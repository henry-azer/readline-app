import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/analytics/viewmodels/analytics_viewmodel.dart';
import 'package:readline_app/features/analytics/widgets/week_at_a_glance.dart';
import 'package:readline_app/widgets/progress_ring_painter.dart';

class DailyProgressSection extends StatelessWidget {
  final double todayMinutes;
  final int dailyGoalMinutes;
  final List<WeekDayProgress> weekProgress;

  const DailyProgressSection({
    super.key,
    required this.todayMinutes,
    required this.dailyGoalMinutes,
    required this.weekProgress,
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
    final success = isDark ? AppColors.success : AppColors.lightSuccess;
    final trackColor = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerHighest;

    final progress = dailyGoalMinutes > 0
        ? (todayMinutes / dailyGoalMinutes).clamp(0.0, 1.0)
        : 0.0;
    final goalMet = todayMinutes >= dailyGoalMinutes;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.lgBorder,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: AppDurations.reveal,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CustomPaint(
                      painter: ProgressRingPainter(
                        progress: value,
                        ringColor: goalMet ? success : primary,
                        trackColor: trackColor,
                        strokeWidth: 5,
                      ),
                      child: Center(
                        child: TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: todayMinutes.round()),
                          duration: AppDurations.reveal,
                          builder: (context, val, _) {
                            return Text(
                              '$val',
                              style: AppTypography.analyticsRingCenter.copyWith(
                                color: onSurface,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.analyticsMinutesReadToday.trParams({
                        'n': '${todayMinutes.round()}',
                      }),
                      style: AppTypography.analyticsRingLabel.copyWith(
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.micro),
                    Text(
                      AppStrings.homeGoalProgress.trParams({
                        'current': '${todayMinutes.round()}',
                        'target': '$dailyGoalMinutes',
                      }),
                      style: AppTypography.bodySmall.copyWith(
                        color: onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: goalMet
                            ? success.withValues(alpha: isDark ? 0.2 : 0.12)
                            : primary.withValues(alpha: isDark ? 0.15 : 0.1),
                        borderRadius: AppRadius.smBorder,
                      ),
                      child: Text(
                        goalMet
                            ? AppStrings.analyticsGoalMetLabel.tr
                            : AppStrings.analyticsGoalNotMetLabel.tr,
                        style: AppTypography.analyticsWeeklyValue.copyWith(
                          color: goalMet ? success : primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          WeekAtAGlance(weekProgress: weekProgress, isDark: isDark),
        ],
      ),
    );
  }
}
