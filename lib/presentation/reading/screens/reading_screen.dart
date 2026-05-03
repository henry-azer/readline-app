import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:read_it/core/services/celebration_service.dart';
import 'package:read_it/core/services/haptic_service.dart';
import 'package:read_it/core/services/share_card_service.dart';
import 'package:read_it/core/theme/app_curves.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/constants/app_constants.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/router/app_router.dart';
import 'package:read_it/core/services/reading_engine_service.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/entities/reading_state.dart';
import 'package:read_it/data/models/celebration_data.dart';
import 'package:read_it/data/models/document_model.dart';
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/user_preferences_model.dart';
import 'package:read_it/presentation/reading/viewmodels/reading_viewmodel.dart';
import 'package:read_it/presentation/reading/widgets/player_settings_sheet.dart';
import 'package:read_it/presentation/reading/widgets/reading_controls.dart';
import 'package:read_it/presentation/reading/widgets/reading_display.dart';
import 'package:read_it/presentation/reading/widgets/session_summary_dialog.dart';
import 'package:read_it/presentation/reading/widgets/vocab_highlight.dart';
import 'package:read_it/presentation/reading/widgets/word_definition_popup.dart';
import 'package:read_it/presentation/widgets/celebration_overlay.dart';

class ReadingScreen extends StatefulWidget {
  final String documentId;
  final bool autoPlay;
  final bool restart;

  const ReadingScreen({
    super.key,
    required this.documentId,
    this.autoPlay = false,
    this.restart = false,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen>
    with WidgetsBindingObserver {
  static const _actionButtonSize = 36.0;

  late final ReadingViewModel _viewModel;
  late final CelebrationService _celebrationService;
  StreamSubscription<ReadingState>? _completionSub;
  StreamSubscription<CelebrationData?>? _celebrationSub;
  String? _tappedWord;
  bool _showVocabBar = false;
  bool _completionHandled = false;
  bool _wasAutoPlayActive = false;
  bool _celebrationOpen = false;
  OverlayEntry? _definitionPopupEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Enter immersive mode — hide status bar and navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _viewModel = ReadingViewModel(
      documentId: widget.documentId,
      restart: widget.restart,
    );
    _celebrationService = getIt<CelebrationService>();
    _celebrationService.startListening();
    _viewModel.init().then((_) async {
      if (!mounted) return;
      await Future<void>.delayed(AppDurations.slow);
      if (!mounted) return;
      if (!getIt<ReadingEngineService>().state$.value.isPlaying) {
        _viewModel.togglePlayPause();
      }
    });
    _listenForCompletion();
    _listenForCelebrations();
  }

  void _listenForCelebrations() {
    _celebrationSub = _celebrationService.pendingCelebration$.listen((
      celebration,
    ) {
      if (!mounted || celebration == null || _celebrationOpen) return;
      _showCelebration(celebration);
    });
  }

  void _showCelebration(CelebrationData celebration) {
    _celebrationOpen = true;

    // Pause playback while celebrating; resume after dismiss if it was playing.
    final engine = getIt<ReadingEngineService>();
    final wasPlaying = engine.state$.value.isPlaying;
    if (wasPlaying) _viewModel.togglePlayPause();

    final shareKey = GlobalKey();
    Navigator.of(context)
        .push(
          PageRouteBuilder<void>(
            opaque: false,
            barrierDismissible: false,
            pageBuilder: (_, _, _) => CelebrationOverlay(
              celebration: celebration,
              shareCardKey: shareKey,
              showKeepReading: true,
              onContinue: () {
                _celebrationService.clearPending();
                Navigator.of(context).pop();
              },
              onShare: () async {
                final shareService = getIt<ShareCardService>();
                await shareService.captureAndShare(shareKey);
              },
            ),
            transitionsBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: AppDurations.calm,
            reverseTransitionDuration: AppDurations.normal,
          ),
        )
        .then((_) async {
          _celebrationOpen = false;
          if (!mounted || !wasPlaying) return;
          await Future<void>.delayed(AppDurations.slow);
          if (!mounted) return;
          if (!engine.state$.value.isPlaying) {
            _viewModel.togglePlayPause();
          }
        });
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
    _completionSub = _viewModel.readingState$.listen((state) {
      if (state.isComplete && mounted && !_completionHandled) {
        _completionHandled = true;
        _handleComplete();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    _definitionPopupEntry?.remove();
    _definitionPopupEntry = null;
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

    // Pause auto-play if active
    final engine = getIt<ReadingEngineService>();
    _wasAutoPlayActive = engine.state$.value.isPlaying;
    if (_wasAutoPlayActive) {
      _viewModel.togglePlayPause();
    }

    engine.highlightWord(word);
    setState(() {
      _tappedWord = word;
      _showVocabBar = true;
    });

    // Show dictionary definition popup
    _showDefinitionPopup(word);
  }

  void _showDefinitionPopup(String word) {
    _definitionPopupEntry?.remove();
    _definitionPopupEntry = null;

    final doc = _viewModel.document$.valueOrNull;
    final engine = getIt<ReadingEngineService>();
    final state = engine.state$.value;

    _definitionPopupEntry = showWordDefinitionPopup(
      context: context,
      word: word,
      tapPosition: Offset(
        MediaQuery.sizeOf(context).width / 2,
        MediaQuery.sizeOf(context).height * 0.35,
      ),
      sourceDocumentId: doc?.id ?? '',
      sourceDocumentTitle: doc?.title ?? '',
      contextSentence: state.focusText.isNotEmpty ? state.focusText : word,
      onDismiss: _dismissDefinitionPopup,
      onSaved: () {
        _viewModel.wordsCollected$.add(_viewModel.wordsCollected$.value + 1);
      },
    );
  }

  void _dismissDefinitionPopup() {
    _definitionPopupEntry = null;
    _dismissVocabBar();

    // Resume auto-play if it was active before word tap
    if (_wasAutoPlayActive && mounted) {
      Future.delayed(AppDurations.slow, () {
        if (mounted && _wasAutoPlayActive) {
          _viewModel.togglePlayPause();
          _wasAutoPlayActive = false;
        }
      });
    }
  }

  void _dismissVocabBar() {
    getIt<ReadingEngineService>().highlightWord(null);
    setState(() {
      _tappedWord = null;
      _showVocabBar = false;
    });
  }

  Future<void> _saveToVocab() async {
    final word = _tappedWord;
    if (word == null) return;
    await _viewModel.saveWordToVocabulary(word);
    _dismissVocabBar();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.vocabSavedSnackbar.trParams({'word': word}),
            style: AppTypography.bodyMedium,
          ),
          duration: AppDurations.snackbar,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
    final session = _viewModel.completedSession;
    await _showSessionSummary(session);
  }

  // ── Player settings sheet ──────────────────────────────────────────────────

  void _showPlayerSettings() {
    final prefs = _viewModel.preferences$.valueOrNull;
    if (prefs == null) return;

    final engine = getIt<ReadingEngineService>();
    final wasPlaying = engine.state$.value.isPlaying;
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
          onAutoPlayToggled: () => _viewModel.toggleAutoPlay(),
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
      if (!mounted || !wasPlaying) return;
      await Future<void>.delayed(AppDurations.slow);
      if (!mounted) return;
      if (!engine.state$.value.isPlaying) {
        _viewModel.togglePlayPause();
      }
    });
  }

  // ── Speed helpers ──────────────────────────────────────────────────────────

  void _onSpeedDecrease() {
    final current = getIt<ReadingEngineService>().currentWpm;
    _viewModel.adjustSpeed(
      (current - AppConstants.wpmStep).clamp(
        AppConstants.minWpm,
        AppConstants.maxWpm,
      ),
    );
  }

  void _onSpeedIncrease() {
    final current = getIt<ReadingEngineService>().currentWpm;
    _viewModel.adjustSpeed(
      (current + AppConstants.wpmStep).clamp(
        AppConstants.minWpm,
        AppConstants.maxWpm,
      ),
    );
  }

  // ── Font size helpers ─────────────────────────────────────────────────────

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

  // ── Seek helper ───────────────────────────────────────────────────────────

  void _onSeek(double progress) {
    final totalWords = getIt<ReadingEngineService>().totalWords;
    final targetIndex = (progress * totalWords).round().clamp(
      0,
      totalWords - 1,
    );
    _viewModel.jumpToWord(targetIndex);
  }

  // ── Session summary dialog ─────────────────────────────────────────────────

  Future<void> _showSessionSummary(ReadingSessionModel? session) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SessionSummaryDialog(
        session: session,
        onDone: () {
          Navigator.of(ctx).pop();
          context.go(AppRoutes.home);
        },
      ),
    );
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

        final bgColor = _resolveColor(
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
        final onSurface = fontPreset == 'default'
            ? defaultOnSurface
            : _resolveColor(
                isDark,
                fontPreset,
                defaultOnSurface,
                defaultOnSurface,
              );
        final onSurfaceVariant = effectiveDark
            ? AppColors.onSurfaceVariant
            : AppColors.lightOnSurfaceVariant;

        final popScope = PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop) await _handleBack();
          },
          child: Scaffold(
            backgroundColor: bgColor,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: AppColors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: Container(
                margin: const EdgeInsets.only(left: AppSpacing.xs),
                child: IconButton(
                  icon: Container(
                    width: _actionButtonSize,
                    height: _actionButtonSize,
                    decoration: BoxDecoration(
                      color: bgColor.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  onPressed: _handleBack,
                  tooltip: AppStrings.readingBack.tr,
                ),
              ),
              title: StreamBuilder<DocumentModel?>(
                stream: _viewModel.document$,
                builder: (context, snap) {
                  final doc = snap.data;
                  return Text(
                    doc?.title ?? '',
                    style: AppTypography.labelMedium.copyWith(
                      color: onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              centerTitle: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: AppSpacing.xs),
                  child: IconButton(
                    icon: Container(
                      width: _actionButtonSize,
                      height: _actionButtonSize,
                      decoration: BoxDecoration(
                        color: bgColor.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: onSurfaceVariant,
                        size: 18,
                      ),
                    ),
                    onPressed: _showPlayerSettings,
                  ),
                ),
              ],
            ),
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
                      return _ErrorBody(
                        message: errSnap.data!,
                        onBack: _handleBack,
                        isDark: isDark,
                        onSurface: onSurface,
                      );
                    }
                    return _ReadingBody(
                      viewModel: _viewModel,
                      showVocabBar: _showVocabBar,
                      tappedWord: _tappedWord,
                      onWordTap: _handleWordTap,
                      onVocabSave: _saveToVocab,
                      onVocabDismiss: _dismissVocabBar,
                      onPlayPause: _viewModel.togglePlayPause,
                      onSpeedDecrease: _onSpeedDecrease,
                      onSpeedIncrease: _onSpeedIncrease,
                      onFontSizeDecrease: _onFontSizeDecrease,
                      onFontSizeIncrease: _onFontSizeIncrease,
                      onSeek: _onSeek,
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

// ── Reading body ───────────────────────────────────────────────────────────────

class _ReadingBody extends StatelessWidget {
  final ReadingViewModel viewModel;
  final bool showVocabBar;
  final String? tappedWord;
  final void Function(String) onWordTap;
  final VoidCallback onVocabSave;
  final VoidCallback onVocabDismiss;
  final VoidCallback onPlayPause;
  final VoidCallback onSpeedDecrease;
  final VoidCallback onSpeedIncrease;
  final VoidCallback onFontSizeDecrease;
  final VoidCallback onFontSizeIncrease;
  final ValueChanged<double> onSeek;

  const _ReadingBody({
    required this.viewModel,
    required this.showVocabBar,
    required this.tappedWord,
    required this.onWordTap,
    required this.onVocabSave,
    required this.onVocabDismiss,
    required this.onPlayPause,
    required this.onSpeedDecrease,
    required this.onSpeedIncrease,
    required this.onFontSizeDecrease,
    required this.onFontSizeIncrease,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final engine = getIt<ReadingEngineService>();
    final isDark = context.isDark;

    // Resolve bg from prefs for fade gradient
    final bgPreset = viewModel.preferences$.valueOrNull?.readingBackground;
    final fadeBg = _resolveFadeBg(isDark, bgPreset ?? 'default');

    return StreamBuilder<ReadingState>(
      stream: viewModel.readingState$,
      initialData: engine.state$.value,
      builder: (context, snap) {
        final state = snap.data ?? engine.state$.value;

        return StreamBuilder<UserPreferencesModel?>(
          stream: viewModel.preferences$,
          builder: (context, prefsSnap) {
            final prefs = prefsSnap.data;

            final topBarHeight =
                MediaQuery.paddingOf(context).top + kToolbarHeight;
            final bottomSafe = MediaQuery.paddingOf(context).bottom;
            final controlsHeight = 12.0 + 3 + 12 + 56 + bottomSafe + 16;

            return Stack(
              children: [
                // ── Reading display — fills entire screen
                Positioned.fill(
                  child: ReadingDisplay(
                    engine: engine,
                    onWordTap: onWordTap,
                    prefs: prefs,
                  ),
                ),

                // ── Top fade gradient — fully opaque behind AppBar, fades out below
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: topBarHeight + 120,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            fadeBg.withValues(alpha: 0),
                            fadeBg.withValues(alpha: 0.7),
                            fadeBg,
                            fadeBg,
                          ],
                          stops: const [0.0, 0.35, 0.6, 1.0],
                        ),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),

                // ── Bottom fade gradient — fully opaque behind controls, fades out above
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: controlsHeight + 250,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            fadeBg.withValues(alpha: 0),
                            fadeBg.withValues(alpha: 0.4),
                            fadeBg.withValues(alpha: 0.8),
                            fadeBg.withValues(alpha: 0.95),
                            fadeBg,
                          ],
                          stops: const [0.0, 0.25, 0.5, 0.7, 1.0],
                        ),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),

                // ── Vocabulary highlight bar + Controls — pinned at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: AppDurations.calm,
                        transitionBuilder: (child, animation) {
                          return SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0, 1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: AppCurves.enter,
                                  ),
                                ),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: (showVocabBar && tappedWord != null)
                            ? VocabHighlight(
                                key: ValueKey('vocab_$tappedWord'),
                                word: tappedWord!,
                                onSave: onVocabSave,
                                onDismiss: onVocabDismiss,
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('vocab_empty'),
                              ),
                      ),
                      ReadingControls(
                        state: state,
                        onPlayPause: onPlayPause,
                        onSpeedDecrease: onSpeedDecrease,
                        onSpeedIncrease: onSpeedIncrease,
                        onFontSizeDecrease: onFontSizeDecrease,
                        onFontSizeIncrease: onFontSizeIncrease,
                        canDecreaseFontSize:
                            (prefs?.fontSize ?? AppConstants.minFontSize) >
                            AppConstants.minFontSize,
                        canIncreaseFontSize:
                            (prefs?.fontSize ?? AppConstants.maxFontSize) <
                            AppConstants.maxFontSize,
                        onSeek: onSeek,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Color _resolveFadeBg(bool isDark, String preset) =>
      AppColors.resolveReadingColor(
        isDark,
        preset,
        AppColors.lightSurface,
        AppColors.surface,
      );
}

// ── Error state ────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  final bool isDark;
  final Color onSurface;

  const _ErrorBody({
    required this.message,
    required this.onBack,
    required this.isDark,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: isDark ? AppColors.error : AppColors.lightError,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(color: onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton(
              onPressed: onBack,
              child: Text(
                AppStrings.readingGoBack.tr,
                style: AppTypography.button.copyWith(
                  color: isDark ? AppColors.primary : AppColors.lightPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
