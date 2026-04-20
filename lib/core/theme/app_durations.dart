/// Animation duration tokens for the Read-It editorial personality.
abstract final class AppDurations {
  /// TapScale, micro-feedback
  static const Duration quick = Duration(milliseconds: 100);

  /// Filter chip selection, toggle state changes
  static const Duration short = Duration(milliseconds: 150);

  /// AnimatedSwitcher defaults, vocab bar, saving indicator
  static const Duration normal = Duration(milliseconds: 250);

  /// Page transitions, flashcard flip, slide-up entries
  static const Duration calm = Duration(milliseconds: 350);

  /// Chart reveal, onboarding page swipe
  static const Duration slow = Duration(milliseconds: 500);
}
