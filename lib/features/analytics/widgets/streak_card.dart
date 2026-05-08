import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_gradients.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/streak_model.dart';
import 'package:readline_app/features/analytics/widgets/weekly_dots.dart';

class StreakCard extends StatelessWidget {
  final StreakModel streak;

  const StreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final milestone = streak.milestoneLabel;
    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppGradients.streak(isDark),
        borderRadius: AppRadius.lgBorder,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (milestone != null) ...[
            Text(
              AppStrings.analyticsMomentum.tr,
              style: AppTypography.analyticsEyebrow.copyWith(
                color: AppColors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${streak.currentStreak}',
                  style: AppTypography.analyticsHeroNumber.copyWith(
                    color: AppColors.white,
                  ),
                ),
                TextSpan(
                  text: AppStrings.analyticsDays.tr,
                  style: AppTypography.analyticsHeroUnit.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          Text(
            _motivationalText(streak.currentStreak, milestone),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          WeeklyDots(weeklyActivity: streak.weeklyActivity),
          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              borderRadius: AppRadius.smBorder,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  size: 14,
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
                const SizedBox(width: AppSpacing.sxs),
                Text(
                  AppStrings.analyticsBestDays.trParams({
                    'n': '${streak.longestStreak}',
                  }),
                  style: AppTypography.analyticsStreakBody.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _motivationalText(int streak, String? milestone) {
    if (streak == 0) return AppStrings.streakStartJourney.tr;
    if (streak == 1) return AppStrings.streakDayOne.tr;
    if (milestone == 'on fire') return AppStrings.streakOnFire.tr;
    if (milestone == 'unstoppable') return AppStrings.streakUnstoppable.tr;
    if (milestone == 'legendary') return AppStrings.streakLegendary.tr;
    if (milestone == 'archivist') return AppStrings.streakArchivist.tr;
    if (streak < 7) return AppStrings.streakBuilding.tr;
    return AppStrings.streakImpressive.tr;
  }
}
