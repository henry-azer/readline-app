import 'package:flutter/material.dart';

/// Animation curve tokens for the Readline editorial personality.
abstract final class AppCurves {
  /// Elements appearing: slide-up, fade-in
  static const Curve enter = Curves.easeOutCubic;

  /// Elements leaving: fade-out, slide-down
  static const Curve exit = Curves.easeInCubic;

  /// Symmetric animations: toggle, page swipe
  static const Curve standard = Curves.easeInOut;
}
