import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_gradients.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/analytics/viewmodels/analytics_viewmodel.dart';

class VelocityChart extends StatelessWidget {
  final MonthlyVelocity velocity;

  const VelocityChart({super.key, required this.velocity});

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
          // Y-axis + chart area
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _VelocityYAxis(
                  maxWpm: _maxWpm(velocity.avgWpmPerWeek),
                  isDark: isDark,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: CustomPaint(
                    painter: _VelocityPainter(
                      data: velocity.avgWpmPerWeek,
                      isDark: isDark,
                      gradient: AppGradients.chartFill(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // X-axis labels
          _VelocityXAxis(labels: velocity.weekLabels, isDark: isDark),
        ],
      ),
    );
  }

  double _maxWpm(List<double> data) {
    if (data.isEmpty) return 300;
    final max = data.reduce(math.max);
    return max == 0 ? 300 : max;
  }
}

// ── Y-axis ────────────────────────────────────────────────────────────────────

class _VelocityYAxis extends StatelessWidget {
  final double maxWpm;
  final bool isDark;

  const _VelocityYAxis({required this.maxWpm, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final steps = [maxWpm, maxWpm * 0.66, maxWpm * 0.33, 0.0];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: steps
          .map(
            (v) => Text(
              '${v.round()}',
              style: AppTypography.label.copyWith(color: color, fontSize: 9),
            ),
          )
          .toList(),
    );
  }
}

// ── X-axis ────────────────────────────────────────────────────────────────────

class _VelocityXAxis extends StatelessWidget {
  final List<String> labels;
  final bool isDark;

  const _VelocityXAxis({required this.labels, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels
            .map(
              (l) => Text(
                l,
                style: AppTypography.label.copyWith(color: color, fontSize: 10),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── CustomPainter ─────────────────────────────────────────────────────────────

class _VelocityPainter extends CustomPainter {
  final List<double> data;
  final bool isDark;
  final LinearGradient gradient;

  const _VelocityPainter({
    required this.data,
    required this.isDark,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final maxVal = data.reduce(math.max);
    final effectiveMax = maxVal == 0 ? 300.0 : maxVal;

    final lineColor = isDark ? AppColors.primary : AppColors.lightPrimary;
    final dotColor = isDark ? AppColors.primary : AppColors.lightPrimary;
    final gridColor = isDark
        ? AppColors.onSurfaceVariant.withValues(alpha: 0.12)
        : AppColors.lightOutlineVariant.withValues(alpha: 0.4);

    // Grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    for (final ratio in [0.33, 0.66, 1.0]) {
      final y = size.height * (1 - ratio);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Compute data points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i] / effectiveMax) * size.height;
      points.add(Offset(x, y));
    }

    // Build smooth bezier path
    final linePath = _buildBezierPath(points);

    // Build fill path (close to bottom)
    final fillPath = Path()..addPath(linePath, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Fill with gradient
    final gradientPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, gradientPaint);

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Draw dots at data points
    final dotFillPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    final dotStrokePaint = Paint()
      ..color = isDark
          ? AppColors.surfaceContainerHigh
          : AppColors.lightSurfaceContainerLowest
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final pt in points) {
      canvas.drawCircle(pt, 4, dotFillPaint);
      canvas.drawCircle(pt, 4, dotStrokePaint);
    }
  }

  Path _buildBezierPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      // Control points for smooth cubic bezier
      final cp1 = Offset(current.dx + (next.dx - current.dx) * 0.4, current.dy);
      final cp2 = Offset(next.dx - (next.dx - current.dx) * 0.4, next.dy);

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
    }

    return path;
  }

  @override
  bool shouldRepaint(_VelocityPainter old) =>
      old.data != data || old.isDark != isDark;
}
