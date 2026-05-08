import 'package:flutter/material.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/services/tts_service.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/features/vocabulary/widgets/difficulty_chip.dart';
import 'package:readline_app/features/vocabulary/widgets/mastery_chip.dart';
import 'package:readline_app/widgets/tap_scale.dart';

/// Expandable card showing a vocabulary word with context, source, mastery chip,
/// difficulty badge, bookmark toggle, TTS, and swipe-to-delete.
class WordCard extends StatelessWidget {
  final VocabularyWordModel word;
  final bool isExpanded;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onDifficultyTap;

  const WordCard({
    super.key,
    required this.word,
    this.isExpanded = false,
    this.onBookmarkToggle,
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
    final errorColor = isDark ? AppColors.error : AppColors.lightError;

    final card = TapScale(
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source document tag + bookmark
              Row(
                children: [
                  _SourceTag(label: word.sourceDocumentTitle, isDark: isDark),
                  const Spacer(),
                  GestureDetector(
                    onTap: onBookmarkToggle,
                    child: Icon(
                      word.isBookmarked
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 20,
                      color: word.isBookmarked
                          ? (isDark
                                ? AppColors.tertiary
                                : AppColors.lightTertiary)
                          : onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),

              // Word + phonetic
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.word,
                          style: AppTypography.headlineLarge.copyWith(
                            color: onSurface,
                            fontSize: 26,
                          ),
                        ),
                        if (word.phonetic != null &&
                            word.phonetic!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.micro),
                          Text(
                            word.phonetic!,
                            style: AppTypography.bodySmall.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // TTS speaker icon
                  _TtsSpeakerButton(word: word.word),
                ],
              ),

              // Definition (truncated when collapsed)
              if (word.definition != null && word.definition!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  word.definition!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: onSurfaceVariant,
                  ),
                  maxLines: isExpanded ? null : 2,
                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                ),
              ],

              // Expanded content
              if (isExpanded) ...[
                // Part of speech
                if (word.partOfSpeech != null &&
                    word.partOfSpeech!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
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
                      style: AppTypography.label.copyWith(
                        color: primary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],

                // Example sentence
                if (word.exampleSentence != null &&
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
                      '"${word.exampleSentence!}"',
                      style: AppTypography.bodySmall.copyWith(
                        color: onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],

              // Context sentence
              if (word.contextSentence.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                _ContextQuote(
                  sentence: word.contextSentence,
                  word: word.word,
                  isDark: isDark,
                ),
              ],

              // Usage note (marginalia)
              if (word.usageNote != null && word.usageNote!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                _UsageNote(note: word.usageNote!, isDark: isDark),
              ],

              const SizedBox(height: AppSpacing.sm),

              // Footer: date + difficulty + mastery chip
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    _formatDate(word.addedAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  DifficultyChip(
                    difficulty: word.difficulty,
                    onTap: onDifficultyTap,
                  ),
                  const Spacer(),
                  MasteryChip(masteryLevel: word.masteryLevel),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with Dismissible for swipe-to-delete
    if (onDelete != null) {
      return Dismissible(
        key: ValueKey('dismiss_${word.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete!(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          decoration: BoxDecoration(
            color: errorColor,
            borderRadius: AppRadius.lgBorder,
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.white,
            size: 24,
          ),
        ),
        child: card,
      );
    }

    return card;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return AppStrings.todayUpper.tr;
    if (diff.inDays == 1) return AppStrings.oneDayAgo.tr;
    if (diff.inDays < 30) {
      return AppStrings.daysAgoUpper.trParams({'n': '${diff.inDays}'});
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).round();
      return months > 1
          ? AppStrings.monthsAgoUpper.trParams({'n': '$months'})
          : AppStrings.monthAgo.trParams({'n': '$months'});
    }
    return AppStrings.longAgo.tr;
  }
}

// ── TTS speaker button ─────────────────────────────────────────────────────────

class _TtsSpeakerButton extends StatelessWidget {
  final String word;

  const _TtsSpeakerButton({required this.word});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final ttsService = getIt<TtsService>();

    return StreamBuilder<String?>(
      stream: ttsService.currentWord$,
      builder: (context, snap) {
        final playingWord = snap.data;
        final isThisWordPlaying = playingWord == word;
        return GestureDetector(
          onTap: () => ttsService.speak(word),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            child: Icon(
              isThisWordPlaying
                  ? Icons.volume_up_rounded
                  : Icons.volume_up_outlined,
              size: 20,
              color: isThisWordPlaying ? primary : onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}

// ── Source tag chip ──────────────────────────────────────────────────────────

class _SourceTag extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SourceTag({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final text = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final displayLabel = label.length > 20
        ? '${label.substring(0, 18).toUpperCase()}...'
        : label.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.xsBorder),
      child: Text(
        displayLabel,
        style: AppTypography.label.copyWith(color: text, fontSize: 9),
      ),
    );
  }
}

// ── Context quote ────────────────────────────────────────────────────────────

class _ContextQuote extends StatelessWidget {
  final String sentence;
  final String word;
  final bool isDark;

  const _ContextQuote({
    required this.sentence,
    required this.word,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final textColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final lower = sentence.toLowerCase();
    final wordLower = word.toLowerCase();
    final idx = lower.indexOf(wordLower);

    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: primary.withValues(alpha: 0.4), width: 2),
        ),
      ),
      child: idx == -1
          ? Text(
              '"$sentence"',
              style: AppTypography.bodySmall.copyWith(
                color: textColor,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          : RichText(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: AppTypography.bodySmall.copyWith(
                  color: textColor,
                  fontStyle: FontStyle.italic,
                ),
                children: [
                  TextSpan(text: '"${sentence.substring(0, idx)}'),
                  TextSpan(
                    text: sentence.substring(idx, idx + word.length),
                    style: AppTypography.bodySmall.copyWith(
                      color: primary,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: '${sentence.substring(idx + word.length)}"'),
                ],
              ),
            ),
    );
  }
}

// ── Usage note (marginalia) ──────────────────────────────────────────────────

class _UsageNote extends StatelessWidget {
  final String note;
  final bool isDark;

  const _UsageNote({required this.note, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? AppColors.surfaceContainerHigh.withValues(alpha: 0.5)
        : AppColors.lightSurfaceContainerLow;
    final textColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.smBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.wordCardMarginalia.tr,
            style: AppTypography.label.copyWith(
              color: textColor.withValues(alpha: 0.4),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: AppSpacing.micro),
          Text(
            note,
            style: AppTypography.bodySmall.copyWith(color: textColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
