import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class MagicSegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primary;
  final Color onSurface;
  final bool isDark;

  const MagicSegmentButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primary,
    required this.onSurface,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? primary.withValues(alpha: 0.15)
        : (isDark
              ? AppColors.surfaceContainer
              : AppColors.lightSurfaceContainer);
    final borderColor = isSelected
        ? primary
        : (isDark ? AppColors.outlineVariant : AppColors.lightOutlineVariant);
    final textColor = isSelected ? primary : onSurface;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smdBorder,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.smdBorder,
            border: Border.all(color: borderColor, width: isSelected ? 1.2 : 1),
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: textColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
