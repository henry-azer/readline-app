import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_tracking.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Section heading inside the library filter bottom sheet.
class LibraryFilterSectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const LibraryFilterSectionLabel({
    super.key,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.label.copyWith(
        color: isDark
            ? AppColors.onSurfaceVariant
            : AppColors.lightOnSurfaceVariant,
        letterSpacing: AppTracking.wide,
      ),
    );
  }
}
