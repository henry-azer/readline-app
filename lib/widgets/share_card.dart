import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/core/utils/date_formatter.dart';
import 'package:readline_app/data/models/celebration_data.dart';

class ShareCard extends StatelessWidget {
  final CelebrationData celebration;
  final GlobalKey repaintKey;

  const ShareCard({
    super.key,
    required this.celebration,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return RepaintBoundary(
      key: repaintKey,
      child: SizedBox(
        width: 1080,
        height: 1080,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.surface, AppColors.surfaceContainerHigh]
                  : [AppColors.lightSurface, AppColors.lightSurfaceContainer],
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.xxxxl * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo area
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 40,
                    color: isDark ? AppColors.primary : AppColors.lightPrimary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    AppStrings.generalAppName.tr,
                    style: AppTypography.shareCardBrand.copyWith(
                      color: isDark
                          ? AppColors.primary
                          : AppColors.lightPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxxl),

              // Achievement icon
              Icon(
                _iconForType(celebration.type),
                size: 80,
                color: isDark ? AppColors.tertiary : AppColors.lightTertiary,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Metric value
              Text(
                _metricValue(celebration),
                style: AppTypography.shareCardMetric.copyWith(
                  color: isDark
                      ? AppColors.onSurface
                      : AppColors.lightOnSurface,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Achievement label
              Text(
                _metricLabel(celebration),
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariant
                      : AppColors.lightOnSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxxl),

              // Date
              Text(
                DateFormatter.compact(DateTime.now()),
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariant
                      : AppColors.lightOnSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Tagline
              Text(
                AppStrings.splashTagline.tr,
                style: AppTypography.shareCardTagline.copyWith(
                  color: isDark ? AppColors.primary : AppColors.lightPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(CelebrationType type) {
    return switch (type) {
      CelebrationType.streakMilestone => Icons.local_fire_department_rounded,
      CelebrationType.dailyTarget => Icons.check_circle_rounded,
      CelebrationType.wordsMilestone => Icons.menu_book_rounded,
    };
  }

  String _metricValue(CelebrationData c) {
    return switch (c.type) {
      CelebrationType.streakMilestone => '${c.streakCount}',
      CelebrationType.dailyTarget => '${c.minutesRead.round()}',
      CelebrationType.wordsMilestone => _formatWords(c.wordsCount),
    };
  }

  String _metricLabel(CelebrationData c) {
    return switch (c.type) {
      CelebrationType.streakMilestone => AppStrings.homeStreakDays.trParams({
        'n': '${c.streakCount}',
      }),
      CelebrationType.dailyTarget => AppStrings.celebrationDailyTargetTitle.tr,
      CelebrationType.wordsMilestone =>
        AppStrings.celebrationWordsTitle.trParams({
          'n': _formatWords(c.wordsCount),
        }),
    };
  }

  String _formatWords(int count) {
    if (count >= 1000) return '${(count / 1000).round()}K';
    return '$count';
  }
}
