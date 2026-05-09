import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Compact uppercase tag showing where a vocabulary word came from.
class WordCardSourceTag extends StatelessWidget {
  final String label;
  final bool isDark;

  const WordCardSourceTag({
    super.key,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final text = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final displayLabel = label.length > 20
        ? '${label.substring(0, 18).toUpperCase()}...'
        : label.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.xsBorder),
      child: Text(
        displayLabel,
        style: AppTypography.vocabSourceTag.copyWith(color: text),
      ),
    );
  }
}
