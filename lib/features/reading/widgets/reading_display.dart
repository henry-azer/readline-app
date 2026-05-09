import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/services/reading_engine_service.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_tracking.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/entities/reading_state.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';

/// Smooth-scroll reading display — renders the full text in a scrollable view
/// and drives a pixel-based Ticker for continuous movie-credits-style scrolling.
class ReadingDisplay extends StatefulWidget {
  final ReadingEngineService engine;
  final void Function(String word) onWordTap;
  final UserPreferencesModel? prefs;

  const ReadingDisplay({
    super.key,
    required this.engine,
    required this.onWordTap,
    this.prefs,
  });

  @override
  State<ReadingDisplay> createState() => _ReadingDisplayState();
}

class _ReadingDisplayState extends State<ReadingDisplay>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _textKey = GlobalKey();

  Ticker? _ticker;
  StreamSubscription<ReadingState>? _stateSub;

  double _pixelsPerSecond = 0;
  Duration _lastTickTime = Duration.zero;
  int _lastSyncedWordIndex = -1;
  int _lastWpm = 0;
  bool _isSyncing = false;
  bool _isPlaying = false;
  // Fractional word index used by the time-based fallback path, which
  // kicks in when content fits on a single screen and there's no scroll
  // extent to drive progress.
  double _wordCursor = 0;

  @override
  void initState() {
    super.initState();
    widget.engine.setExternalScrollControl(true);
    _lastWpm = widget.engine.currentWpm;
    _stateSub = widget.engine.state$.listen(_onEngineStateChanged);
    _scrollController.addListener(_onManualScroll);
  }

  @override
  void didUpdateWidget(ReadingDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    final prefsChanged =
        widget.prefs?.fontSize != oldWidget.prefs?.fontSize ||
        widget.prefs?.lineSpacing != oldWidget.prefs?.lineSpacing ||
        widget.prefs?.readingMargin != oldWidget.prefs?.readingMargin ||
        widget.prefs?.fontFamily != oldWidget.prefs?.fontFamily ||
        widget.prefs?.letterSpacing != oldWidget.prefs?.letterSpacing;

    if (prefsChanged) {
      if (_isPlaying) _recalculateSpeed();
      // Re-scroll to keep the same word in view after layout changes
      final wordIndex = _lastSyncedWordIndex;
      if (wordIndex > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToWord(wordIndex, animate: false);
        });
      }
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _stateSub?.cancel();
    _scrollController.dispose();
    widget.engine.setExternalScrollControl(false);
    super.dispose();
  }

  // ── Engine state listener ─────────────────────────────────────────

  void _onEngineStateChanged(ReadingState state) {
    if (_isSyncing) return;

    // Play/pause toggle
    if (state.isPlaying && !_isPlaying) {
      _startSmooth();
    } else if (!state.isPlaying && _isPlaying) {
      _stopSmooth();
    }

    // Speed change — adjust scroll rate without interruption
    if (state.currentWpm != _lastWpm) {
      _lastWpm = state.currentWpm;
      if (_isPlaying) _recalculateSpeed();
    }

    // External seek (slider, jumpToWord)
    final wordDiff = (state.currentWordIndex - _lastSyncedWordIndex).abs();
    if (wordDiff > 3) {
      _scrollToWord(state.currentWordIndex, animate: !state.isPlaying);
    }
  }

  // ── Smooth scroll ─────────────────────────────────────────────────

  void _recalculateSpeed() {
    final prefs = widget.prefs;
    final fontSize = prefs?.fontSize.toDouble() ?? 18;
    final lineHeight = prefs?.lineSpacing ?? 1.6;
    final wpm = widget.engine.currentWpm;
    final margin = (prefs?.readingMargin ?? 24).toDouble();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = screenWidth - (margin * 2);
    final avgCharWidth = fontSize * 0.48;
    final wordsPerLine = (availableWidth / (avgCharWidth * 5.0)).clamp(
      4.0,
      18.0,
    );

    final linesPerSecond = (wpm / 60.0) / wordsPerLine;
    _pixelsPerSecond = linesPerSecond * (fontSize * lineHeight);
  }

  void _startSmooth() {
    _isPlaying = true;
    _recalculateSpeed();
    _lastTickTime = Duration.zero;
    _wordCursor = widget.engine.currentWordIndex.toDouble();
    _ticker?.dispose();
    _ticker = createTicker(_onTick)..start();
    if (mounted) setState(() {});
  }

  void _stopSmooth() {
    _isPlaying = false;
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
    if (mounted) setState(() {});
  }

  void _onTick(Duration elapsed) {
    // Skip first frame to establish baseline
    if (_lastTickTime == Duration.zero) {
      _lastTickTime = elapsed;
      return;
    }

    final dt = (elapsed - _lastTickTime).inMicroseconds / 1000000.0;
    _lastTickTime = elapsed;

    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;

    // Content fits on a single screen — there's no scroll runway for the
    // pixel-based loop to drive progress with. Fall back to a time × WPM
    // word counter so short documents (one or two lines) still play and
    // reach the completion summary.
    if (maxExtent <= 0) {
      _advanceByTime(dt);
      return;
    }

    final newOffset = (_scrollController.offset + _pixelsPerSecond * dt).clamp(
      0.0,
      maxExtent,
    );
    _scrollController.jumpTo(newOffset);

    // Reached the end — stop scrolling, then sync final progress.
    // Always call updateProgress (idempotent in the engine) so a stale
    // _lastSyncedWordIndex can't suppress the completion emit.
    if (newOffset >= maxExtent) {
      _stopSmooth();
      final lastWord = widget.engine.totalWords - 1;
      _lastSyncedWordIndex = lastWord;
      _isSyncing = true;
      widget.engine.updateProgress(lastWord);
      _isSyncing = false;
      return;
    }

    _syncProgress(newOffset, maxExtent);
  }

  /// Time-based fallback for content that doesn't fill a screen. Advances
  /// [_wordCursor] by `dt × wpm/60` and reports the floored index to the
  /// engine. Mirrors the engine's internal timer so the user sees the
  /// session progress + completion summary just like a long document.
  void _advanceByTime(double dt) {
    final totalWords = widget.engine.totalWords;
    if (totalWords <= 0) return;

    final wpm = widget.engine.currentWpm;
    _wordCursor += dt * (wpm / 60.0);

    final lastWord = totalWords - 1;
    final newIndex = _wordCursor.floor().clamp(0, lastWord);

    if (newIndex >= lastWord) {
      _stopSmooth();
      _lastSyncedWordIndex = lastWord;
      _isSyncing = true;
      widget.engine.updateProgress(lastWord);
      _isSyncing = false;
      return;
    }

    if (newIndex != _lastSyncedWordIndex) {
      _lastSyncedWordIndex = newIndex;
      _isSyncing = true;
      widget.engine.updateProgress(newIndex);
      _isSyncing = false;
    }
  }

  void _syncProgress(double offset, double maxExtent) {
    if (maxExtent <= 0) return;
    final fraction = offset / maxExtent;
    final totalWords = widget.engine.totalWords;
    final wordIndex = (fraction * totalWords).round().clamp(0, totalWords - 1);

    if (wordIndex != _lastSyncedWordIndex) {
      _lastSyncedWordIndex = wordIndex;
      _isSyncing = true;
      widget.engine.updateProgress(wordIndex);
      _isSyncing = false;
    }
  }

  void _scrollToWord(int wordIndex, {bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      final totalWords = widget.engine.totalWords;
      if (totalWords <= 0 || maxExtent <= 0) return;

      final target = ((wordIndex / totalWords) * maxExtent).clamp(
        0.0,
        maxExtent,
      );
      _lastSyncedWordIndex = wordIndex;

      if (animate) {
        _scrollController.animateTo(
          target,
          duration: AppDurations.calm,
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  /// Sync progress when user manually drags while paused.
  void _onManualScroll() {
    if (_isPlaying || !_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;
    _syncProgress(_scrollController.offset, maxExtent);
  }

  // ── Word tap detection ────────────────────────────────────────────

  // Double-tap is required to open the word popup so casual single taps
  // (used to dismiss the controls bar, etc.) don't accidentally pull it up.
  void _handleDoubleTap(TapDownDetails details) {
    final renderObj = _textKey.currentContext?.findRenderObject();
    if (renderObj is! RenderParagraph) return;

    final localPos = renderObj.globalToLocal(details.globalPosition);
    final textPos = renderObj.getPositionForOffset(localPos);

    final fullText = widget.engine.words.join(' ');
    if (fullText.isEmpty) return;
    final charIdx = textPos.offset.clamp(0, fullText.length - 1);

    // Walk outward to find word boundaries
    int start = charIdx;
    int end = charIdx;
    while (start > 0 && fullText[start - 1] != ' ') {
      start--;
    }
    while (end < fullText.length && fullText[end] != ' ') {
      end++;
    }

    final raw = fullText.substring(start, end).trim();
    final cleaned = raw.replaceAll(RegExp("[^a-zA-Z0-9'-]"), '');
    if (cleaned.isNotEmpty) widget.onWordTap(cleaned);
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final prefs = widget.prefs;
    final isDark = context.isDark;

    final fontColorPref = prefs?.readingFontColor ?? 'default';
    final defaultOnSurface = isDark
        ? AppColors.onSurface
        : AppColors.lightOnSurface;
    // Reading theme (when not 'system') wins over readingFontColor — that's
    // what makes "Sepia/Amoled/Dark/Light" themes actually flip the text
    // color, not just the background.
    final themeColors = readingThemeColors(prefs?.readingTheme);
    final onSurface = themeColors?.fg ??
        (fontColorPref == 'default'
            ? defaultOnSurface
            : _parseFontColor(fontColorPref, defaultOnSurface));

    final family = prefs?.fontFamily ?? 'newsreader';
    final fontSize = prefs?.fontSize.toDouble() ?? 18;
    final lineHeight = prefs?.lineSpacing ?? 1.6;
    final margin = (prefs?.readingMargin ?? 24).toDouble();
    final textAlign = _resolveAlign(prefs?.textAlignment);

    final isBold = prefs?.readingBold ?? false;
    final isItalic = prefs?.readingItalic ?? false;
    final isUnderline = prefs?.readingUnderline ?? false;
    final letterSpacingValue = _resolveLetterSpacing(prefs?.letterSpacing);

    final textStyle = AppTypography.readingFont(family, fontSize: fontSize)
        .copyWith(
          color: onSurface,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          decoration: isUnderline
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: onSurface.withValues(alpha: 0.4),
          height: lineHeight,
          letterSpacing: letterSpacingValue,
        );

    final screenHeight = MediaQuery.sizeOf(context).height;
    // Text starts at ~38% from top so the "focus zone" sits at natural eye level
    final topPad = screenHeight * 0.38;
    final bottomPad = screenHeight * 0.55;

    return StreamBuilder<ReadingState>(
      stream: widget.engine.state$.stream.distinct(
        (a, b) =>
            a.highlightedWord == b.highlightedWord &&
            a.totalWords == b.totalWords,
      ),
      builder: (context, snap) {
        final highlightedWord = snap.data?.highlightedWord;
        final words = widget.engine.words;

        if (words.isEmpty) {
          return Center(
            child: Text(AppStrings.readingLoading.tr, style: textStyle),
          );
        }

        final fullText = words.join(' ');
        final textSpan = _buildSpan(
          fullText,
          highlightedWord,
          textStyle,
          isDark,
        );

        return GestureDetector(
          onDoubleTapDown: _handleDoubleTap,
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: _isPlaying
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: margin,
              right: margin,
              top: topPad,
              bottom: bottomPad,
            ),
            child: RichText(
              key: _textKey,
              text: textSpan,
              textAlign: textAlign,
            ),
          ),
        );
      },
    );
  }

  /// Build a [TextSpan] with optional highlighted word.
  TextSpan _buildSpan(
    String fullText,
    String? highlightedWord,
    TextStyle style,
    bool isDark,
  ) {
    if (highlightedWord == null || highlightedWord.isEmpty) {
      return TextSpan(text: fullText, style: style);
    }

    final pattern = RegExp(
      r'\b' + RegExp.escape(highlightedWord) + r'\b',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(fullText);
    if (match == null) {
      return TextSpan(text: fullText, style: style);
    }

    final highlightBg = isDark
        ? AppColors.primary.withValues(alpha: 0.25)
        : AppColors.lightPrimary.withValues(alpha: 0.15);

    return TextSpan(
      children: [
        TextSpan(text: fullText.substring(0, match.start), style: style),
        TextSpan(
          text: fullText.substring(match.start, match.end),
          style: style.copyWith(
            backgroundColor: highlightBg,
            decoration: TextDecoration.underline,
            decorationColor: highlightBg,
          ),
        ),
        TextSpan(text: fullText.substring(match.end), style: style),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Color _parseFontColor(String value, Color fallback) {
  final parsed = int.tryParse(value, radix: 16);
  if (parsed != null) return Color(parsed);
  return fallback;
}

double _resolveLetterSpacing(String? spacing) {
  switch (spacing) {
    case 'tight':
      return AppTracking.tight;
    case 'wide':
      return AppTracking.wide;
    default:
      return AppTracking.normal;
  }
}

TextAlign _resolveAlign(String? alignment) {
  switch (alignment) {
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
    case 'justified':
      return TextAlign.justify;
    default:
      return TextAlign.left;
  }
}

/// Resolves the reading-theme preference into a (background, foreground)
/// color pair. Returns `null` for "system" or unknown values so callers can
/// fall back to the default surface / on-surface colors.
({Color bg, Color fg})? readingThemeColors(String? theme) {
  switch (theme) {
    case 'light':
      return (
        bg: AppColors.readingThemeLightBg,
        fg: AppColors.readingThemeLightFg,
      );
    case 'dark':
      return (
        bg: AppColors.readingThemeDarkBg,
        fg: AppColors.readingThemeDarkFg,
      );
    case 'sepia':
      return (
        bg: AppColors.readingThemeSepiaBg,
        fg: AppColors.readingThemeSepiaFg,
      );
    case 'amoled':
      return (
        bg: AppColors.readingThemeAmoledBg,
        fg: AppColors.readingThemeAmoledFg,
      );
    default:
      return null;
  }
}
