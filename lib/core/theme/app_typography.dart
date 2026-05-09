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

  /// 11px label — card meta lines, descriptions, last-read date hints.
  static TextStyle get labelSmall => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTracking.normal,
    height: 1,
  );

  /// 10px label — page count, list-tile meta, percentage chips.
  static TextStyle get labelTiny => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTracking.normal,
    height: 1,
  );

  /// 9px label — status pills, complexity badges, dense card hints.
  static TextStyle get labelMicro => _sans.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTracking.normal,
    height: 1,
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

  // ── Splash (Newsreader display + Inter editorial label) ──
  // Resolved via bundled assets (pubspec `flutter.fonts`) instead of
  // google_fonts — the splash is the first paint and must not flash a
  // heavy system-serif fallback while Newsreader is being fetched.
  /// Hero-sized scale of the AppBar wordmark — identical typeface,
  /// weight, italic, and tracking as [brandMark]; just larger.
  static TextStyle get splashBrand => const TextStyle(
    fontFamily: 'Newsreader',
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    fontSize: 40,
    height: 1.2,
  );

  /// Cover title for the document grid card — bundled Newsreader italic
  /// 700, line height 1.15. Resolved via the bundled asset (declared in
  /// `pubspec.yaml`) so it renders on first paint without google_fonts
  /// fetching, mirroring [splashBrand].
  static TextStyle get coverTitle => const TextStyle(
    fontFamily: 'Newsreader',
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  static TextStyle get splashTagline => const TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    fontSize: 12,
    letterSpacing: AppTracking.wide,
    height: 1,
  );

  // ── Onboarding ──
  static TextStyle get onboardingHeadline => _serif.copyWith(
    fontSize: 38,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static TextStyle get onboardingHeadlineItalic =>
      onboardingHeadline.copyWith(fontStyle: FontStyle.italic);

  static TextStyle get onboardingSubtitleItalic =>
      bodyLarge.copyWith(fontStyle: FontStyle.italic);

  static TextStyle get onboardingFormatBadge => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTracking.normal,
    height: 1,
  );

  // ── Reading level cards ──
  static TextStyle get levelTag => _sans.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTracking.normal,
    height: 1,
  );

  static TextStyle get levelWpm => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTracking.normal,
    height: 1,
  );

  static TextStyle get levelDescription => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ── Bottom nav tabs ──
  static TextStyle get navTabInactive => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTracking.normal,
    height: 1,
  );

  static TextStyle get navTabActive => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: AppTracking.normal,
    height: 1,
  );

  // ── Home feature ──
  /// 9px / w600 / tracking 2.0 — uppercase eyebrow labels (greeting, section).
  static TextStyle get homeEyebrowLabel => _sans.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
    height: 1,
  );

  /// 9px / w600 / tracking 1.5 — progress ring micro labels.
  static TextStyle get homeProgressMicroLabel => _sans.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1,
  );

  /// 8px / w600 / tracking 1 — tiniest labels (streak day initials).
  static TextStyle get homeMicroLabelTiny => _sans.copyWith(
    fontSize: 8,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
    height: 1,
  );

  /// 10px / w600 — daily-insight title, format/badge labels.
  static TextStyle get homeBadgeLabel => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTracking.normal,
    height: 1,
  );

  /// 11px / w400 — shelf description / meta lines.
  static TextStyle get homeShelfMeta => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// 12px / w500 — featured-card meta caption ("X min left").
  static TextStyle get homeMetaCaption => _sans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// 22 / w800 — large stat number (streak count, calendar count).
  static TextStyle get homeStatNumber => _serif.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  /// 14 / w800 — small stat number (daily progress center).
  static TextStyle get homeStatNumberSmall => _sans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  /// 20 / w700 — calendar sheet section heading.
  static TextStyle get homeCalendarHeading => _serif.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// 18 / w600 — empty hero title.
  static TextStyle get homeEmptyTitle => _serif.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// w600 / tracking 0.5 — glass CTA + empty hero CTA label.
  static TextStyle get homeCtaLabel => labelMedium.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// 16 / w700 — featured card title (heavier than titleMedium).
  static TextStyle get homeFeaturedTitle => _serif.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// titleMedium with w500 — streak reset banner title.
  static TextStyle get homeBannerTitle =>
      titleMedium.copyWith(fontWeight: FontWeight.w500);

  // ── Shared widgets ──
  /// Brand-mark wordmark — italic title.
  static TextStyle get brandMark =>
      titleLarge.copyWith(fontStyle: FontStyle.italic);

  /// Share-card brand wordmark — italic headline.
  static TextStyle get shareCardBrand =>
      headlineLarge.copyWith(fontStyle: FontStyle.italic);

  /// Share-card large metric value — 48 / w800.
  static TextStyle get shareCardMetric => _serif.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  /// Share-card tagline footer — 10 / tracking 2.0.
  static TextStyle get shareCardTagline => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
    height: 1,
  );

  /// Daily-target picker title — titleMedium with bolder weight.
  static TextStyle get dailyTargetTitle =>
      titleMedium.copyWith(fontWeight: FontWeight.w700);

  /// Selected target chip label — labelMedium with bolder weight.
  static TextStyle get targetChipSelected =>
      labelMedium.copyWith(fontWeight: FontWeight.w700);

  /// Celebration tier label pill — 10 / tracking 1.5.
  static TextStyle get celebrationTierLabel => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1,
  );

  /// Celebration emoji glyph (e.g. fire) — 48px display.
  static TextStyle get celebrationEmoji => const TextStyle(fontSize: 48);

  /// Celebration streak hero number — 56 / w800 / serif display.
  static TextStyle get celebrationStreakNumber => _serif.copyWith(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  /// Celebration "DAY STREAK" label — `button` w800 with editorial tracking.
  static TextStyle get celebrationStreakLabel => button.copyWith(
    fontWeight: FontWeight.w800,
    letterSpacing: AppTracking.editorial,
  );

  // ── About / legal screens ──
  /// About screen app-name display — same wordmark style as [brandMark]
  /// and [splashBrand], scaled down for the about-screen header.
  static TextStyle get aboutAppName => brandMark.copyWith(
    fontSize: 20,
    height: 1.3,
  );

  /// About screen developer name — 20 / w700.
  static TextStyle get aboutDeveloperName => _serif.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// About screen copyright footer — 11 / w400.
  static TextStyle get aboutCopyright => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Privacy policy / terms body text — 14 / w400 / height 1.7.
  static TextStyle get legalBody => _sans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );

  /// Social chip label (LinkedIn / GitHub / Email) — 12 / w600.
  static TextStyle get socialChipLabel => _sans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1,
  );

  /// Feature card title — bodyMedium with bolder weight.
  static TextStyle get featureCardTitle =>
      bodyMedium.copyWith(fontWeight: FontWeight.w600);

  // ── Analytics ──
  /// Eyebrow / section label — 10 / w600 / wide tracking.
  static TextStyle get analyticsEyebrow => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTracking.wide,
    height: 1,
  );

  /// Smaller eyebrow used inside chart bodies — 9 / w600 / tracking 1.5.
  static TextStyle get analyticsLegend => _sans.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1,
  );

  /// Tiny chart axis tick label — 9 / w500.
  static TextStyle get analyticsAxisTick => _sans.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  /// Compact label (e.g. weekly-dots day initials) — 9 / w600 / tracking 0.5.
  static TextStyle get analyticsCompactLabel => _sans.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1,
  );

  /// Hero streak number on the analytics streak card — 56 / w800.
  static TextStyle get analyticsHeroNumber => _serif.copyWith(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    height: 1,
  );

  /// Hero streak unit ("days") — 32 / w500.
  static TextStyle get analyticsHeroUnit => _serif.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.1,
  );

  /// Stat card big number — 26 / w700.
  static TextStyle get analyticsStatNumber => _serif.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  /// Stat card unit ("hr", "wpm", etc.) — 11 / w500.
  static TextStyle get analyticsStatUnit => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  /// Stat card label under value — 10 / w600 / tracking 1.0.
  static TextStyle get analyticsStatLabel => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1,
  );

  /// Calendar day-of-week initial (M/T/W…) — 10 / w500 / tracking 0.5.
  static TextStyle get analyticsCalendarDow => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1,
  );

  /// Calendar day cell number — 12 / w500.
  static TextStyle get analyticsCalendarDay => _sans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  /// Calendar day cell number for today — 12 / w700.
  static TextStyle get analyticsCalendarDayToday => _sans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  /// Calendar tooltip body — 11 / w400.
  static TextStyle get analyticsCalendarTooltip => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// Volume / velocity chart period chip — 11 / variable weight / tracking 0.5.
  static TextStyle get analyticsPeriodChip => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1,
  );

  static TextStyle get analyticsPeriodChipSelected => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1,
  );

  /// Daily-progress ring center number — w700.
  static TextStyle get analyticsRingCenter =>
      titleMedium.copyWith(fontWeight: FontWeight.w700);

  /// Daily-progress ring center label — w600.
  static TextStyle get analyticsRingLabel =>
      bodySmall.copyWith(fontWeight: FontWeight.w600);

  /// Daily-progress weekly bar value — 10 / w600 / tracking 0.8.
  static TextStyle get analyticsWeeklyValue => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1,
  );

  /// Streak card body label — bodyMedium with w600.
  static TextStyle get analyticsStreakBody =>
      bodyMedium.copyWith(fontWeight: FontWeight.w600);

  /// Growth-insight body — bodyMedium with w500.
  static TextStyle get analyticsInsightBody =>
      bodyMedium.copyWith(fontWeight: FontWeight.w500);

  /// Velocity-chart trend label — bodySmall with w500.
  static TextStyle get analyticsTrendLabel =>
      bodySmall.copyWith(fontWeight: FontWeight.w500);

  // ── Support feature ──
  /// Support screen header title — uppercase button style with editorial tracking.
  static TextStyle get supportHeaderTitle =>
      button.copyWith(letterSpacing: AppTracking.editorial);

  // ── Settings feature ──
  /// Settings section eyebrow — `label` + wide tracking.
  static TextStyle get settingsEyebrow =>
      label.copyWith(letterSpacing: AppTracking.wide);

  /// Settings row label (chevron / toggle row primary text) — bodyMedium + w500.
  static TextStyle get settingsRowLabel =>
      bodyMedium.copyWith(fontWeight: FontWeight.w500);

  /// Settings picker option — bodyMedium default weight.
  static TextStyle get settingsPickerOption => bodyMedium;

  /// Settings picker option (selected) — bodyMedium + w600.
  static TextStyle get settingsPickerOptionSelected =>
      bodyMedium.copyWith(fontWeight: FontWeight.w600);

  /// Settings language-flag glyph — Inter 20 / w400.
  static TextStyle get settingsLanguageFlag =>
      _sans.copyWith(fontSize: 20, fontWeight: FontWeight.w400, height: 1);

  // ── Reading feature ──
  /// Reading micro label — 10 / w600 / loose tracking 0.8 (e.g. streak badge,
  /// floating vocab CTA labels).
  static TextStyle get readingMicroLabel => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1,
  );

  /// Reading micro CTA label — 10 / w700 / wider tracking 1.1 (vocab
  /// SAVE/SAVED button label).
  static TextStyle get readingMicroCta => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    height: 1,
  );

  /// Reading highlight word — italic title (vocab bar word).
  static TextStyle get readingHighlightWord =>
      titleMedium.copyWith(fontStyle: FontStyle.italic);

  /// Reading eyebrow — settings sheet section labels.
  static TextStyle get readingEyebrow => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1,
  );

  /// Reading slider value caption — 12 / w500.
  static TextStyle get readingValueCaption => _sans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  /// Reading slider value display — 14 / w700.
  static TextStyle get readingValueDisplay => _sans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  /// Reading pill button label — 12 / w600.
  static TextStyle get readingPillLabel => _sans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1,
  );

  /// Reading pill button label (selected) — 12 / w700.
  static TextStyle get readingPillLabelSelected => _sans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  /// Reading hero value display — 56 / w700 (e.g. WPM number in speed tab).
  static TextStyle get readingHeroValue => _serif.copyWith(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  /// Reading hero unit caption — 12 / w600 / wide tracking 2.0 (WPM label).
  static TextStyle get readingHeroUnit => _sans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
    height: 1,
  );

  /// Reading tiny preset label — 8 / w600 / tracking 0.8.
  static TextStyle get readingTinyLabel => _sans.copyWith(
    fontSize: 8,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1,
  );

  /// Reading sheet section label — 10 / w600 / tracking 1.0.
  static TextStyle get readingSheetLabel => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1,
  );

  /// Reading slider current value — 12 / w600.
  static TextStyle get readingSliderValue => _sans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1,
  );

  /// Reading theme-chip label — 9 / w500.
  static TextStyle get readingThemeChip => _sans.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  /// Reading theme-chip label (active) — 9 / w700.
  static TextStyle get readingThemeChipActive => _sans.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  /// Tabular caption — `label` style + `tabularFigures` font feature, with a
  /// responsive [fontSize] (used in the reading controls bar where elapsed /
  /// remaining time and speed labels need monospaced digits and adapt to
  /// screen breakpoints).
  static TextStyle tabularCaption({required double fontSize}) =>
      label.copyWith(
        fontSize: fontSize,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ── Session summary dialog ──
  /// Session summary headline — `headlineMedium` with tighter tracking.
  static TextStyle get summaryHeadline =>
      headlineMedium.copyWith(letterSpacing: -0.2);

  /// Session summary document title — italic title with comfortable leading.
  static TextStyle get summaryDocumentTitle => titleLarge.copyWith(
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0.1,
  );

  /// Session summary performance pill — 10 / w700 / wide tracking 1.2.
  static TextStyle get summaryPerformancePill => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1,
  );

  /// Session summary stat number — `headlineMedium` w700 with tight tracking.
  static TextStyle get summaryStatValue => headlineMedium.copyWith(
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// Session summary stat label — 9 / w600 / tracking 1.0.
  static TextStyle get summaryStatLabel => _sans.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1,
  );

  /// Session summary duration footer — 11 / w500 / tracking 0.5.
  static TextStyle get summaryDuration => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1,
  );

  /// Session summary "Done" CTA — `button` with wider tracking 1.4.
  static TextStyle get summaryDoneButton =>
      button.copyWith(letterSpacing: 1.4, fontWeight: FontWeight.w700);

  /// Reading player-settings TabBar tab label — 11 / w600 / tracking 1.0.
  static TextStyle get readingTabLabel => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1,
  );

  // ── Vocabulary feature ──
  /// Word-card primary word title — 26 / w600 / serif.
  static TextStyle get vocabWordTitle => _serif.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Source tag chip label — 9 / w600 / `labelMicro` family.
  static TextStyle get vocabSourceTag => labelMicro;

  /// Marginalia / footnote eyebrow inside word card — 9 / w600 / `labelMicro`.
  static TextStyle get vocabMarginaliaLabel => labelMicro;

  /// Word-card footer date meta — 11 / w400 / serif-neutral.
  static TextStyle get vocabDateMeta => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Difficulty pill — 9 / w600 / tracking 0.8.
  static TextStyle get vocabDifficultyChip => _sans.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1,
  );

  /// Mastery pill — 10 / w600 / tracking 0.8.
  static TextStyle get vocabMasteryChip => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1,
  );

  /// Flashcard front word — 40 / w700 / serif display.
  static TextStyle get vocabFlashcardWord => _serif.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Flashcard back word — `titleLarge` (22 / w700 / serif).
  static TextStyle get vocabFlashcardWordBack => titleLarge;

  /// Flashcard back source hint — 10 / `labelTiny`.
  static TextStyle get vocabFlashcardSourceHint => labelTiny;

  /// Flashcard "tap to reveal" hint — 13 / w700 / button-style.
  static TextStyle get vocabFlashcardFlipHint => button.copyWith(fontSize: 13);

  /// Flashcard action button label ("Still Learning" / "I Know This") —
  /// 11 / w700 / button-style.
  static TextStyle get vocabFlashcardActionLabel =>
      button.copyWith(fontSize: 11);

  /// Review-bloom CTA word ("Start" / "Session") — 11 / w700 / button-style.
  static TextStyle get vocabBloomCta => button.copyWith(fontSize: 11);

  // ── Word definition popup ──
  /// Word-definition part-of-speech badge — 10 / w600.
  static TextStyle get wordDefBadge => _sans.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: AppTracking.normal,
    height: 1,
  );

  /// Word-definition error message — bodyMedium + italic.
  static TextStyle get wordDefErrorMessage =>
      bodyMedium.copyWith(fontStyle: FontStyle.italic);

  /// Word-definition example sentence — bodySmall + italic.
  static TextStyle get wordDefExample =>
      bodySmall.copyWith(fontStyle: FontStyle.italic);

  /// Word-definition save / saved button label — 11 / w700 / tracking 1.0.
  static TextStyle get wordDefSaveButton => _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    height: 1,
  );

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

  /// Resolve reading font by family name.
  /// Supports all reading-appropriate Google Fonts.
  static TextStyle readingFont(
    String family, {
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.6,
  }) {
    final style = switch (family) {
      'newsreader' => _serif,
      'literata' => _literata,
      'inter' => _sans,
      'merriweather' => GoogleFonts.merriweather(),
      'lora' => GoogleFonts.lora(),
      'playfairDisplay' => GoogleFonts.playfairDisplay(),
      'sourceSerif4' => GoogleFonts.sourceSerif4(),
      'ebGaramond' => GoogleFonts.ebGaramond(),
      'crimsonText' => GoogleFonts.crimsonText(),
      'vollkorn' => GoogleFonts.vollkorn(),
      'notoSerif' => GoogleFonts.notoSerif(),
      'robotoSlab' => GoogleFonts.robotoSlab(),
      'openSans' => GoogleFonts.openSans(),
      'roboto' => GoogleFonts.roboto(),
      'nunito' => GoogleFonts.nunito(),
      'poppins' => GoogleFonts.poppins(),
      'dmSans' => GoogleFonts.dmSans(),
      'ibmPlexSerif' => GoogleFonts.ibmPlexSerif(),
      'ibmPlexSans' => GoogleFonts.ibmPlexSans(),
      'jetBrainsMono' => GoogleFonts.jetBrainsMono(),
      'firaMono' => GoogleFonts.firaCode(),
      _ => _serif,
    };
    return style.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }
}
