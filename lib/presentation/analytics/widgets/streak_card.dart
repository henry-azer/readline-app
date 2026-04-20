import 'package:flutter/material.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_gradients.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/streak_model.dart';

class StreakCard extends StatelessWidget {
  final StreakModel streak;

  const StreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final milestone = streak.milestoneLabel;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppGradients.streakLight,
        borderRadius: AppRadius.lgBorder,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Milestone label
          if (milestone != null) ...[
            Text(
              AppStrings.analyticsMomentum.tr,
              style: AppTypography.label.copyWith(
                color: AppColors.white.withValues(alpha: 0.75),
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],

          // Streak count
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${streak.currentStreak}',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: AppStrings.analyticsDays.tr,
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Motivational text
          Text(
            _motivationalText(streak.currentStreak, milestone),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Weekly activity dots
          _WeeklyDots(weeklyActivity: streak.weeklyActivity),
          const SizedBox(height: AppSpacing.md),

          // Longest streak
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
                const SizedBox(width: 6),
                Text(
                  AppStrings.analyticsBestDays.trParams({
                    'n': '${streak.longestStreak}',
                  }),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
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

// ── Weekly dots ──────────────────────────────────────────────────────────────

class _WeeklyDots extends StatelessWidget {
  final List<bool> weeklyActivity;

  const _WeeklyDots({required this.weeklyActivity});

  @override
  Widget build(BuildContext context) {
    final dayLabels = [
      AppStrings.dayMon.tr,
      AppStrings.dayTue.tr,
      AppStrings.dayWed.tr,
      AppStrings.dayThu.tr,
      AppStrings.dayFri.tr,
      AppStrings.daySat.tr,
      AppStrings.daySun.tr,
    ];

    final activity = weeklyActivity.length == 7
        ? weeklyActivity
        : List<bool>.filled(7, false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final isActive = activity[i];
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppColors.white.withValues(alpha: 0.9)
                    : AppColors.white.withValues(alpha: 0.25),
                border: isActive
                    ? null
                    : Border.all(
                        color: AppColors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
              ),
              child: isActive
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.streakGradientStart,
                    )
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              dayLabels[i],
              style: AppTypography.label.copyWith(
                color: AppColors.white.withValues(alpha: 0.65),
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      }),
    );
  }
}
