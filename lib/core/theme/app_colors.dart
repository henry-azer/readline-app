import 'package:flutter/material.dart';

/// Readline dual-theme color system.
///
/// Light: "The Modern Bibliophile" — warm paper, editorial
/// Dark: "The Midnight Library" — atmospheric, archival
abstract final class AppColors {
  // ── Light theme: "The Modern Bibliophile" ──
  static const Color lightWarmParchment = Color(0xFFF0EDE7);
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

  // ── Reading theme swatches ──
  static const Color readingThemeLightBg = Color(0xFFFFFBF5);
  static const Color readingThemeLightFg = Color(0xFF1C1B1F);
  static const Color readingThemeDarkBg = Color(0xFF1C1B1F);
  static const Color readingThemeDarkFg = Color(0xFFE6E0E9);
  static const Color readingThemeSepiaBg = Color(0xFFF4E8D1);
  static const Color readingThemeSepiaFg = Color(0xFF3E2723);
  static const Color readingThemeAmoledBg = Color(0xFF000000);
  static const Color readingThemeAmoledFg = Color(0xFFE6E0E9);

  // ── Reading background presets ──
  static const Color readingBgSepia = Color(0xFFF5ECD7);
  static const Color readingBgDark = Color(0xFF1A1A1E);
  static const Color readingBgAmoled = Color(0xFF000000);

  // ── Library cover palette ──
  /// Cover title color over the title-derived gradient — off-white in dark
  /// mode, near-black in light mode. Tuned for the muted earth-tone gradients
  /// produced by `CoverPalette.forTitle`.
  static const Color coverTitleDark = Color(0xFFF5F1E6);
  static const Color coverTitleLight = Color(0xFF1A1310);

  // ── Shared ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  /// 20% black scrim — used as a backdrop for floating UI (e.g. vocab bar).
  static const Color scrim20 = Color(0x33000000);
  /// 8% black scrim — used behind blurred celebration / dialog backdrops
  /// where the underlying screen should still read clearly.
  static const Color scrim08 = Color(0x14000000);

  // ── Semantic: Success / Completion ──
  static const Color lightSuccess = Color(0xFF1E7E34);
  static const Color success = Color(0xFF81C995);

  // ── Semantic: Mastery levels ──
  static const Color lightMasteredBg = Color(0xFFE6F4EA);
  static const Color masteredBg = Color(0xFF1B3A2E);
  static const Color lightMasteredText = Color(0xFF1E7E34);
  static const Color masteredText = Color(0xFF81C995);
  static const Color lightLearningBg = Color(0xFFFFF3CD);
  static const Color lightLearningText = Color(0xFF856404);

  // ── Semantic: Complexity levels ──
  static const Color complexityBeginner = Color(0xFF4CAF50);
  static const Color complexityIntermediate = Color(0xFF2196F3);
  static const Color complexityAdvanced = Color(0xFFFF9800);
  static const Color complexityExpert = Color(0xFFF44336);

  // ── Streak gradient ──
  static const Color streakGradientStart = Color(0xFFFF4500);
  static const Color streakGradientEnd = Color(0xFFD4A04A);
  static const Color lightStreakGradientStart = Color(0xFFD4572E);
  static const Color lightStreakGradientEnd = Color(0xFFB8892E);

  // ── Celebration tier colors ──
  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierBronzeEnd = Color(0xFFA0522D);
  static const Color lightTierBronze = Color(0xFF8B5A2B);
  static const Color lightTierBronzeEnd = Color(0xFF6B3A1A);
  static const Color tierSilver = Color(0xFFC0C0C0);
  static const Color tierSilverEnd = Color(0xFF909090);
  static const Color lightTierSilver = Color(0xFF808080);
  static const Color lightTierSilverEnd = Color(0xFF606060);
  static const Color tierGold = Color(0xFFFFD700);
  static const Color tierGoldEnd = Color(0xFFFFA500);
  static const Color lightTierGold = Color(0xFFDAA520);
  static const Color lightTierGoldEnd = Color(0xFFB8860B);
  static const Color tierPlatinum = Color(0xFFE5E4E2);
  static const Color tierPlatinumEnd = Color(0xFFADB2BD);
  static const Color lightTierPlatinum = Color(0xFFB0AEB0);
  static const Color lightTierPlatinumEnd = Color(0xFF8E9196);
  static const Color tierDiamond = Color(0xFFB9F2FF);
  static const Color tierDiamondEnd = Color(0xFF81D4FA);
  static const Color lightTierDiamond = Color(0xFF4FC3F7);
  static const Color lightTierDiamondEnd = Color(0xFF0288D1);

  // ── Group color presets ──
  static const Color groupRed = Color(0xFFEF5350);
  static const Color groupPink = Color(0xFFEC407A);
  static const Color groupPurple = Color(0xFFAB47BC);
  static const Color groupDeepPurple = Color(0xFF7E57C2);
  static const Color groupIndigo = Color(0xFF5C6BC0);
  static const Color groupBlue = Color(0xFF42A5F5);
  static const Color groupTeal = Color(0xFF26A69A);
  static const Color groupGreen = Color(0xFF66BB6A);
  static const Color groupLime = Color(0xFF9CCC65);
  static const Color groupAmber = Color(0xFFFFCA28);
  static const Color groupOrange = Color(0xFFFFA726);
  static const Color groupBrown = Color(0xFF8D6E63);

  static const List<Color> groupPresetColors = [
    groupRed,
    groupPink,
    groupPurple,
    groupDeepPurple,
    groupIndigo,
    groupBlue,
    groupTeal,
    groupGreen,
    groupLime,
    groupAmber,
    groupOrange,
    groupBrown,
  ];

  /// Resolve a hex color string (e.g., '#EF5350') to a Color.
  static Color fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) buffer.write('FF');
    buffer.write(hex);
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert a Color to hex string (e.g., '#EF5350').
  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  // ── Overlays ──
  static const Color darkOverlay = Color(0x14FFFFFF);
  static const Color barrierOverlay = Color(0x8A000000);

  // ── Glass effects ──
  static Color glassBackground(bool isDark) => isDark
      ? const Color(0x0AFFFFFF) // rgba(255,255,255,0.04)
      : const Color(0x08000000); // rgba(0,0,0,0.03)

  static Color glassBorder(bool isDark) => isDark
      ? const Color(0x14FFFFFF) // rgba(255,255,255,0.08)
      : const Color(0x0F000000); // rgba(0,0,0,0.06)

  static Color glassInner(bool isDark) => isDark
      ? const Color(0x0FFFFFFF) // rgba(255,255,255,0.06)
      : const Color(0x0A000000); // rgba(0,0,0,0.04)

  static Color glassTrack(bool isDark) => isDark
      ? const Color(0x0AFFFFFF) // rgba(255,255,255,0.04)
      : const Color(0x0A000000); // rgba(0,0,0,0.04)

  // ── Home background gradient (dark only) ──
  static const Color homeGradientTop = Color(0xFF0E1A2A);

  // ── Ambient shadows ──
  static BoxShadow ambientShadow({double blur = 32, double opacity = 0.06}) =>
      BoxShadow(
        color: Color.fromRGBO(28, 28, 26, opacity),
        blurRadius: blur,
        spreadRadius: -4,
      );

  /// Resolves a reading background/font color preset string to a [Color].
  ///
  /// Handles `'default'`, legacy preset names (`'sepia'`, `'dark'`, `'black'`),
  /// and raw hex strings (e.g. `'FF1A1A1E'`).
  static Color resolveReadingColor(
    bool isDark,
    String value,
    Color lightDefault,
    Color darkDefault,
  ) {
    if (value == 'default') {
      return isDark ? darkDefault : lightDefault;
    }
    switch (value) {
      case 'sepia':
        return readingBgSepia;
      case 'dark':
        return readingBgDark;
      case 'black':
        return readingBgAmoled;
    }
    final parsed = int.tryParse(value, radix: 16);
    if (parsed != null) return Color(parsed);
    return isDark ? darkDefault : lightDefault;
  }

  static BoxShadow darkAmbientShadow({
    double blur = 40,
    double opacity = 0.4,
  }) => BoxShadow(
    color: Color.fromRGBO(0, 0, 0, opacity),
    blurRadius: blur,
    spreadRadius: 0,
  );
}
