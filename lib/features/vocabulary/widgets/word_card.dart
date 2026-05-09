import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/core/utils/date_formatter.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/features/vocabulary/widgets/difficulty_chip.dart';
import 'package:readline_app/features/vocabulary/widgets/tts_speaker_button.dart';
import 'package:readline_app/features/vocabulary/widgets/word_card_context_quote.dart';
import 'package:readline_app/features/vocabulary/widgets/word_card_source_tag.dart';
import 'package:readline_app/features/vocabulary/widgets/word_card_usage_note.dart';
import 'package:readline_app/widgets/tap_scale.dart';

/// Expandable card showing a vocabulary word with context, source, part-of-
/// speech, difficulty, TTS, and explicit/swipe delete.
class WordCard extends StatelessWidget {
  final VocabularyWordModel word;
  final bool isExpanded;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onDifficultyTap;

  const WordCard({
    super.key,
    required this.word,
    this.isExpanded = false,
    this.onDelete,
    this.onTap,
    this.onDifficultyTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark
        ? AppColors.surfaceContainer
        : AppColors.lightSurfaceContainerLowest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.lgBorder,
          boxShadow: [
            isDark
                ? AppColors.darkAmbientShadow(blur: 16, opacity: 0.25)
                : AppColors.ambientShadow(blur: 8, opacity: 0.06),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.sm,
            bottom: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        word.word,
                        style: AppTypography.vocabWordTitle.copyWith(
                          color: onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (word.partOfSpeech != null &&
                          word.partOfSpeech!.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sxs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: AppRadius.smBorder,
                          ),
                          child: Text(
                            word.partOfSpeech!,
                            style: AppTypography.wordDefBadge.copyWith(
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TtsSpeakerButton(word: word.word),
                      const SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        onTap: onDelete,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxs),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (word.phonetic != null && word.phonetic!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.micro),
                Text(
                  word.phonetic!,
                  style: AppTypography.bodySmall.copyWith(
                    color: onSurfaceVariant,
                  ),
                ),
              ],

              if (word.definition != null && word.definition!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  word.definition!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: onSurfaceVariant,
                  ),
                  maxLines: isExpanded ? null : 2,
                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                ),
              ],

              if (isExpanded &&
                  word.exampleSentence != null &&
                  word.exampleSentence!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.only(left: AppSpacing.smd),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: primary.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    AppStrings.generalQuoted.trParams({
                      'text': word.exampleSentence!,
                    }),
                    style: AppTypography.bodySmall.copyWith(
                      color: onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              if (word.contextSentence.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                WordCardContextQuote(
                  sentence: word.contextSentence,
                  word: word.word,
                  isDark: isDark,
                ),
              ],

              if (word.usageNote != null && word.usageNote!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                WordCardUsageNote(note: word.usageNote!, isDark: isDark),
              ],

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  WordCardSourceTag(
                    label: word.sourceDocumentTitle,
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    DateFormatter.relative(word.addedAt),
                    style: AppTypography.vocabDateMeta.copyWith(
                      color: onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  DifficultyChip(
                    difficulty: word.difficulty,
                    onTap: onDifficultyTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
