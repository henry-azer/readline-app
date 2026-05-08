import 'package:flutter/material.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_gradients.dart';
import 'package:readline_app/core/theme/app_opacity.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class ReadlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isSecondary;

  const ReadlineButton({
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

    final isDisabled = onTap == null;

    return TapScale(
      onTap: isDisabled
          ? null
          : () {
              getIt<HapticService>().light();
              onTap!();
            },
      child: Opacity(
        opacity: isDisabled ? AppOpacity.medium : AppOpacity.full,
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
      ),
    );
  }
}
