import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_gradients.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class ImportFab extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const ImportFab({super.key, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: AppSpacing.buttonHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppGradients.primary(isDark),
          borderRadius: AppRadius.fullBorder,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.primary : AppColors.lightPrimary)
                  .withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            else
              const Icon(Icons.add_rounded, color: AppColors.white, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Text(
              AppStrings.libraryImportPdf.tr,
              style: AppTypography.button.copyWith(
                color: AppColors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
