import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_opacity.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/vocabulary/widgets/vocab_chip_style.dart';

/// Small colored pill showing the mastery level of a vocabulary word.
///
/// Progressive visual metaphor:
/// - fresh → outlined/hollow (just arrived)
/// - learning → semi-filled with border (active progress)
/// - mastered → fully solid (earned through repetition)
class MasteryChip extends StatelessWidget {
  final String masteryLevel;

  const MasteryChip({super.key, required this.masteryLevel});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final style = _resolveStyle(masteryLevel, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: style.bgColor,
        borderRadius: AppRadius.fullBorder,
        border: style.borderColor != null
            ? Border.all(color: style.borderColor!, width: 1.5)
            : null,
      ),
      child: Text(
        style.label,
        style: AppTypography.vocabMasteryChip.copyWith(color: style.textColor),
      ),
    );
  }

  VocabChipStyle _resolveStyle(String level, bool isDark) {
    switch (level.toLowerCase()) {
      case 'mastered':
        return VocabChipStyle(
          bgColor: isDark ? AppColors.masteredBg : AppColors.lightSuccess,
          textColor: isDark ? AppColors.masteredText : AppColors.white,
          label: AppStrings.wordCardMasteryMastered.tr,
        );
      case 'learning':
        return VocabChipStyle(
          bgColor: isDark
              ? AppColors.tertiaryContainer.withValues(alpha: AppOpacity.medium)
              : AppColors.lightLearningBg,
          textColor: isDark ? AppColors.tertiary : AppColors.lightLearningText,
          borderColor: isDark
              ? AppColors.tertiary.withValues(alpha: AppOpacity.medium)
              : AppColors.lightLearningText.withValues(alpha: 0.3),
          label: AppStrings.wordCardMasteryLearning.tr,
        );
      case 'new':
      default:
        return VocabChipStyle(
          bgColor: AppColors.transparent,
          textColor: isDark ? AppColors.primary : AppColors.lightPrimary,
          borderColor: isDark
              ? AppColors.primary.withValues(alpha: AppOpacity.medium)
              : AppColors.lightPrimary.withValues(alpha: AppOpacity.medium),
          label: AppStrings.wordCardMasteryNew.tr,
        );
    }
  }
}
