import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/analytics/viewmodels/analytics_viewmodel.dart';

class WeekAtAGlance extends StatelessWidget {
  final List<WeekDayProgress> weekProgress;
  final bool isDark;

  const WeekAtAGlance({
    super.key,
    required this.weekProgress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final success = isDark ? AppColors.success : AppColors.lightSuccess;
    final trackColor = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerHighest;

    final dayLabels = [
      AppStrings.dayMon.tr,
      AppStrings.dayTue.tr,
      AppStrings.dayWed.tr,
      AppStrings.dayThu.tr,
      AppStrings.dayFri.tr,
      AppStrings.daySat.tr,
      AppStrings.daySun.tr,
    ];

    final items = weekProgress.isEmpty
        ? List.generate(7, (_) => WeekDayProgress(date: DateTime(2000, 1, 1)))
        : weekProgress;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final day = i < items.length ? items[i] : null;
        final met = day?.targetMet ?? false;
        final hasReading = (day?.minutesRead ?? 0) > 0;

        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: met
                    ? success
                    : hasReading
                    ? success.withValues(alpha: 0.3)
                    : trackColor,
                border: !met && !hasReading
                    ? Border.all(
                        color: onSurfaceVariant.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: met
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.surface
                          : AppColors.lightSurface,
                    )
                  : null,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              dayLabels[i],
              style: AppTypography.analyticsCompactLabel.copyWith(
                color: onSurfaceVariant,
              ),
            ),
          ],
        );
      }),
    );
  }
}
