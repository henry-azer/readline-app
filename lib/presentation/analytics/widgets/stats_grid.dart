import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/analytics/viewmodels/analytics_viewmodel.dart';

class StatsGrid extends StatelessWidget {
  final AnalyticsTotalStats stats;
  final int currentStreak;
  final int longestStreak;

  const StatsGrid({
    super.key,
    required this.stats,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final items = [
      _StatItem(
        icon: Icons.schedule_rounded,
        value: _formatHours(stats.totalReadingTimeHours),
        label: AppStrings.analyticsStatTotalTime.tr,
        sublabel: AppStrings.analyticsStatTotalTimeUnit.tr,
      ),
      _StatItem(
        icon: Icons.text_snippet_outlined,
        value: _formatWords(stats.totalWordsRead),
        label: AppStrings.analyticsStatWordsRead.tr,
      ),
      _StatItem(
        icon: Icons.speed_rounded,
        value: '${stats.avgWpm}',
        label: AppStrings.analyticsStatAvgSpeed.tr,
        sublabel: AppStrings.analyticsStatAvgSpeedUnit.tr,
      ),
      _StatItem(
        icon: Icons.book_rounded,
        value: '${stats.totalSessions}',
        label: AppStrings.analyticsStatSessions.tr,
      ),
      _StatItem(
        icon: Icons.psychology_outlined,
        value: '${stats.vocabCount}',
        label: AppStrings.analyticsStatVocabWords.tr,
      ),
      _StatItem(
        icon: Icons.center_focus_strong_rounded,
        value: '${stats.avgFocusScore.round()}%',
        label: AppStrings.analyticsStatFocusScore.tr,
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
      itemBuilder: (context, i) => _StatCard(item: items[i], isDark: isDark),
    );
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

// ── Stat item data ────────────────────────────────────────────────────────────

class _StatItem {
  final IconData icon;
  final String value;
  final String label;
  final String? sublabel;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.sublabel,
  });
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final _StatItem item;
  final bool isDark;

  const _StatCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerLowest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final iconColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.lgBorder,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Icon(item.icon, size: 20, color: iconColor),

          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                item.value,
                style: AppTypography.displayMedium.copyWith(
                  color: onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (item.sublabel != null) ...[
                const SizedBox(width: 3),
                Text(
                  item.sublabel!,
                  style: AppTypography.bodySmall.copyWith(
                    color: onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),

          // Label
          Text(
            item.label.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: onSurfaceVariant,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
