import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/tap_scale.dart';

/// "I Know This" button — gradient primary variant marking a word mastered.
class ReviewIKnowThisButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const ReviewIKnowThisButton({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? AppColors.onPrimary : AppColors.lightOnPrimary;
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark ? AppColors.primary : AppColors.lightPrimary,
              isDark
                  ? AppColors.primaryContainer
                  : AppColors.lightPrimaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.lgBorder,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 20, color: fg),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              AppStrings.reviewIKnowThis.tr,
              style: AppTypography.vocabFlashcardActionLabel.copyWith(color: fg),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
