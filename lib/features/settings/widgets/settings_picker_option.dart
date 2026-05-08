import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class SettingsPickerOption extends StatelessWidget {
  final Widget leading;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SettingsPickerOption({
    super.key,
    required this.leading,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final selectedBg = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final textColor = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final accent = isDark ? AppColors.primary : AppColors.lightPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.msl,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : AppColors.transparent,
          borderRadius: AppRadius.mdBorder,
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: (isSelected
                        ? AppTypography.settingsPickerOptionSelected
                        : AppTypography.settingsPickerOption)
                    .copyWith(color: textColor),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, size: 18, color: accent),
          ],
        ),
      ),
    );
  }
}
