import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Chip used inside the library filter bottom sheet for multi-select state.
class LibraryFilterSheetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const LibraryFilterSheetChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final surface = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.short,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sxs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primary : surface,
          borderRadius: AppRadius.fullBorder,
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark
                      ? AppColors.outlineVariant
                      : AppColors.lightOutlineVariant),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? (isDark ? AppColors.onPrimary : AppColors.lightOnPrimary)
                    : onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
