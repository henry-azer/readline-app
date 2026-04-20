import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/vocabulary_word_model.dart';

/// Card showing a daily insight or "Word of the Day" from the vocabulary.
///
/// Shows one random word with its context sentence and an encouraging message.
/// Falls back to a static insight tip when no words are available.
class DailyInsightCard extends StatelessWidget {
  final List<VocabularyWordModel> words;

  const DailyInsightCard({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final insight = _resolveInsight(words);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: primary.withValues(alpha: 0.15), width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 14, color: primary),
              const SizedBox(width: 6),
              Text(
                insight.label,
                style: AppTypography.label.copyWith(
                  color: primary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Headline
          Text(
            insight.headline,
            style: AppTypography.headlineMedium.copyWith(
              color: onSurface,
              fontSize: 18,
            ),
          ),

          // Body text
          const SizedBox(height: AppSpacing.xxs),
          Text(
            insight.body,
            style: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
          ),

          // CTA
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () {}, // stub — "coming soon" action
            child: Text(
              insight.ctaLabel,
              style: AppTypography.button.copyWith(
                color: primary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _InsightData _resolveInsight(List<VocabularyWordModel> words) {
    if (words.isEmpty) {
      return _InsightData(
        label: AppStrings.insightDailyLabel.tr,
        headline: AppStrings.insightDailyHeadline.tr,
        body: AppStrings.insightDailyBody.tr,
        ctaLabel: AppStrings.insightDailyCta.tr,
      );
    }

    // Pick a word deterministically based on the day of the year
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    final word = words[dayOfYear % words.length];

    if (word.definition != null && word.definition!.isNotEmpty) {
      return _InsightData(
        label: AppStrings.insightWordOfDayLabel.tr,
        headline: word.word,
        body: word.definition!,
        ctaLabel: AppStrings.insightWordOfDayCta.tr,
      );
    }

    return _InsightData(
      label: AppStrings.insightWordOfDayLabel.tr,
      headline: word.word,
      body: word.contextSentence.isEmpty
          ? AppStrings.insightWordReviewBody.tr
          : '"${word.contextSentence}"',
      ctaLabel: AppStrings.insightWordReviewNowCta.tr,
    );
  }
}

class _InsightData {
  final String label;
  final String headline;
  final String body;
  final String ctaLabel;

  const _InsightData({
    required this.label,
    required this.headline,
    required this.body,
    required this.ctaLabel,
  });
}
