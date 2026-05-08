import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/data/models/calendar_day_stats.dart';
import 'package:readline_app/features/analytics/widgets/calendar_day_cell.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime displayedMonth;
  final Map<String, CalendarDayStats> calendarData;
  final int dailyGoalMinutes;
  final bool isDark;

  const CalendarGrid({
    super.key,
    required this.displayedMonth,
    required this.calendarData,
    required this.dailyGoalMinutes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final lastDay = DateTime(displayedMonth.year, displayedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;

    final startWeekday = firstDay.weekday;
    final leadingBlanks = startWeekday - 1;
    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: EdgeInsets.only(bottom: row < rows - 1 ? AppSpacing.xxs : 0),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - leadingBlanks + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }

              final date = DateTime(
                displayedMonth.year,
                displayedMonth.month,
                dayNum,
              );
              final key = _dateKey(date);
              final stats = calendarData[key];

              return Expanded(
                child: CalendarDayCell(
                  day: dayNum,
                  stats: stats,
                  dailyGoalMinutes: dailyGoalMinutes,
                  isDark: isDark,
                  date: date,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
