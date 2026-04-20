import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:read_it/data/models/reading_session_model.dart';
import 'package:read_it/data/models/streak_model.dart';
import 'package:read_it/presentation/reading/viewmodels/reading_viewmodel.dart';
import 'package:read_it/presentation/reading/widgets/reading_controls.dart';
import 'package:read_it/presentation/reading/widgets/reading_display.dart';
import 'package:read_it/presentation/reading/widgets/streak_badge.dart';
import 'package:read_it/presentation/reading/widgets/vocab_highlight.dart';

class ReadingScreen extends StatefulWidget {
  final String documentId;

  const ReadingScreen({super.key, required this.documentId});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late final ReadingViewModel _viewModel;
  StreamSubscription<ReadingState>? _completionSub;
  String? _tappedWord;
  bool _showVocabBar = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ReadingViewModel(documentId: widget.documentId);
    _viewModel.init();
    _listenForCompletion();
  }

  void _listenForCompletion() {
    _completionSub = _viewModel.readingState$.listen((state) {
      if (state.isComplete && mounted) {
        _handleComplete();
      }
    });
  }

  @override
  void dispose() {
    _completionSub?.cancel();
    // Save session best-effort on dispose; ViewModel guards against closed subjects.
    _viewModel.saveSession();
    _viewModel.dispose();
    super.dispose();
  }

  // ── User actions ───────────────────────────────────────────────────────────

  void _handleWordTap(String word) {
    HapticFeedback.lightImpact();
    getIt<ReadingEngineService>().highlightWord(word);
    setState(() {
      _tappedWord = word;
      _showVocabBar = true;
    });
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
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleBack() async {
    await _viewModel.saveSession();
    if (mounted) context.go(AppRoutes.library);
  }

  Future<void> _handleStop() async {
    await _viewModel.saveSession();
    if (mounted) context.go(AppRoutes.library);
  }

  Future<void> _handleComplete() async {
    await _viewModel.onComplete();
    if (!mounted) return;
    final session = _viewModel.completedSession;
    await _showSessionSummary(session);
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

  // ── Session summary dialog ─────────────────────────────────────────────────

  Future<void> _showSessionSummary(ReadingSessionModel? session) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SessionSummaryDialog(
        session: session,
        onDone: () {
          Navigator.of(ctx).pop();
          context.go(AppRoutes.home);
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _handleBack();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: false,
        appBar: _buildAppBar(
          isDark: isDark,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
        ),
        body: StreamBuilder<bool>(
          stream: _viewModel.isLoading$,
          builder: (context, loadingSnap) {
            if (loadingSnap.data ?? true) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDark ? AppColors.primary : AppColors.lightPrimary,
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
                  onStop: _handleStop,
                  onSpeedDecrease: _onSpeedDecrease,
                  onSpeedIncrease: _onSpeedIncrease,
                );
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({
    required bool isDark,
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: onSurface),
        onPressed: _handleBack,
        tooltip: AppStrings.readingBack.tr,
      ),
      title: Text(
        AppStrings.appTitle.tr,
        style: AppTypography.titleLarge.copyWith(color: onSurface),
      ),
      centerTitle: false,
      actions: [
        StreamBuilder<StreakModel>(
          stream: _viewModel.streak$,
          builder: (context, snap) {
            final streak = snap.data ?? const StreakModel();
            if (streak.currentStreak == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Center(child: StreakBadge(streak: streak)),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert_rounded, color: onSurfaceVariant),
          onPressed: () {},
          tooltip: AppStrings.readingMoreOptions.tr,
        ),
      ],
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
  final VoidCallback onStop;
  final VoidCallback onSpeedDecrease;
  final VoidCallback onSpeedIncrease;

  const _ReadingBody({
    required this.viewModel,
    required this.showVocabBar,
    required this.tappedWord,
    required this.onWordTap,
    required this.onVocabSave,
    required this.onVocabDismiss,
    required this.onPlayPause,
    required this.onStop,
    required this.onSpeedDecrease,
    required this.onSpeedIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final engine = getIt<ReadingEngineService>();

    return StreamBuilder<ReadingState>(
      stream: viewModel.readingState$,
      initialData: engine.state$.value,
      builder: (context, snap) {
        final state = snap.data ?? engine.state$.value;

        return Column(
          children: [
            // ── Three-zone reading display ─────────────────────────────
            Expanded(
              child: ReadingDisplay(engine: engine, onWordTap: onWordTap),
            ),

            // ── Vocabulary highlight bar (conditional) ─────────────────
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
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: (showVocabBar && tappedWord != null)
                  ? VocabHighlight(
                      key: ValueKey('vocab_$tappedWord'),
                      word: tappedWord!,
                      onSave: onVocabSave,
                      onDismiss: onVocabDismiss,
                    )
                  : const SizedBox.shrink(key: ValueKey('vocab_empty')),
            ),

            // ── Controls bar ───────────────────────────────────────────
            ReadingControls(
              state: state,
              onPlayPause: onPlayPause,
              onStop: onStop,
              onSpeedDecrease: onSpeedDecrease,
              onSpeedIncrease: onSpeedIncrease,
            ),
          ],
        );
      },
    );
  }
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

// ── Session summary dialog ────────────────────────────────────────────────────

class _SessionSummaryDialog extends StatelessWidget {
  final ReadingSessionModel? session;
  final VoidCallback onDone;

  const _SessionSummaryDialog({required this.session, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerLowest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final tertiary = isDark ? AppColors.tertiary : AppColors.lightTertiary;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final s = session;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: tertiary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 32,
                color: tertiary,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              AppStrings.readingSessionComplete.tr,
              style: AppTypography.headlineMedium.copyWith(color: onSurface),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              s?.documentTitle ?? AppStrings.readingSessionEnded.tr,
              style: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Stats row
            if (s != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    value: '${s.wordsRead}',
                    label: AppStrings.readingWordsRead.tr,
                    color: primary,
                    onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant,
                  ),
                  _StatItem(
                    value: '${s.averageWpm}',
                    label: AppStrings.readingAvgWpm.tr,
                    color: primary,
                    onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant,
                  ),
                  _StatItem(
                    value: '${s.focusScore.round()}%',
                    label: AppStrings.readingFocus.tr,
                    color: primary,
                    onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Performance label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.xxxxl),
                ),
                child: Text(
                  s.performanceLabel.toUpperCase(),
                  style: AppTypography.label.copyWith(
                    color: primary,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: isDark
                      ? AppColors.onPrimary
                      : AppColors.lightOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppStrings.readingDone.tr,
                  style: AppTypography.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color onSurface;
  final Color onSurfaceVariant;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
    required this.onSurface,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(color: onSurface),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: onSurfaceVariant,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
