import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/tap_scale.dart';

/// Subtle "tap to reveal" hint shown beneath the flashcard front face.
class ReviewFlipHint extends StatelessWidget {
  final VoidCallback onTap;

  const ReviewFlipHint({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: TapScale(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceContainerHigh
                : AppColors.lightSurfaceContainerHigh,
            borderRadius: AppRadius.lgBorder,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: 18,
                color: onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                AppStrings.reviewTapToReveal.tr,
                style: AppTypography.vocabFlashcardFlipHint.copyWith(
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
