import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/constants/app_constants.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/router/app_router.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/theme/app_breakpoints.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/data/entities/reading_state.dart';
import 'package:readline_app/data/models/celebration_data.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';
import 'package:readline_app/features/reading/viewmodels/reading_viewmodel.dart';
import 'package:readline_app/features/reading/widgets/player_settings_sheet.dart';
import 'package:readline_app/features/reading/widgets/reading_body.dart';
import 'package:readline_app/features/reading/widgets/reading_display.dart'
    show readingThemeColors;
import 'package:readline_app/features/reading/widgets/reading_error_body.dart';
import 'package:readline_app/features/reading/widgets/session_summary_dialog.dart';
import 'package:readline_app/features/reading/widgets/word_definition_popup.dart';
import 'package:readline_app/widgets/celebration_overlay.dart';

/// Approximate height of the bottom player controls bar so the vocab
/// highlight panel can stretch its background behind the controls without
/// covering its own content.
double readingControlsBarApproxHeight(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final safeBottom = MediaQuery.paddingOf(context).bottom;
  final base = width < AppBreakpoints.compact
      ? 140.0
      : width >= AppBreakpoints.expanded
          ? 180.0
          : 160.0;
  return base + safeBottom;
}

/// Visible height of the vocab highlight bar above the controls.
const double _kVocabBarVisibleHeight = 80.0;

/// Bottom area to keep tappable while the popup's tap-outside catcher is
/// active — covers the vocab bar's visible row + the controls bar.
double popupBottomReserve(BuildContext context) =>
    _kVocabBarVisibleHeight + readingControlsBarApproxHeight(context);

class ReadingScreen extends StatefulWidget {
  final String documentId;
  final bool restart;

  const ReadingScreen({
    super.key,
    required this.documentId,
    this.restart = false,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen>
    with WidgetsBindingObserver {
  late final ReadingViewModel _viewModel;
  StreamSubscription<ReadingState>? _completionSub;
  StreamSubscription<CelebrationData?>? _celebrationSub;
  String? _tappedWord;
  bool _showVocabBar = false;
  bool _completionHandled = false;
  bool _wasAutoPlayActive = false;
  bool _celebrationOpen = false;
  // Resolves when the active celebration overlay closes. _handleComplete
  // awaits it before showing the session summary so a milestone celebration
  // never appears stacked behind the summary dialog.
  Completer<void>? _celebrationCompleter;
  OverlayEntry? _definitionPopupEntry;
  // Saved-state of the currently tapped word; shared by the bottom vocab bar
  // and the top definition popup so both reflect the same value.
  final ValueNotifier<bool> _isCurrentWordSaved = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _viewModel = ReadingViewModel(
      documentId: widget.documentId,
      restart: widget.restart,
    );
    _viewModel.startCelebrationListening();
    _viewModel.init().then((_) async {
      if (!mounted) return;
      // Auto-play unconditionally on entry — every path into the player
      // (document tap, resume, deep-link) starts reading immediately.
      await Future<void>.delayed(AppDurations.slow);
      if (!mounted) return;
      if (!_viewModel.currentReadingState.isPlaying) {
        _viewModel.togglePlayPause();
      }
    });
    _listenForCompletion();
    _listenForCelebrations();
  }

  void _listenForCelebrations() {
    _celebrationSub = _viewModel.pendingCelebration$.listen((celebration) {
      if (!mounted || celebration == null || _celebrationOpen) return;
      _showCelebration(celebration);
    });
  }

  Future<void> _showCelebration(CelebrationData celebration) async {
    _celebrationOpen = true;
    _celebrationCompleter = Completer<void>();

    final wasPlaying = _viewModel.currentReadingState.isPlaying;
    if (wasPlaying) _viewModel.togglePlayPause();

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (_, _, _) => CelebrationOverlay(
          celebration: celebration,
          showKeepReading: true,
          onContinue: () {
            _viewModel.clearPendingCelebration();
            Navigator.of(context).pop();
          },
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: AppDurations.calm,
        reverseTransitionDuration: AppDurations.normal,
      ),
    );

    _celebrationOpen = false;
    if (!(_celebrationCompleter?.isCompleted ?? true)) {
      _celebrationCompleter!.complete();
    }
    _celebrationCompleter = null;

    if (!mounted || !wasPlaying) return;
    await Future<void>.delayed(AppDurations.slow);
    if (!mounted) return;
    if (!_viewModel.currentReadingState.isPlaying) {
      _viewModel.togglePlayPause();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _viewModel.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      _viewModel.onAppResumed();
    }
  }

  void _listenForCompletion() {
    _completionSub = _viewModel.readingState$.skip(1).listen((state) {
      if (state.isComplete && mounted && !_completionHandled) {
        _completionHandled = true;
        _handleComplete();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    _definitionPopupEntry?.remove();
    _definitionPopupEntry = null;
    _isCurrentWordSaved.dispose();
    _completionSub?.cancel();
    _celebrationSub?.cancel();
    _viewModel.saveSession();
    _viewModel.dispose();
    super.dispose();
  }

  // ── User actions ───────────────────────────────────────────────────────────

  void _handleWordTap(String word) {
    final prefs = _viewModel.preferences$.valueOrNull;
    if (!(prefs?.enableVocabCollection ?? true)) return;
    getIt<HapticService>().light();

    _wasAutoPlayActive = _viewModel.currentReadingState.isPlaying;
    _viewModel.beginInteractivePause();
    if (_wasAutoPlayActive) {
      _viewModel.togglePlayPause();
    }

    _viewModel.highlightWord(word);
    setState(() {
      _tappedWord = word;
      _showVocabBar = true;
    });

    _isCurrentWordSaved.value = false;
    _viewModel.isWordSaved(word).then((saved) {
      if (!mounted || _tappedWord != word) return;
      _isCurrentWordSaved.value = saved;
    });

    _showDefinitionPopup(word);
  }

  void _showDefinitionPopup(String word) {
    _definitionPopupEntry?.remove();
    _definitionPopupEntry = null;

    final doc = _viewModel.document$.valueOrNull;
    final state = _viewModel.currentReadingState;

    _definitionPopupEntry = showWordDefinitionPopup(
      context: context,
      word: word,
      tapPosition: Offset(
        MediaQuery.sizeOf(context).width / 2,
        MediaQuery.sizeOf(context).height * 0.25,
      ),
      sourceDocumentId: doc?.id ?? '',
      sourceDocumentTitle: doc?.title ?? '',
      contextSentence: state.focusText.isNotEmpty ? state.focusText : word,
      onDismiss: _dismissDefinitionPopup,
      onCloseStarted: _dismissVocabBar,
      onSaved: () {
        _viewModel.wordsCollected$.add(_viewModel.wordsCollected$.value + 1);
      },
      savedListener: _isCurrentWordSaved,
      onToggle: _toggleSaveCurrentWord,
      bottomReserve: popupBottomReserve(context),
    );
  }

  void _dismissDefinitionPopup() {
    final entry = _definitionPopupEntry;
    _definitionPopupEntry = null;
    entry?.remove();
    _dismissVocabBar();

    _viewModel.endInteractivePause();

    if (_wasAutoPlayActive && mounted) {
      _wasAutoPlayActive = false;
      _viewModel.togglePlayPause();
    }
  }

  void _dismissVocabBar() {
    _viewModel.highlightWord(null);
    setState(() {
      _tappedWord = null;
      _showVocabBar = false;
    });
  }

  Future<void> _toggleSaveCurrentWord() async {
    final word = _tappedWord;
    if (word == null) return;
    if (_isCurrentWordSaved.value) {
      await _viewModel.removeWordFromVocabulary(word);
      if (!mounted) return;
      _isCurrentWordSaved.value = false;
    } else {
      await _viewModel.saveWordToVocabulary(word);
      if (!mounted) return;
      _isCurrentWordSaved.value = true;
    }
    if (mounted) _dismissDefinitionPopup();
  }

  Future<void> _handleBack() async {
    await _viewModel.saveSession();
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _handleComplete() async {
    await _viewModel.onComplete();
    if (!mounted) return;

    final pending = _celebrationCompleter?.future;
    if (pending != null) {
      await pending;
      if (!mounted) return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.barrierOverlay,
      builder: (dialogContext) => SessionSummaryDialog(
        session: _viewModel.completedSession,
        onDone: () => Navigator.of(dialogContext).pop(),
      ),
    );
    if (!mounted) return;

    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  // ── Player settings sheet ──────────────────────────────────────────────────

  void _showPlayerSettings() {
    final prefs = _viewModel.preferences$.valueOrNull;
    if (prefs == null) return;

    final wasPlaying = _viewModel.currentReadingState.isPlaying;
    _viewModel.beginInteractivePause();
    if (wasPlaying) _viewModel.togglePlayPause();

    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: AppColors.barrierOverlay,
        fullscreenDialog: true,
        pageBuilder: (_, _, _) => PlayerSettingsSheet(
          prefs: prefs,
          onSpeedChanged: (v) => _viewModel.adjustSpeed(v),
          onFontSizeChanged: (v) => _viewModel.updateFontSize(v),
          onLineSpacingChanged: (v) => _viewModel.updateLineSpacing(v),
          onFocusLinesChanged: (v) => _viewModel.updateFocusLines(v),
          onFontFamilyChanged: (v) => _viewModel.updateFontFamily(v),
          onVocabToggled: () => _viewModel.toggleVocabCollection(),
          onTextAlignmentChanged: (v) => _viewModel.updateTextAlignment(v),
          onBackgroundChanged: (v) => _viewModel.updateReadingBackground(v),
          onMarginChanged: (v) => _viewModel.updateReadingMargin(v),
          onBrightnessChanged: (v) => _viewModel.updateBrightnessLevel(v),
          onDimChanged: (v) => _viewModel.updateBrightnessOverlay(v),
          onFontColorChanged: (v) => _viewModel.updateReadingFontColor(v),
          onBoldToggled: () => _viewModel.toggleBold(),
          onItalicToggled: () => _viewModel.toggleItalic(),
          onUnderlineToggled: () => _viewModel.toggleUnderline(),
          onLetterSpacingChanged: (v) => _viewModel.updateLetterSpacing(v),
          onReadingThemeChanged: (v) => _viewModel.updateReadingTheme(v),
        ),
        transitionsBuilder: (_, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: AppDurations.smooth,
        reverseTransitionDuration: AppDurations.calm,
      ),
    ).then((_) async {
      _viewModel.endInteractivePause();
      if (!mounted || !wasPlaying) return;
      await Future<void>.delayed(AppDurations.slow);
      if (!mounted) return;
      if (!_viewModel.currentReadingState.isPlaying) {
        _viewModel.togglePlayPause();
      }
    });
  }

  // ── Speed / font / seek helpers ───────────────────────────────────────────

  void _onSpeedDecrease() {
    final current = _viewModel.currentWpm;
    _viewModel.adjustSpeed(
      (current - AppConstants.wpmStep).clamp(
        AppConstants.minWpm,
        AppConstants.maxWpm,
      ),
    );
  }

  void _onSpeedIncrease() {
    final current = _viewModel.currentWpm;
    _viewModel.adjustSpeed(
      (current + AppConstants.wpmStep).clamp(
        AppConstants.minWpm,
        AppConstants.maxWpm,
      ),
    );
  }

  void _onFontSizeDecrease() {
    final current =
        _viewModel.preferences$.valueOrNull?.fontSize ??
        AppConstants.minFontSize;
    final next = (current - AppConstants.fontSizeStep).clamp(
      AppConstants.minFontSize,
      AppConstants.maxFontSize,
    );
    _viewModel.updateFontSize(next);
  }

  void _onFontSizeIncrease() {
    final current =
        _viewModel.preferences$.valueOrNull?.fontSize ??
        AppConstants.maxFontSize;
    final next = (current + AppConstants.fontSizeStep).clamp(
      AppConstants.minFontSize,
      AppConstants.maxFontSize,
    );
    _viewModel.updateFontSize(next);
  }

  void _onSeek(double progress) {
    final totalWords = _viewModel.totalWords;
    final targetIndex = (progress * totalWords).round().clamp(
      0,
      totalWords - 1,
    );
    _viewModel.jumpToWord(targetIndex);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  Color _resolveColor(
    bool isDark,
    String value,
    Color lightDefault,
    Color darkDefault,
  ) => AppColors.resolveReadingColor(isDark, value, lightDefault, darkDefault);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return StreamBuilder<UserPreferencesModel?>(
      stream: _viewModel.preferences$,
      builder: (context, prefsSnap) {
        final prefs = prefsSnap.data;
        final bgPreset = prefs?.readingBackground ?? 'default';
        final fontPreset = prefs?.readingFontColor ?? 'default';
        final dimVal = prefs?.brightnessOverlay ?? 0;
        final brightVal = prefs?.brightnessLevel ?? 0;

        final themePreset = readingThemeColors(prefs?.readingTheme);
        final bgColor = themePreset?.bg ??
            _resolveColor(
              isDark,
              bgPreset,
              AppColors.lightSurface,
              AppColors.surface,
            );
        final bgLuminance = bgColor.computeLuminance();
        final effectiveDark = bgLuminance < 0.4;

        final defaultOnSurface = effectiveDark
            ? AppColors.onSurface
            : AppColors.lightOnSurface;
        final onSurface = themePreset?.fg ??
            (fontPreset == 'default'
                ? defaultOnSurface
                : _resolveColor(
                    isDark,
                    fontPreset,
                    defaultOnSurface,
                    defaultOnSurface,
                  ));

        final popScope = PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop) await _handleBack();
          },
          child: Scaffold(
            backgroundColor: bgColor,
            body: StreamBuilder<bool>(
              stream: _viewModel.isLoading$,
              builder: (context, loadingSnap) {
                if (loadingSnap.data ?? true) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDark
                          ? AppColors.primary
                          : AppColors.lightPrimary,
                    ),
                  );
                }
                return StreamBuilder<String?>(
                  stream: _viewModel.error$,
                  builder: (context, errSnap) {
                    if (errSnap.data != null) {
                      return ReadingErrorBody(
                        message: errSnap.data!,
                        onBack: _handleBack,
                        isDark: isDark,
                        onSurface: onSurface,
                      );
                    }
                    return ReadingBody(
                      viewModel: _viewModel,
                      showVocabBar: _showVocabBar,
                      tappedWord: _tappedWord,
                      isCurrentWordSaved: _isCurrentWordSaved,
                      onWordTap: _handleWordTap,
                      onVocabToggle: _toggleSaveCurrentWord,
                      onVocabDismiss: _dismissDefinitionPopup,
                      onPlayPause: _viewModel.togglePlayPause,
                      onSpeedDecrease: _onSpeedDecrease,
                      onSpeedIncrease: _onSpeedIncrease,
                      onFontSizeDecrease: _onFontSizeDecrease,
                      onFontSizeIncrease: _onFontSizeIncrease,
                      onSeek: _onSeek,
                      onBack: _handleBack,
                      onShowSettings: _showPlayerSettings,
                    );
                  },
                );
              },
            ),
          ),
        );

        // Brightness (white) + Dim (black) overlays
        final hasOverlay = brightVal > 0 || dimVal > 0;
        final content = hasOverlay
            ? Stack(
                children: [
                  popScope,
                  if (brightVal > 0)
                    IgnorePointer(
                      child: ColoredBox(
                        color: Color.fromRGBO(255, 255, 255, brightVal),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  if (dimVal > 0)
                    IgnorePointer(
                      child: ColoredBox(
                        color: Color.fromRGBO(0, 0, 0, dimVal),
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              )
            : popScope;

        return content;
      },
    );
  }
}
