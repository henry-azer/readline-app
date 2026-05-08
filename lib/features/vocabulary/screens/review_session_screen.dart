import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/features/vocabulary/viewmodels/review_session_viewmodel.dart';
import 'package:readline_app/features/vocabulary/widgets/mastery_chip.dart';
import 'package:readline_app/widgets/readline_button.dart';
import 'package:readline_app/widgets/tap_scale.dart';

/// Full-screen flashcard review session.
///
/// - Shows word on front, context + definition on back
/// - "I Know This" (mastered) and "Still Learning" buttons
/// - Progress bar showing position in session
/// - Summary screen at the end
class ReviewSessionScreen extends StatefulWidget {
  const ReviewSessionScreen({super.key});

  @override
  State<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  late final ReviewSessionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ReviewSessionViewModel();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: StreamBuilder<bool>(
          stream: _viewModel.isLoading$,
          builder: (context, loadingSnap) {
            if (loadingSnap.data == true) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDark ? AppColors.primary : AppColors.lightPrimary,
                ),
              );
            }

            return StreamBuilder<bool>(
              stream: _viewModel.isComplete$,
              builder: (context, completeSnap) {
                if (completeSnap.data == true) {
                  return _SummaryView(
                    viewModel: _viewModel,
                    onClose: () => context.pop(),
                  );
                }

                return StreamBuilder<List<VocabularyWordModel>>(
                  stream: _viewModel.words$,
                  builder: (context, wordsSnap) {
                    final words = wordsSnap.data ?? const [];

                    if (words.isEmpty) {
                      return _NoWordsView(
                        isDark: isDark,
                        onSurface: onSurface,
                        onClose: () => context.pop(),
                      );
                    }

                    return _SessionView(viewModel: _viewModel);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Session view (flashcard) ─────────────────────────────────────────────────

class _SessionView extends StatelessWidget {
  final ReviewSessionViewModel viewModel;

  const _SessionView({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return StreamBuilder<int>(
      stream: viewModel.currentIndex$,
      builder: (context, indexSnap) {
        return StreamBuilder<bool>(
          stream: viewModel.isFlipped$,
          builder: (context, flippedSnap) {
            final currentIndex = indexSnap.data ?? 0;
            final isFlipped = flippedSnap.data ?? false;
            final totalWords = viewModel.words.length;
            final word = viewModel.currentWord;

            if (word == null) return const SizedBox.shrink();

            final progress = totalWords > 0 ? currentIndex / totalWords : 0.0;

            return Column(
              children: [
                // Header: back button + title + progress
                _SessionHeader(
                  currentIndex: currentIndex,
                  totalWords: totalWords,
                  progress: progress,
                  isDark: isDark,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                  primary: primary,
                ),

                // Card (flip area)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: _FlashCard(
                      word: word,
                      isFlipped: isFlipped,
                      isDark: isDark,
                      onFlip: viewModel.flipCard,
                    ),
                  ),
                ),

                // Action buttons (only when flipped)
                AnimatedSwitcher(
                  duration: AppDurations.normal,
                  child: isFlipped
                      ? _ActionButtons(
                          key: const ValueKey('actions'),
                          onMastered: viewModel.markMastered,
                          onLearning: viewModel.markLearning,
                          isDark: isDark,
                          primary: primary,
                        )
                      : Padding(
                          key: const ValueKey('flip-hint'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.xxl,
                          ),
                          child: TapScale(
                            onTap: viewModel.flipCard,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceContainerHigh
                                    : AppColors.lightSurfaceContainerHigh,
                                borderRadius: AppRadius.lgBorder,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.touch_app_rounded,
                                    size: 18,
                                    color: onSurfaceVariant,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    AppStrings.reviewTapToReveal.tr,
                                    style: AppTypography.button.copyWith(
                                      color: onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: AppSpacing.md),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Session header ────────────────────────────────────────────────────────────

class _SessionHeader extends StatelessWidget {
  final int currentIndex;
  final int totalWords;
  final double progress;
  final bool isDark;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;

  const _SessionHeader({
    required this.currentIndex,
    required this.totalWords,
    required this.progress,
    required this.isDark,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.close_rounded, color: onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  AppStrings.reviewTitle.tr,
                  style: AppTypography.titleMedium.copyWith(color: onSurface),
                ),
              ),
              Text(
                '${currentIndex + 1} / $totalWords',
                style: AppTypography.labelMedium.copyWith(
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ClipRRect(
              borderRadius: AppRadius.fullBorder,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark
                    ? AppColors.surfaceContainerHigh
                    : AppColors.lightSurfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Flashcard ────────────────────────────────────────────────────────────────

class _FlashCard extends StatelessWidget {
  final VocabularyWordModel word;
  final bool isFlipped;
  final bool isDark;
  final VoidCallback onFlip;

  const _FlashCard({
    required this.word,
    required this.isFlipped,
    required this.isDark,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerLowest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return TapScale(
      onTap: isFlipped ? null : onFlip,
      child: AnimatedSwitcher(
        duration: AppDurations.calm,
        transitionBuilder: (child, animation) {
          final scaleAnimation = TweenSequence<double>([
            TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.97), weight: 50),
            TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.0), weight: 50),
          ]).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: scaleAnimation, child: child),
          );
        },
        child: Container(
          key: ValueKey('card-$isFlipped-${word.id}'),
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadius.lgBorder,
            boxShadow: [
              isDark
                  ? AppColors.darkAmbientShadow(blur: 32, opacity: 0.3)
                  : AppColors.ambientShadow(blur: 16, opacity: 0.07),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isFlipped) ...[
                // Front: just the word
                Text(
                  word.word,
                  style: AppTypography.displayLarge.copyWith(
                    color: onSurface,
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                MasteryChip(masteryLevel: word.masteryLevel),
              ] else ...[
                // Back: definition + context
                Text(
                  word.word,
                  style: AppTypography.titleLarge.copyWith(
                    color: primary,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                if (word.definition != null && word.definition!.isNotEmpty) ...[
                  Text(
                    word.definition!,
                    style: AppTypography.bodyLarge.copyWith(color: onSurface),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                if (word.contextSentence.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceContainer
                          : AppColors.lightSurfaceContainerLow,
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: Text(
                      '"${word.contextSentence}"',
                      style: AppTypography.bodyMedium.copyWith(
                        color: onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],

                Text(
                  word.sourceDocumentTitle,
                  style: AppTypography.label.copyWith(
                    color: onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Action buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final Future<void> Function() onMastered;
  final Future<void> Function() onLearning;
  final bool isDark;
  final Color primary;

  const _ActionButtons({
    super.key,
    required this.onMastered,
    required this.onLearning,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Still Learning
          Expanded(
            child: TapScale(
              onTap: () {
                getIt<HapticService>().light();
                onLearning();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceContainerHigh
                      : AppColors.lightSurfaceContainerHigh,
                  borderRadius: AppRadius.lgBorder,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.tertiary
                          : AppColors.lightTertiary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      AppStrings.reviewStillLearning.tr,
                      style: AppTypography.button.copyWith(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.tertiary
                            : AppColors.lightTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // I Know This (mastered)
          Expanded(
            child: TapScale(
              onTap: () {
                getIt<HapticService>().light();
                onMastered();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? AppColors.primary : AppColors.lightPrimary,
                      isDark
                          ? AppColors.primaryContainer
                          : AppColors.lightPrimaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.lgBorder,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.onPrimary
                          : AppColors.lightOnPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      AppStrings.reviewIKnowThis.tr,
                      style: AppTypography.button.copyWith(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.onPrimary
                            : AppColors.lightOnPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary view ─────────────────────────────────────────────────────────────

class _SummaryView extends StatelessWidget {
  final ReviewSessionViewModel viewModel;
  final VoidCallback onClose;

  const _SummaryView({required this.viewModel, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return StreamBuilder<ReviewSessionResults>(
      stream: viewModel.results$,
      builder: (context, snap) {
        final results = snap.data ?? const ReviewSessionResults();
        final accuracyPct = (results.accuracy * 100).round();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Celebration icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceContainerHigh
                      : AppColors.lightSurfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  results.mastered > 0
                      ? Icons.auto_awesome_rounded
                      : Icons.school_outlined,
                  size: 36,
                  color: primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(
                AppStrings.reviewSessionComplete.tr,
                style: AppTypography.displayMedium.copyWith(color: onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                results.totalReviewed == 0
                    ? AppStrings.reviewNoWordsDue.tr
                    : AppStrings.reviewGreatWork.trParams({
                        'count': '${results.totalReviewed}',
                      }),
                style: AppTypography.bodyMedium.copyWith(
                  color: onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Stats grid
              if (results.totalReviewed > 0) ...[
                _SummaryStatRow(
                  label: AppStrings.reviewLabelReviewed.tr,
                  value: '${results.totalReviewed}',
                  isDark: isDark,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                ),
                _SummaryStatRow(
                  label: AppStrings.reviewLabelMastered.tr,
                  value: '${results.mastered}',
                  isDark: isDark,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                  valueColor: isDark
                      ? AppColors.success
                      : AppColors.lightSuccess,
                ),
                _SummaryStatRow(
                  label: AppStrings.reviewLabelStillLearning.tr,
                  value: '${results.stillLearning}',
                  isDark: isDark,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                  valueColor: isDark
                      ? AppColors.tertiary
                      : AppColors.lightTertiary,
                ),
                _SummaryStatRow(
                  label: AppStrings.reviewLabelAccuracy.tr,
                  value: '$accuracyPct%',
                  isDark: isDark,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                  valueColor: primary,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],

              SizedBox(
                width: double.infinity,
                child: ReadlineButton(
                  label: AppStrings.reviewDone.tr,
                  onTap: onClose,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryStatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color? valueColor;

  const _SummaryStatRow({
    required this.label,
    required this.value,
    required this.isDark,
    required this.onSurface,
    required this.onSurfaceVariant,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
          ),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: valueColor ?? onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── No words view ────────────────────────────────────────────────────────────

class _NoWordsView extends StatelessWidget {
  final bool isDark;
  final Color onSurface;
  final VoidCallback onClose;

  const _NoWordsView({
    required this.isDark,
    required this.onSurface,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 72,
            color: primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppStrings.reviewAllCaughtUp.tr,
            style: AppTypography.displayMedium.copyWith(color: onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.reviewAllCaughtUpBody.tr,
            style: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: ReadlineButton(
              label: AppStrings.reviewGoBack.tr,
              onTap: onClose,
            ),
          ),
        ],
      ),
    );
  }
}
