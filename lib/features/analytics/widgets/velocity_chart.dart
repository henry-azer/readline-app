import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
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

class VelocityChart extends StatefulWidget {
  final VelocityChartData data;

  const VelocityChart({super.key, required this.data});

  @override
  State<VelocityChart> createState() => _VelocityChartState();
}

class _VelocityChartState extends State<VelocityChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: AppDurations.slow, vsync: this);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark
        ? AppColors.surfaceContainer
        : AppColors.lightSurfaceContainerLowest;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final trend = widget.data.trendPercent;
    final trendLabel = _trendLabel(trend);
    final trendColor = trend > 0
        ? (isDark ? AppColors.success : AppColors.lightSuccess)
        : trend < 0
        ? (isDark ? AppColors.error : AppColors.lightError)
        : onSurfaceVariant;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: Transform.translate(
          offset: Offset(0, AppSpacing.sm * (1 - _animation.value)),
          child: child,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.lgBorder,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trend label
            if (widget.data.days.any((d) => d.avgWpm > 0))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(
                      trend > 0
                          ? Icons.trending_up_rounded
                          : trend < 0
                          ? Icons.trending_down_rounded
                          : Icons.trending_flat_rounded,
                      size: 16,
                      color: trendColor,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        trendLabel,
                        style: AppTypography.analyticsTrendLabel.copyWith(
                          color: trendColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Line chart
            SizedBox(
              height: 160,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) => _buildChart(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    final days = widget.data.days;
    final movingAvg = widget.data.movingAverage;

    if (days.isEmpty) return const SizedBox.shrink();

    final allWpm = days.map((d) => d.avgWpm).toList();
    final maxWpm = [
      ...allWpm,
      ...movingAvg,
    ].where((v) => v > 0).fold(300.0, math.max);
    final maxY = maxWpm * 1.15;

    final lineColor = isDark ? AppColors.primary : AppColors.lightPrimary;
    final trendColor = widget.data.trendPercent >= 0
        ? (isDark ? AppColors.success : AppColors.lightSuccess)
        : (isDark ? AppColors.error : AppColors.lightError);
    final gridColor = isDark
        ? AppColors.onSurfaceVariant.withValues(alpha: 0.12)
        : AppColors.lightOutlineVariant.withValues(alpha: 0.4);
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final gradientColors = [
      lineColor.withValues(alpha: 0.3),
      lineColor.withValues(alpha: 0.0),
    ];

    // Build spots for daily WPM (only non-zero)
    final dailySpots = <FlSpot>[];
    for (int i = 0; i < days.length; i++) {
      final wpm = days[i].avgWpm * _animation.value;
      dailySpots.add(FlSpot(i.toDouble(), wpm));
    }

    // Build spots for moving average
    final maSpots = <FlSpot>[];
    for (int i = 0; i < movingAvg.length; i++) {
      final wpm = movingAvg[i] * _animation.value;
      maSpots.add(FlSpot(i.toDouble(), wpm));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => isDark
                ? AppColors.surfaceContainerHighest
                : AppColors.lightSurfaceContainerLowest,
            tooltipRoundedRadius: AppRadius.sm,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                if (spot.barIndex == 0) {
                  final idx = spot.spotIndex;
                  if (idx < days.length) {
                    final day = days[idx];
                    final dateStr = '${day.date.day}/${day.date.month}';
                    return LineTooltipItem(
                      AppStrings.analyticsWpmOnDate.trParams({
                        'wpm': '${day.avgWpm.round()}',
                        'date': dateStr,
                      }),
                      AppTypography.analyticsStatLabel.copyWith(
                        color: isDark
                            ? AppColors.onSurface
                            : AppColors.lightOnSurface,
                      ),
                    );
                  }
                }
                if (spot.barIndex == 1) {
                  return LineTooltipItem(
                    '${AppStrings.analyticsTrendLine.tr}: ${spot.y.round()} WPM',
                    AppTypography.analyticsStatLabel.copyWith(
                      color: trendColor,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                if (value == meta.max || value == meta.min) {
                  return const SizedBox.shrink();
                }
                return Text(
                  '${value.round()}',
                  style: AppTypography.analyticsAxisTick.copyWith(
                    color: onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              interval: 7,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= days.length) {
                  return const SizedBox.shrink();
                }
                if (idx % 7 != 0 && idx != days.length - 1) {
                  return const SizedBox.shrink();
                }
                final day = days[idx];
                return Text(
                  '${day.date.day}/${day.date.month}',
                  style: AppTypography.analyticsAxisTick.copyWith(
                    color: onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: gridColor, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Daily WPM line
          LineChartBarData(
            spots: dailySpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: lineColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: lineColor,
                  strokeWidth: 2,
                  strokeColor: isDark
                      ? AppColors.surfaceContainerHigh
                      : AppColors.lightSurfaceContainerLowest,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 7-day moving average trend line
          if (maSpots.isNotEmpty)
            LineChartBarData(
              spots: maSpots,
              isCurved: true,
              curveSmoothness: 0.4,
              color: trendColor.withValues(alpha: 0.7),
              barWidth: 2,
              isStrokeCapRound: true,
              dashArray: [6, 3],
              dotData: const FlDotData(show: false),
            ),
        ],
      ),
      duration: AppDurations.normal,
    );
  }

  String _trendLabel(double trend) {
    if (trend.abs() < 1) return AppStrings.analyticsSpeedSteady.tr;
    if (trend > 0) {
      return AppStrings.analyticsSpeedIncreased.trParams({
        'pct': '${trend.abs().round()}',
      });
    }
    return AppStrings.analyticsSpeedDecreased.trParams({
      'pct': '${trend.abs().round()}',
    });
  }
}
