import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class WeeklyDots extends StatelessWidget {
  final List<bool> weeklyActivity;

  const WeeklyDots({super.key, required this.weeklyActivity});

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
              duration: AppDurations.normal,
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
                      color: AppColors.lightPrimary,
                    )
                  : null,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              dayLabels[i],
              style: AppTypography.analyticsCompactLabel.copyWith(
                color: AppColors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        );
      }),
    );
  }
}
