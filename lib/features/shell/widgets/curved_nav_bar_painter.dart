import 'package:flutter/material.dart';

class CurvedNavBarPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double notchRadius;
  final double notchMargin;
  final double topOffset;
  final double bottomPadding;

  CurvedNavBarPainter({
    required this.color,
    required this.borderColor,
    required this.notchRadius,
    required this.notchMargin,
    required this.topOffset,
    required this.bottomPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final barTop = topOffset;
    final r = notchRadius + notchMargin;

    final path = Path()
      ..moveTo(0, barTop)
      ..lineTo(cx - r - r * 0.6, barTop)
      ..cubicTo(
        cx - r,
        barTop,
        cx - r * 0.52,
        barTop + r * 0.85,
        cx,
        barTop + r * 0.85,
      )
      ..cubicTo(
        cx + r * 0.52,
        barTop + r * 0.85,
        cx + r,
        barTop,
        cx + r + r * 0.6,
        barTop,
      )
      ..lineTo(w, barTop)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    final borderPath = Path()
      ..moveTo(0, barTop)
      ..lineTo(cx - r - r * 0.6, barTop)
      ..cubicTo(
        cx - r,
        barTop,
        cx - r * 0.52,
        barTop + r * 0.85,
        cx,
        barTop + r * 0.85,
      )
      ..cubicTo(
        cx + r * 0.52,
        barTop + r * 0.85,
        cx + r,
        barTop,
        cx + r + r * 0.6,
        barTop,
      )
      ..lineTo(w, barTop);

    canvas.drawPath(
      borderPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CurvedNavBarPainter old) =>
      old.color != color || old.borderColor != borderColor;
}
