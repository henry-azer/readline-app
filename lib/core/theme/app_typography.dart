import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tracking.dart';

/// Typography system: Newsreader (reading/editorial) + Inter (UI/functional).
abstract final class AppTypography {
  static TextStyle get _serif => GoogleFonts.newsreader();
  static TextStyle get _sans => GoogleFonts.inter();
  static TextStyle get _literata => GoogleFonts.literata();

  // ── Display (Newsreader — hero, editorial) ──
  static TextStyle get displayLarge => _serif.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get displayMedium => _serif.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // ── Headline (Newsreader) ──
  static TextStyle get headlineLarge =>
      _serif.copyWith(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get headlineMedium =>
      _serif.copyWith(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);

  // ── Title (Newsreader) ──
  static TextStyle get titleLarge => _serif.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static TextStyle get titleMedium =>
      _serif.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  // ── Body (Inter — functional UI) ──
  static TextStyle get bodyLarge =>
      _sans.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodyMedium =>
      _sans.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodySmall =>
      _sans.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);

  // ── Labels (Inter — metadata, navigation, all-caps) ──
  static TextStyle get label => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTracking.normal,
    height: 1,
  );

  static TextStyle get labelMedium => _sans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: AppTracking.tight,
  );

  // ── Button (Inter — bold, wide tracking) ──
  static TextStyle get button => _sans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: AppTracking.wide,
  );

  // ── Section header (Newsreader — analytics/library section titles) ──
  static TextStyle get sectionHeader =>
      _serif.copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3);

  // ── Reading body (Newsreader — long-form reading display) ──
  static TextStyle get readingBody =>
      _serif.copyWith(fontSize: 18, fontWeight: FontWeight.w400, height: 1.6);

  static TextStyle get readingBodyFocus =>
      _serif.copyWith(fontSize: 24, fontWeight: FontWeight.w700, height: 1.5);

  static TextStyle get readingBodyPast => _serif.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.6,
  );

  /// Dark mode reading adjustment: +0.03em letter-spacing
  static TextStyle readingBodyDark(TextStyle base) => base.copyWith(
    letterSpacing: (base.letterSpacing ?? 0) + 0.48,
    height: 1.6,
  );

  // ── Alternative reading font (Literata) ──
  static TextStyle literataBody({double fontSize = 18}) => _literata.copyWith(
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  /// Resolve reading font by family name
  static TextStyle readingFont(String family, {double fontSize = 18}) {
    switch (family) {
      case 'literata':
        return _literata.copyWith(fontSize: fontSize, height: 1.6);
      case 'newsreader':
        return _serif.copyWith(fontSize: fontSize, height: 1.6);
      case 'inter':
      default:
        return _sans.copyWith(fontSize: fontSize, height: 1.6);
    }
  }
}
