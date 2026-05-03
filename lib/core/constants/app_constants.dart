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
  static const double minLineSpacing = 1.0;
  static const double maxLineSpacing = 2.5;
  static const double lineSpacingStep = 0.1;

  // Focus window
  static const int maxFocusLines = 7;

  // Spaced repetition
  static const List<int> spacedRepetitionIntervals = [1, 3, 7, 14, 30];

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
