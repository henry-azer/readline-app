import 'package:flutter/material.dart';
import 'package:read_it/core/theme/app_breakpoints.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isCompactScreen => screenWidth < AppBreakpoints.compact;
  bool get isExpandedScreen => screenWidth > AppBreakpoints.expanded;
}
