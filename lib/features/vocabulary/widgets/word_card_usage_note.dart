import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// "Marginalia" panel inside the word card carrying user-authored notes.
class WordCardUsageNote extends StatelessWidget {
  final String note;
  final bool isDark;

  const WordCardUsageNote({
    super.key,
    required this.note,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? AppColors.surfaceContainerHigh.withValues(alpha: 0.5)
        : AppColors.lightSurfaceContainerLow;
    final textColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.smBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.wordCardMarginalia.tr,
            style: AppTypography.vocabMarginaliaLabel.copyWith(
              color: textColor.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: AppSpacing.micro),
          Text(
            note,
            style: AppTypography.bodySmall.copyWith(color: textColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
