import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/analytics/viewmodels/analytics_viewmodel.dart';

class ReadingVolumeChart extends StatelessWidget {
  final WeeklyStats stats;

  const ReadingVolumeChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerLowest;

    return Container(
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
          // Y-axis labels row + chart area
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels
                _YAxisLabels(
                  maxWords: _maxWords(stats.wordsPerDay),
                  isDark: isDark,
                ),
                const SizedBox(width: AppSpacing.xs),
                // Bar chart
                Expanded(
                  child: CustomPaint(
                    painter: _BarChartPainter(
                      wordsPerDay: stats.wordsPerDay,
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // X-axis day labels
          _XAxisLabels(dayLabels: stats.dayLabels),
        ],
      ),
    );
  }

  int _maxWords(List<int> data) {
    if (data.isEmpty) return 1000;
    final max = data.reduce(math.max);
    return max == 0 ? 1000 : max;
  }
}

// ── Y-axis labels ─────────────────────────────────────────────────────────────

class _YAxisLabels extends StatelessWidget {
  final int maxWords;
  final bool isDark;

  const _YAxisLabels({required this.maxWords, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    String fmt(int n) {
      if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
      return '$n';
    }

    final steps = [
      maxWords,
      (maxWords * 0.66).round(),
      (maxWords * 0.33).round(),
      0,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: steps
          .map(
            (v) => Text(
              fmt(v),
              style: AppTypography.label.copyWith(color: color, fontSize: 9),
            ),
          )
          .toList(),
    );
  }
}

// ── X-axis labels ─────────────────────────────────────────────────────────────

class _XAxisLabels extends StatelessWidget {
  final List<String> dayLabels;

  const _XAxisLabels({required this.dayLabels});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final color = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    // Offset for the y-axis column width (approx 28px) + spacing (8px)
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: dayLabels
            .map(
              (d) => Text(
                d,
                style: AppTypography.label.copyWith(
                  color: color,
                  fontSize: 10,
                  letterSpacing: 0.2,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── CustomPainter ─────────────────────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  final List<int> wordsPerDay;
  final bool isDark;

  const _BarChartPainter({required this.wordsPerDay, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (wordsPerDay.isEmpty) return;

    final maxVal = wordsPerDay.reduce(math.max).toDouble();
    final effectiveMax = maxVal == 0 ? 1000.0 : maxVal;

    final barColor = isDark ? AppColors.primary : AppColors.lightPrimary;
    final gridColor = isDark
        ? AppColors.onSurfaceVariant.withValues(alpha: 0.15)
        : AppColors.lightOutlineVariant.withValues(alpha: 0.5);

    // Draw grid lines (3 levels)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    for (final ratio in [0.33, 0.66, 1.0]) {
      final y = size.height * (1 - ratio);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final count = wordsPerDay.length;
    final barAreaWidth = size.width / count;
    const barInsetRatio = 0.28; // gap on each side relative to bar area
    final barWidth = barAreaWidth * (1 - barInsetRatio * 2);
    final barInset = barAreaWidth * barInsetRatio;

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final val = wordsPerDay[i].toDouble();
      final barHeight = (val / effectiveMax) * size.height;
      if (barHeight < 1) continue;

      final left = barAreaWidth * i + barInset;
      final top = size.height - barHeight;
      final right = left + barWidth;
      final bottom = size.height;

      // Rounded top corners only
      final rect = Rect.fromLTRB(left, top, right, bottom);
      final rRect = RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rRect, barPaint);
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.wordsPerDay != wordsPerDay || old.isDark != isDark;
}
