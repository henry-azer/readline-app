/// Opacity value tokens — replaces hardcoded `.withValues(alpha:)` values.
abstract final class AppOpacity {
  /// Light mode shadows
  static const double subtle = 0.06;

  /// Dividers, disabled states
  static const double hint = 0.12;

  /// Inactive icon tint
  static const double light = 0.25;

  /// Secondary text overlay
  static const double medium = 0.4;

  /// Active but not primary
  static const double strong = 0.6;

  /// Primary elements
  static const double full = 1.0;
}
