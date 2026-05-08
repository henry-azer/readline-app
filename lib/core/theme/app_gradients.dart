import 'package:flutter/painting.dart';
import 'app_colors.dart';

abstract final class AppGradients {
  /// Primary CTA gradient (135° angle: primary → primaryContainer)
  static LinearGradient primary(bool isDark) => LinearGradient(
    colors: [
      isDark ? AppColors.primary : AppColors.lightPrimary,
      isDark ? AppColors.primaryContainer : AppColors.lightPrimaryContainer,
    ],
    begin: const Alignment(-0.7071, -0.7071),
    end: const Alignment(0.7071, 0.7071),
  );

  /// Streak card gradient (uses the app primary palette)
  static LinearGradient streak(bool isDark) => LinearGradient(
    colors: [
      isDark ? AppColors.primary : AppColors.lightPrimary,
      isDark ? AppColors.primaryContainer : AppColors.lightPrimaryContainer,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Velocity chart fill gradient
  static LinearGradient chartFill(bool isDark) => LinearGradient(
    colors: [
      isDark
          ? AppColors.primary.withValues(alpha: 0.3)
          : AppColors.lightPrimary.withValues(alpha: 0.2),
      isDark
          ? AppColors.primary.withValues(alpha: 0.0)
          : AppColors.lightPrimary.withValues(alpha: 0.0),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
