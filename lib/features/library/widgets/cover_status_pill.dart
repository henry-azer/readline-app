import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Status pill shown on the top-left of a document grid card cover.
class CoverStatusPill extends StatelessWidget {
  final String status;
  final bool isDark;

  const CoverStatusPill({
    super.key,
    required this.status,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      'completed' => (
        AppStrings.libraryStatusCompleted.tr,
        isDark ? AppColors.success : AppColors.lightSuccess,
        Icons.check_rounded,
      ),
      'reading' => (
        AppStrings.libraryStatusInProgress.tr,
        isDark ? AppColors.primary : AppColors.lightPrimary,
        null,
      ),
      _ => (
        AppStrings.libraryStatusNotStarted.tr,
        isDark ? AppColors.onSurfaceVariant : AppColors.lightOnSurfaceVariant,
        null,
      ),
    };
    final bg = isDark
        ? AppColors.surfaceContainerHigh.withValues(alpha: 0.85)
        : AppColors.lightSurfaceContainerHigh.withValues(alpha: 0.85);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.fullBorder),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: AppSpacing.micro),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.micro),
          ],
          Text(label, style: AppTypography.labelMicro.copyWith(color: color)),
        ],
      ),
    );
  }
}
