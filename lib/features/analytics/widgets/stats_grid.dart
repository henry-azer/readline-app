import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/features/analytics/viewmodels/analytics_viewmodel.dart';
import 'package:readline_app/features/analytics/widgets/stat_card.dart';

typedef _Stat = ({
  IconData icon,
  Color accentColor,
  int value,
  String formatted,
  String label,
  String? sublabel,
});

class StatsGrid extends StatelessWidget {
  final AnalyticsTotalStats stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accent = isDark ? AppColors.primary : AppColors.lightPrimary;

    final items = <_Stat>[
      (
        icon: Icons.speed_rounded,
        accentColor: accent,
        value: stats.avgWpm,
        formatted: '${stats.avgWpm}',
        label: AppStrings.analyticsStatAvgSpeed.tr,
        sublabel: AppStrings.analyticsStatAvgSpeedUnit.tr,
      ),
      (
        icon: Icons.timer_outlined,
        accentColor: accent,
        value: stats.avgSessionMinutes.round(),
        formatted: '${stats.avgSessionMinutes.round()}',
        label: AppStrings.analyticsStatAvgTime.tr,
        sublabel: AppStrings.analyticsStatAvgTimeUnit.tr,
      ),
      (
        icon: Icons.schedule_rounded,
        accentColor: accent,
        value: _hoursTarget(stats.totalReadingTimeHours),
        formatted: _formatHours(stats.totalReadingTimeHours),
        label: AppStrings.analyticsStatTotalTime.tr,
        sublabel: AppStrings.analyticsStatTotalTimeUnit.tr,
      ),
      (
        icon: Icons.book_rounded,
        accentColor: accent,
        value: stats.totalSessions,
        formatted: '${stats.totalSessions}',
        label: AppStrings.analyticsStatSessions.tr,
        sublabel: null,
      ),
      (
        icon: Icons.text_snippet_outlined,
        accentColor: accent,
        value: stats.totalWordsRead,
        formatted: _formatWords(stats.totalWordsRead),
        label: AppStrings.analyticsStatWordsRead.tr,
        sublabel: null,
      ),
      (
        icon: Icons.psychology_outlined,
        accentColor: accent,
        value: stats.vocabCount,
        formatted: '${stats.vocabCount}',
        label: AppStrings.analyticsStatVocabWords.tr,
        sublabel: null,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.4,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return StatCard(
          icon: item.icon,
          accentColor: item.accentColor,
          label: item.label,
          targetValue: item.value,
          formattedValue: item.formatted,
          sublabel: item.sublabel,
          isDark: isDark,
        );
      },
    );
  }

  int _hoursTarget(double hours) {
    if (hours < 1) return (hours * 60).round();
    return (hours * 10).round();
  }

  String _formatHours(double hours) {
    if (hours < 1) return '${(hours * 60).round()}m';
    return hours.toStringAsFixed(1);
  }

  String _formatWords(int words) {
    if (words >= 1000000) {
      return '${(words / 1000000).toStringAsFixed(1)}M';
    }
    if (words >= 1000) {
      return '${(words / 1000).toStringAsFixed(1)}k';
    }
    return '$words';
  }
}
