import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class CalendarDayOfWeekHeader extends StatelessWidget {
  final bool isDark;

  const CalendarDayOfWeekHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final labels = [
      AppStrings.dayMon.tr,
      AppStrings.dayTue.tr,
      AppStrings.dayWed.tr,
      AppStrings.dayThu.tr,
      AppStrings.dayFri.tr,
      AppStrings.daySat.tr,
      AppStrings.daySun.tr,
    ];

    return Row(
      children: labels.map((l) {
        return Expanded(
          child: Center(
            child: Text(
              l.isNotEmpty ? l[0] : '',
              style: AppTypography.analyticsCalendarDow.copyWith(color: color),
            ),
          ),
        );
      }).toList(),
    );
  }
}
