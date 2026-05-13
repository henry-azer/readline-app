abstract final class AppConstants {
  // Reading speed
  static const int defaultWpm = 200;
  static const int minWpm = 50;
  static const int maxWpm = 800;
  static const int wpmStep = 10;

  // Font size
  static const int minFontSize = 8;
  static const int maxFontSize = 48;
  static const int fontSizeStep = 2;

  // Line spacing
  static const double minLineSpacing = 0.8;
  static const double maxLineSpacing = 3.0;
  static const double lineSpacingStep = 0.1;

  // Page margin (left/right inset for the reading text, in logical px)
  static const double minMargin = 0;
  static const double maxMargin = 80;
  static const double marginStep = 4;

  // Streak milestones
  static const Map<int, String> streakMilestones = {
    7: 'on fire',
    14: 'unstoppable',
    30: 'legendary',
    100: 'archivist',
  };

  // Complexity thresholds
  static const int beginnerMax = 25;
  static const int intermediateMax = 50;
  static const int advancedMax = 75;
}
