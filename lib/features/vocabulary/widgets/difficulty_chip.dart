import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/vocabulary/widgets/vocab_chip_style.dart';

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
    final style = _resolveStyle(difficulty, isDark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: style.bgColor,
          borderRadius: AppRadius.fullBorder,
        ),
        child: Text(
          style.label,
          style: AppTypography.vocabDifficultyChip.copyWith(
            color: style.textColor,
          ),
        ),
      ),
    );
  }

  VocabChipStyle _resolveStyle(String level, bool isDark) {
    switch (level.toLowerCase()) {
      case 'easy':
        return VocabChipStyle(
          bgColor: (isDark ? AppColors.success : AppColors.lightSuccess)
              .withValues(alpha: 0.15),
          textColor: isDark ? AppColors.success : AppColors.lightSuccess,
          label: AppStrings.wordCardDifficultyEasy.tr,
        );
      case 'hard':
        return VocabChipStyle(
          bgColor: (isDark ? AppColors.error : AppColors.lightError).withValues(
            alpha: 0.15,
          ),
          textColor: isDark ? AppColors.error : AppColors.lightError,
          label: AppStrings.wordCardDifficultyHard.tr,
        );
      case 'medium':
      default:
        return VocabChipStyle(
          bgColor: (isDark ? AppColors.tertiary : AppColors.lightTertiary)
              .withValues(alpha: 0.15),
          textColor: isDark ? AppColors.tertiary : AppColors.lightTertiary,
          label: AppStrings.wordCardDifficultyMedium.tr,
        );
    }
  }
}
