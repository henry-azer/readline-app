import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_opacity.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

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
    final resolved = _resolveStyle(masteryLevel, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: resolved.bgColor,
        borderRadius: AppRadius.fullBorder,
        border: resolved.borderColor != null
            ? Border.all(color: resolved.borderColor!, width: 1.5)
            : null,
      ),
      child: Text(
        resolved.label,
        style: AppTypography.label.copyWith(
          color: resolved.textColor,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  _MasteryStyle _resolveStyle(String level, bool isDark) {
    switch (level.toLowerCase()) {
      case 'mastered':
        // Fully solid — earned through repetition
        return _MasteryStyle(
          bgColor: isDark ? AppColors.masteredBg : AppColors.lightSuccess,
          textColor: isDark ? AppColors.masteredText : AppColors.white,
          borderColor: null,
          label: AppStrings.wordCardMasteryMastered.tr,
        );
      case 'learning':
        // Semi-filled with border — active progress
        return _MasteryStyle(
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
        // Outlined/hollow — just arrived
        return _MasteryStyle(
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

class _MasteryStyle {
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final String label;

  const _MasteryStyle({
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.label,
  });
}
