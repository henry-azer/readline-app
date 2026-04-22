import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';

final _tipKeys = [
  AppStrings.homeTip1,
  AppStrings.homeTip2,
  AppStrings.homeTip3,
  AppStrings.homeTip4,
  AppStrings.homeTip5,
];

class ReadingTipCard extends StatelessWidget {
  final int tipIndex;

  const ReadingTipCard({super.key, this.tipIndex = 0});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final tip = _tipKeys[tipIndex % _tipKeys.length].tr;

    final bgColor = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    final accentColor = isDark ? AppColors.tertiary : AppColors.lightTertiary;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final borderColor = isDark
        ? AppColors.outlineVariant
        : AppColors.lightOutlineVariant;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: accentColor, width: 3),
          ),
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 18,
              color: accentColor,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.homeTipTitle.tr,
                  style: AppTypography.label.copyWith(
                    color: onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  tip,
                  style: AppTypography.bodyMedium.copyWith(
                    color: onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
