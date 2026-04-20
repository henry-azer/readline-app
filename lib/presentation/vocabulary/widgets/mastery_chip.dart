import 'package:flutter/material.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_typography.dart';

/// Small colored pill showing the mastery level of a vocabulary word.
///
/// Colors:
/// - new/fresh → blue
/// - learning → amber
/// - mastered → green
class MasteryChip extends StatelessWidget {
  final String masteryLevel;

  const MasteryChip({super.key, required this.masteryLevel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (bgColor, textColor, label) = _resolveStyle(masteryLevel, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: textColor,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  (Color bg, Color text, String label) _resolveStyle(
    String level,
    bool isDark,
  ) {
    switch (level.toLowerCase()) {
      case 'mastered':
        return (
          isDark ? const Color(0xFF1B3A2E) : const Color(0xFFE6F4EA),
          isDark ? const Color(0xFF81C995) : const Color(0xFF1E7E34),
          AppStrings.wordCardMasteryMastered.tr,
        );
      case 'learning':
        return (
          isDark ? AppColors.tertiaryContainer : const Color(0xFFFFF3CD),
          isDark ? AppColors.tertiary : const Color(0xFF856404),
          AppStrings.wordCardMasteryLearning.tr,
        );
      case 'new':
      default:
        return (
          isDark ? const Color(0xFF1A2E40) : const Color(0xFFE3F0FA),
          isDark ? AppColors.primary : AppColors.lightPrimary,
          AppStrings.wordCardMasteryNew.tr,
        );
    }
  }
}
