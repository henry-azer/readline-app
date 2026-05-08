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
import 'package:readline_app/features/analytics/widgets/period_chips.dart';

class ReadingVolumeChart extends StatefulWidget {
  final VolumeChartData data;
  final VolumePeriod selectedPeriod;
  final ValueChanged<VolumePeriod> onPeriodChanged;

  const ReadingVolumeChart({
    super.key,
    required this.data,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  State<ReadingVolumeChart> createState() => _ReadingVolumeChartState();
}

class _ReadingVolumeChartState extends State<ReadingVolumeChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  int? _touchedIndex;

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
  void didUpdateWidget(ReadingVolumeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      _controller.reset();
      _controller.forward();
    }
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
            // Period toggle chips
            PeriodChips(
              selectedPeriod: widget.selectedPeriod,
              onPeriodChanged: widget.onPeriodChanged,
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.md),

            // Bar chart
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
    if (days.isEmpty) return const SizedBox.shrink();

    final maxWords = days.map((d) => d.wordsRead).fold(0, math.max);
    final effectiveMax = maxWords == 0 ? 1000.0 : maxWords.toDouble();
    final maxY = effectiveMax * 1.15;

    final barColor = isDark ? AppColors.primary : AppColors.lightPrimary;
    final gridColor = isDark
        ? AppColors.onSurfaceVariant.withValues(alpha: 0.12)
        : AppColors.lightOutlineVariant.withValues(alpha: 0.4);
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final avgLineColor = onSurfaceVariant.withValues(alpha: 0.5);
    final targetLineColor = isDark
        ? AppColors.success.withValues(alpha: 0.6)
        : AppColors.lightSuccess.withValues(alpha: 0.6);

    // For large datasets, downsample to max 30 bars
    final displayDays = days.length > 30 ? _downsample(days, 30) : days;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => isDark
                ? AppColors.surfaceContainerHighest
                : AppColors.lightSurfaceContainerLowest,
            tooltipRoundedRadius: AppRadius.sm,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex >= displayDays.length) return null;
              final day = displayDays[groupIndex];
              final dateStr = '${day.date.day}/${day.date.month}';
              return BarTooltipItem(
                AppStrings.analyticsWordsOnDate.trParams({
                  'words': _formatWords(day.wordsRead),
                  'date': dateStr,
                }),
                AppTypography.analyticsStatLabel.copyWith(
                  color: isDark
                      ? AppColors.onSurface
                      : AppColors.lightOnSurface,
                ),
              );
            },
          ),
          touchCallback: (event, response) {
            setState(() {
              _touchedIndex = response?.spot?.touchedBarGroupIndex;
            });
          },
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
                  _formatWords(value.round()),
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
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= displayDays.length) {
                  return const SizedBox.shrink();
                }
                // Show limited labels to avoid crowding
                final step = _labelStep(displayDays.length);
                if (idx % step != 0 && idx != displayDays.length - 1) {
                  return const SizedBox.shrink();
                }
                final day = displayDays[idx];
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
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            // Average line
            if (widget.data.averageWords > 0)
              HorizontalLine(
                y: widget.data.averageWords.toDouble(),
                color: avgLineColor,
                strokeWidth: 1,
                dashArray: [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: AppTypography.analyticsAxisTick.copyWith(
                    color: onSurfaceVariant,
                  ),
                  labelResolver: (_) => AppStrings.analyticsAvgWordsPerDay
                      .trParams({'n': _formatWords(widget.data.averageWords)}),
                ),
              ),
            // Daily target line
            if (widget.data.dailyTargetWords > 0)
              HorizontalLine(
                y: widget.data.dailyTargetWords.toDouble(),
                color: targetLineColor,
                strokeWidth: 1,
                dashArray: [6, 3],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topLeft,
                  style: AppTypography.analyticsAxisTick.copyWith(
                    color: targetLineColor,
                  ),
                  labelResolver: (_) => AppStrings.analyticsDailyTargetLine.tr,
                ),
              ),
          ],
        ),
        barGroups: displayDays.asMap().entries.map((entry) {
          final i = entry.key;
          final day = entry.value;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: day.wordsRead.toDouble() * _animation.value,
                color: _touchedIndex == i
                    ? barColor
                    : barColor.withValues(alpha: 0.75),
                width: _barWidth(displayDays.length),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xsm),
                  topRight: Radius.circular(AppRadius.xsm),
                ),
              ),
            ],
          );
        }).toList(),
      ),
      duration: AppDurations.normal,
    );
  }

  double _barWidth(int count) {
    if (count <= 7) return 16;
    if (count <= 14) return 10;
    if (count <= 30) return 6;
    return 4;
  }

  int _labelStep(int count) {
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    if (count <= 30) return 5;
    return 10;
  }

  List<DayVolume> _downsample(List<DayVolume> days, int maxBars) {
    if (days.length <= maxBars) return days;
    final step = (days.length / maxBars).ceil();
    final result = <DayVolume>[];
    for (int i = 0; i < days.length; i += step) {
      final end = (i + step).clamp(0, days.length);
      final chunk = days.sublist(i, end);
      final totalWords = chunk.fold<int>(0, (s, d) => s + d.wordsRead);
      result.add(
        DayVolume(
          date: chunk.first.date,
          wordsRead: totalWords ~/ chunk.length,
        ),
      );
    }
    return result;
  }

  String _formatWords(int words) {
    if (words >= 1000) return '${(words / 1000).toStringAsFixed(1)}k';
    return '$words';
  }
}

