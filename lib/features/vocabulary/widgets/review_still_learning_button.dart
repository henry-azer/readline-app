import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/tap_scale.dart';

/// "Still Learning" button — flat surface variant with tertiary accent icon
/// and label.
class ReviewStillLearningButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const ReviewStillLearningButton({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColors.tertiary : AppColors.lightTertiary;
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceContainerHigh
              : AppColors.lightSurfaceContainerHigh,
          borderRadius: AppRadius.lgBorder,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 20, color: accent),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              AppStrings.reviewStillLearning.tr,
              style: AppTypography.vocabFlashcardActionLabel.copyWith(
                color: accent,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
