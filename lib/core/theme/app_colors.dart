import 'package:flutter/material.dart';

/// Read-It dual-theme color system.
///
/// Light: "The Modern Bibliophile" — warm paper, editorial
/// Dark: "The Midnight Library" — atmospheric, archival
abstract final class AppColors {
  // ── Light theme: "The Modern Bibliophile" ──
  static const Color lightSurface = Color(0xFFFCF9F5);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF6F3EF);
  static const Color lightSurfaceContainer = Color(0xFFF0EDE7);
  static const Color lightSurfaceContainerHigh = Color(0xFFEDE9E3);
  static const Color lightSurfaceContainerHighest = Color(0xFFE4E0DA);
  static const Color lightOnSurface = Color(0xFF1C1C1A);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightPrimary = Color(0xFF00464A);
  static const Color lightPrimaryContainer = Color(0xFF006064);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightTertiary = Color(0xFFFFBA38);
  static const Color lightTertiaryContainer = Color(0xFF744F00);
  static const Color lightOutlineVariant = Color(0xFFCAC4BC);
  static const Color lightError = Color(0xFFBA1A1A);

  // ── Dark theme: "The Midnight Library" ──
  static const Color surface = Color(0xFF0E0E12);
  static const Color surfaceContainerLowest = Color(0xFF09090D);
  static const Color surfaceContainerLow = Color(0xFF131318);
  static const Color surfaceContainer = Color(0xFF19191F);
  static const Color surfaceContainerHigh = Color(0xFF1F1F26);
  static const Color surfaceContainerHighest = Color(0xFF25252D);
  static const Color onSurface = Color(0xFFE6E4EF);
  static const Color onSurfaceVariant = Color(0xFF9E9BA8);
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFAFCBD8);
  static const Color primaryContainer = Color(0xFF1A3A4A);
  static const Color onPrimary = Color(0xFF0E0E12);
  static const Color tertiary = Color(0xFFFFC6A0);
  static const Color tertiaryContainer = Color(0xFF3D2800);
  static const Color outlineVariant = Color(0xFF3A3A44);
  static const Color error = Color(0xFFFFB4AB);

  // ── Shared ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  // ── Streak gradient (light) ──
  static const Color streakGradientStart = Color(0xFFE8734A);
  static const Color streakGradientEnd = Color(0xFFD4A04A);

  // ── Overlays ──
  static const Color darkOverlay = Color(0x14FFFFFF);
  static const Color barrierOverlay = Color(0x8A000000);

  // ── Glass effects ──
  static Color glassBackground(bool isDark) => isDark
      ? surfaceContainer.withValues(alpha: 0.7)
      : lightSurface.withValues(alpha: 0.8);

  // ── Ambient shadows ──
  static BoxShadow ambientShadow({double blur = 32, double opacity = 0.06}) =>
      BoxShadow(
        color: Color.fromRGBO(28, 28, 26, opacity),
        blurRadius: blur,
        spreadRadius: -4,
      );

  static BoxShadow darkAmbientShadow({
    double blur = 40,
    double opacity = 0.4,
  }) => BoxShadow(
    color: Color.fromRGBO(0, 0, 0, opacity),
    blurRadius: blur,
    spreadRadius: 0,
  );
}
