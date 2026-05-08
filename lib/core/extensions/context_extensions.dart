import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_breakpoints.dart';
import 'package:readline_app/core/theme/app_colors.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isCompactScreen => screenWidth < AppBreakpoints.compact;
  bool get isExpandedScreen => screenWidth > AppBreakpoints.expanded;

  // Color shortcuts
  Color get primary => isDark ? AppColors.primary : AppColors.lightPrimary;
  Color get onSurface => isDark ? AppColors.onSurface : AppColors.lightOnSurface;
  Color get onSurfaceVariant => isDark ? AppColors.onSurfaceVariant : AppColors.lightOnSurfaceVariant;
  Color get surfaceContainer => isDark ? AppColors.surfaceContainer : AppColors.lightSurfaceContainer;
  Color get surfaceContainerHigh => isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceContainerHigh;
  Color get surfaceContainerLowest => isDark ? AppColors.surfaceContainerLowest : AppColors.lightSurfaceContainerLowest;
  Color get outlineVariant => isDark ? AppColors.outlineVariant : AppColors.lightOutlineVariant;
}
