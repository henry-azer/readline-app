import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/readline_button.dart';

/// Empty state shown when no vocabulary words are due for review.
class ReviewNoWordsView extends StatelessWidget {
  final VoidCallback onClose;

  const ReviewNoWordsView({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 72,
            color: primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppStrings.reviewAllCaughtUp.tr,
            style: AppTypography.displayMedium.copyWith(color: onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.reviewAllCaughtUpBody.tr,
            style: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: ReadlineButton(
              label: AppStrings.reviewGoBack.tr,
              onTap: onClose,
            ),
          ),
        ],
      ),
    );
  }
}
