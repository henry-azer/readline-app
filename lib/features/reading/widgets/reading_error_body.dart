import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Centered error body shown when the reading screen fails to load a document.
class ReadingErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  final bool isDark;
  final Color onSurface;

  const ReadingErrorBody({
    super.key,
    required this.message,
    required this.onBack,
    required this.isDark,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: isDark ? AppColors.error : AppColors.lightError,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(color: onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton(
              onPressed: onBack,
              child: Text(
                AppStrings.readingGoBack.tr,
                style: AppTypography.button.copyWith(
                  color: isDark ? AppColors.primary : AppColors.lightPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
