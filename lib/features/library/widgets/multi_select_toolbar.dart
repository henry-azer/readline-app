import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class MultiSelectToolbar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const MultiSelectToolbar({
    super.key,
    required this.selectedCount,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final textColor = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final subtextColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final errorColor = isDark ? AppColors.error : AppColors.lightError;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.lgBorder,
        boxShadow: [
          isDark
              ? AppColors.darkAmbientShadow(blur: 16, opacity: 0.3)
              : AppColors.ambientShadow(blur: 16, opacity: 0.08),
        ],
      ),
      child: Row(
        children: [
          // Close button
          IconButton(
            icon: Icon(Icons.close_rounded, size: 20, color: subtextColor),
            onPressed: onCancel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Selected count
          Text(
            AppStrings.librarySelectedCount.trParams({'n': '$selectedCount'}),
            style: AppTypography.titleMedium.copyWith(color: textColor),
          ),

          const Spacer(),

          // Delete
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 22,
              color: selectedCount > 0 ? errorColor : subtextColor,
            ),
            onPressed: selectedCount > 0 ? onDelete : null,
            tooltip: AppStrings.libraryDeleteAction.tr,
          ),
        ],
      ),
    );
  }
}
