import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/vocabulary_word_model.dart';
import 'package:read_it/presentation/vocabulary/widgets/mastery_chip.dart';
import 'package:read_it/presentation/widgets/tap_scale.dart';

/// Card showing a vocabulary word with context, source, mastery chip,
/// bookmark toggle, and delete on long press.
class WordCard extends StatelessWidget {
  final VocabularyWordModel word;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const WordCard({
    super.key,
    required this.word,
    this.onBookmarkToggle,
    this.onDelete,
    this.onTap,
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
      onLongPress: onDelete != null
          ? () => _showDeleteConfirm(context, isDark)
          : null,
      child: Container(
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

              // Word
              Text(
                word.word,
                style: AppTypography.headlineLarge.copyWith(
                  color: onSurface,
                  fontSize: 26,
                ),
              ),

              // Definition (if present)
              if (word.definition != null && word.definition!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  word.definition!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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

              // Footer: date + mastery chip
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(word.addedAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.menu_book_outlined,
                    size: 12,
                    color: onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      word.sourceDocumentTitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: primary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  MasteryChip(masteryLevel: word.masteryLevel),
                ],
              ),

              // Swipe hint
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.wordCardLongPressDelete.tr,
                style: AppTypography.label.copyWith(
                  color: onSurfaceVariant.withValues(alpha: 0.4),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, bool isDark) {
    showDialog<bool>(
      context: context,
      builder: (ctx) {
        final surfaceBg = isDark
            ? AppColors.surfaceContainerHigh
            : AppColors.lightSurface;
        final onSurf = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
        return AlertDialog(
          backgroundColor: surfaceBg,
          title: Text(
            AppStrings.wordCardRemoveTitle.tr,
            style: AppTypography.headlineMedium.copyWith(color: onSurf),
          ),
          content: Text(
            AppStrings.wordCardRemoveBody.trParams({'word': word.word}),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.onSurfaceVariant
                  : AppColors.lightOnSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                AppStrings.cancel.tr,
                style: AppTypography.button.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariant
                      : AppColors.lightOnSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(true);
                onDelete?.call();
              },
              child: Text(
                AppStrings.remove.tr,
                style: AppTypography.button.copyWith(
                  color: isDark ? AppColors.error : AppColors.lightError,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
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

    // Truncate to a filename-like format
    final displayLabel = label.length > 20
        ? '${label.substring(0, 18).toUpperCase()}...'
        : label.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
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

    // Build rich text with the word highlighted
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.wordCardMarginalia.tr,
            style: AppTypography.label.copyWith(
              color: textColor.withValues(alpha: 0.6),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
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
