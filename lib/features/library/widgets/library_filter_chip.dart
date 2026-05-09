import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Single chip in the library's quick-filter row (all / unread / reading /
/// completed). Shows an optional count next to the label.
class LibraryFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const LibraryFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final surfaceHigh = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.short,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.msl,
          vertical: AppSpacing.sxs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primary : surfaceHigh,
          borderRadius: AppRadius.fullBorder,
        ),
        child: Text(
          count > 0 ? '$label ($count)' : label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected
                ? (isDark ? AppColors.onPrimary : AppColors.lightOnPrimary)
                : onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
