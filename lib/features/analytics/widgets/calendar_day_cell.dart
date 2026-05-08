import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/calendar_day_stats.dart';

class CalendarDayCell extends StatelessWidget {
  final int day;
  final CalendarDayStats? stats;
  final int dailyGoalMinutes;
  final bool isDark;
  final DateTime date;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.stats,
    required this.dailyGoalMinutes,
    required this.isDark,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isFuture = date.isAfter(DateTime(now.year, now.month, now.day));

    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final success = isDark ? AppColors.success : AppColors.lightSuccess;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    Color bgColor;
    Color textColor;

    if (isFuture) {
      bgColor = AppColors.transparent;
      textColor = onSurfaceVariant.withValues(alpha: 0.3);
    } else if (stats == null || stats!.minutesRead <= 0) {
      bgColor = isDark
          ? AppColors.surfaceContainerHighest.withValues(alpha: 0.5)
          : AppColors.lightSurfaceContainerHighest.withValues(alpha: 0.5);
      textColor = onSurfaceVariant;
    } else if (stats!.targetMet) {
      bgColor = success.withValues(alpha: isDark ? 0.3 : 0.2);
      textColor = success;
    } else {
      bgColor = isDark
          ? AppColors.tertiary.withValues(alpha: 0.2)
          : AppColors.lightTertiary.withValues(alpha: 0.15);
      textColor = isDark
          ? AppColors.tertiary
          : AppColors.lightTertiaryContainer;
    }

    final dayStyle = isToday
        ? AppTypography.analyticsCalendarDayToday
        : AppTypography.analyticsCalendarDay;

    return GestureDetector(
      onTap: isFuture ? null : () => _showDayTooltip(context),
      child: Container(
        height: 40,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.smBorder,
          border: isToday ? Border.all(color: primary, width: 1.5) : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: dayStyle.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }

  void _showDayTooltip(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final tooltipBg = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerLowest;
    final success = isDark ? AppColors.success : AppColors.lightSuccess;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;

    final minutes = stats?.minutesRead ?? 0;
    final sessions = stats?.sessionsCount ?? 0;
    final met = stats?.targetMet ?? false;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + box.size.height,
        position.dx + box.size.width,
        position.dy + box.size.height + 100,
      ),
      color: tooltipBg,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.smBorder),
      items: [
        PopupMenuItem<void>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (minutes > 0) ...[
                Text(
                  AppStrings.analyticsCalendarMinutesRead.trParams({
                    'n': '${minutes.round()}',
                  }),
                  style: AppTypography.analyticsStreakBody.copyWith(
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.micro),
                Text(
                  sessions == 1
                      ? AppStrings.analyticsCalendarSessionsCount.trParams({
                          'n': '$sessions',
                        })
                      : AppStrings.analyticsCalendarSessionsCountPlural
                            .trParams({'n': '$sessions'}),
                  style: AppTypography.analyticsCalendarTooltip.copyWith(
                    color: onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.micro),
                Text(
                  met
                      ? AppStrings.analyticsCalendarTargetMet.tr
                      : AppStrings.analyticsCalendarTargetNotMet.tr,
                  style: AppTypography.analyticsStatLabel.copyWith(
                    color: met ? success : onSurfaceVariant,
                  ),
                ),
              ] else
                Text(
                  AppStrings.analyticsCalendarNoReading.tr,
                  style: AppTypography.bodySmall.copyWith(
                    color: onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
