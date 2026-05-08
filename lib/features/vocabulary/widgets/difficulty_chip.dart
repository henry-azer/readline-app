import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Small colored pill showing the difficulty level of a vocabulary word.
///
/// Tap to cycle: easy -> medium -> hard -> easy.
class DifficultyChip extends StatelessWidget {
  final String difficulty;
  final VoidCallback? onTap;

  const DifficultyChip({super.key, required this.difficulty, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final resolved = _resolveStyle(difficulty, isDark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: resolved.bgColor,
          borderRadius: AppRadius.fullBorder,
        ),
        child: Text(
          resolved.label,
          style: AppTypography.label.copyWith(
            color: resolved.textColor,
            fontSize: 9,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  _DifficultyStyle _resolveStyle(String level, bool isDark) {
    switch (level.toLowerCase()) {
      case 'easy':
        return _DifficultyStyle(
          bgColor: (isDark ? AppColors.success : AppColors.lightSuccess)
              .withValues(alpha: 0.15),
          textColor: isDark ? AppColors.success : AppColors.lightSuccess,
          label: AppStrings.wordCardDifficultyEasy.tr,
        );
      case 'hard':
        return _DifficultyStyle(
          bgColor: (isDark ? AppColors.error : AppColors.lightError).withValues(
            alpha: 0.15,
          ),
          textColor: isDark ? AppColors.error : AppColors.lightError,
          label: AppStrings.wordCardDifficultyHard.tr,
        );
      case 'medium':
      default:
        return _DifficultyStyle(
          bgColor: (isDark ? AppColors.tertiary : AppColors.lightTertiary)
              .withValues(alpha: 0.15),
          textColor: isDark ? AppColors.tertiary : AppColors.lightTertiary,
          label: AppStrings.wordCardDifficultyMedium.tr,
        );
    }
  }
}

class _DifficultyStyle {
  final Color bgColor;
  final Color textColor;
  final String label;

  const _DifficultyStyle({
    required this.bgColor,
    required this.textColor,
    required this.label,
  });
}
