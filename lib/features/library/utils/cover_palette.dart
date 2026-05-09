import 'package:flutter/material.dart';

/// Stable per-title gradient palettes for the document grid card cover.
///
/// An FNV-1a hash over [title]'s UTF-16 code units yields a hue in
/// [0, 360); we then project that hue through fixed soft HSL stops, so
/// every document gets a unique-but-stable gradient that stays inside
/// the app's muted earth-tone aesthetic regardless of which hue lands.
abstract final class CoverPalette {
  /// Returns the 3-stop gradient (TL → BR) for [title].
  static List<Color> forTitle(String title, {required bool isDark}) {
    final hue = _hueFromTitle(title);
    if (isDark) {
      return [
        HSLColor.fromAHSL(1, hue, 0.30, 0.18).toColor(),
        HSLColor.fromAHSL(1, hue, 0.32, 0.28).toColor(),
        HSLColor.fromAHSL(1, hue, 0.36, 0.39).toColor(),
      ];
    }
    return [
      HSLColor.fromAHSL(1, hue, 0.26, 0.88).toColor(),
      HSLColor.fromAHSL(1, hue, 0.32, 0.70).toColor(),
      HSLColor.fromAHSL(1, hue, 0.38, 0.55).toColor(),
    ];
  }

  /// Returns the title text color appropriate for the gradient
  /// brightness — near-black on light gradients, off-white on dark.
  static Color titleColor({required bool isDark}) =>
      isDark ? const Color(0xFFF5F1E6) : const Color(0xFF1A1310);

  /// Tiered font size for the cover title — shrinks as the title gets longer
  /// so it fits within the cover's 2–3 line budget.
  static double titleFontSize(String title) {
    final len = title.length;
    if (len <= 18) return 24;
    if (len <= 34) return 20;
    if (len <= 55) return 17;
    return 14;
  }

  /// FNV-1a hash over [title]'s code units, projected into hue degrees.
  /// Stable across platforms — does not rely on [String.hashCode].
  static double _hueFromTitle(String title) {
    var h = 2166136261;
    for (final u in title.codeUnits) {
      h ^= u;
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    return (h % 360).toDouble();
  }
}
