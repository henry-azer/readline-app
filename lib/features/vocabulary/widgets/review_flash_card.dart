import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/features/vocabulary/widgets/mastery_chip.dart';
import 'package:readline_app/widgets/tap_scale.dart';

/// Front/back flashcard for the review session. Front shows the word; back
/// shows the definition, context sentence, and source.
class ReviewFlashCard extends StatelessWidget {
  final VocabularyWordModel word;
  final bool isFlipped;
  final VoidCallback onFlip;

  const ReviewFlashCard({
    super.key,
    required this.word,
    required this.isFlipped,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
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
                Text(
                  word.word,
                  style: AppTypography.vocabFlashcardWord.copyWith(
                    color: onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                MasteryChip(masteryLevel: word.masteryLevel),
              ] else ...[
                Text(
                  word.word,
                  style: AppTypography.vocabFlashcardWordBack.copyWith(
                    color: primary,
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
                      AppStrings.generalQuoted.trParams({
                        'text': word.contextSentence,
                      }),
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
                  style: AppTypography.vocabFlashcardSourceHint.copyWith(
                    color: onSurfaceVariant.withValues(alpha: 0.6),
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
