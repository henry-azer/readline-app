import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/calendar_day_stats.dart';
import 'package:readline_app/features/analytics/widgets/calendar_day_of_week_header.dart';
import 'package:readline_app/features/analytics/widgets/calendar_grid.dart';

class StreakCalendar extends StatelessWidget {
  final DateTime displayedMonth;
  final Map<String, CalendarDayStats> calendarData;
  final int dailyGoalMinutes;
  final ValueChanged<int> onChangeMonth;

  const StreakCalendar({
    super.key,
    required this.displayedMonth,
    required this.calendarData,
    required this.dailyGoalMinutes,
    required this.onChangeMonth,
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

    final monthName = _monthName(displayedMonth.month);
    final year = displayedMonth.year;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: onSurfaceVariant,
                  size: 22,
                ),
                onPressed: () => onChangeMonth(-1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Text(
                '$monthName $year',
                style: AppTypography.analyticsStreakBody.copyWith(
                  color: onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: onSurfaceVariant,
                  size: 22,
                ),
                onPressed: () => onChangeMonth(1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          CalendarDayOfWeekHeader(isDark: isDark),
          const SizedBox(height: AppSpacing.xs),

          CalendarGrid(
            displayedMonth: displayedMonth,
            calendarData: calendarData,
            dailyGoalMinutes: dailyGoalMinutes,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const keys = [
      AppStrings.monthJan,
      AppStrings.monthFeb,
      AppStrings.monthMar,
      AppStrings.monthApr,
      AppStrings.monthMay,
      AppStrings.monthJun,
      AppStrings.monthJul,
      AppStrings.monthAug,
      AppStrings.monthSep,
      AppStrings.monthOct,
      AppStrings.monthNov,
      AppStrings.monthDec,
    ];
    return keys[month - 1].tr;
  }
}
