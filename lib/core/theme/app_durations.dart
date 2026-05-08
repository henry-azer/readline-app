/// Animation duration tokens for the Readline editorial personality.
abstract final class AppDurations {
  /// TapScale micro-feedback
  static const Duration instant = Duration(milliseconds: 60);

  /// TapScale, micro-feedback
  static const Duration quick = Duration(milliseconds: 100);

  /// Filter chip selection, toggle state changes
  static const Duration short = Duration(milliseconds: 150);

  /// Quick transitions (font family cards, preset chips)
  static const Duration fast = Duration(milliseconds: 150);

  /// AnimatedSwitcher defaults, vocab bar, saving indicator
  static const Duration normal = Duration(milliseconds: 250);

  /// Page transitions, flashcard flip, slide-up entries
  static const Duration calm = Duration(milliseconds: 300);

  /// Sheet transitions (import, settings)
  static const Duration smooth = Duration(milliseconds: 350);

  /// Chart reveal, onboarding page swipe, overlays
  static const Duration slow = Duration(milliseconds: 500);

  /// Count-up animations, progress reveals
  static const Duration reveal = Duration(milliseconds: 800);

  /// Stagger controllers
  static const Duration stagger = Duration(milliseconds: 1000);

  /// Splash screen animations
  static const Duration splash = Duration(milliseconds: 1200);

  /// Loading skeleton shimmer
  static const Duration skeleton = Duration(milliseconds: 1500);

  /// Snackbar display duration (short)
  static const Duration snackbar = Duration(seconds: 2);

  /// Snackbar display duration (long, with undo actions)
  static const Duration snackbarLong = Duration(seconds: 5);

  /// Auto-dismiss timers (overlays, banners)
  static const Duration autoDismiss = Duration(seconds: 10);

  /// Celebration confetti entry
  static const Duration celebrationEntry = Duration(seconds: 3);

  /// Search / input debounce
  static const Duration debounce = Duration(milliseconds: 300);
}
