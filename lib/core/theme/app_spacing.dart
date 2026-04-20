import 'package:flutter/material.dart';
import 'app_breakpoints.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double sxs = 6;
  static const double xs = 8;
  static const double smd = 10;
  static const double sm = 12;
  static const double msl = 14;
  static const double md = 16;
  static const double mlg = 18;
  static const double lg = 20;
  static const double xl = 24;
  static const double xlg = 28;
  static const double xxl = 32;
  static const double x2l = 36;
  static const double xxxl = 40;
  static const double xxxxl = 48;

  // Button heights
  static const double buttonHeight = 48;
  static const double buttonHeightCompact = 40;

  // Layout constants
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(xl, xs, xl, xxxl);

  /// Responsive scale factor based on screen width.
  static double scaleFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppBreakpoints.compact) return 0.85;
    if (width > AppBreakpoints.expanded) return 1.1;
    return 1.0;
  }
}
