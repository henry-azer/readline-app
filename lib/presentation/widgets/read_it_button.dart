import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_gradients.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/widgets/tap_scale.dart';

class ReadItButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isSecondary;

  const ReadItButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    if (isSecondary) {
      return TapScale(
        onTap: onTap,
        child: Container(
          height: AppSpacing.buttonHeight,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceContainerHigh
                : AppColors.lightSurfaceContainerHigh,
            borderRadius: AppRadius.lgBorder,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.button.copyWith(
              color: isDark ? AppColors.onSurface : AppColors.lightOnSurface,
            ),
          ),
        ),
      );
    }

    return TapScale(
      onTap: onTap,
      child: Container(
        height: AppSpacing.buttonHeight,
        decoration: BoxDecoration(
          gradient: AppGradients.primary(isDark),
          borderRadius: AppRadius.lgBorder,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDark ? AppColors.onPrimary : AppColors.white,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: AppTypography.button.copyWith(
                color: isDark ? AppColors.onPrimary : AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
