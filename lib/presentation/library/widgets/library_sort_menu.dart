import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';

class LibrarySortMenu extends StatelessWidget {
  final String currentField;
  final bool isAscending;
  final ValueChanged<String> onFieldChanged;
  final VoidCallback onDirectionToggled;

  const LibrarySortMenu({
    super.key,
    required this.currentField,
    required this.isAscending,
    required this.onFieldChanged,
    required this.onDirectionToggled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return PopupMenuButton<String>(
      icon: Icon(Icons.sort_rounded, color: onSurfaceVariant, size: 22),
      color: isDark
          ? AppColors.surfaceContainerHigh
          : AppColors.lightSurfaceContainerLowest,
      onSelected: (value) {
        if (value == '_toggle_direction') {
          onDirectionToggled();
        } else {
          onFieldChanged(value);
        }
      },
      itemBuilder: (context) {
        final options = [
          ('lastRead', AppStrings.librarySortLastRead.tr),
          ('dateAdded', AppStrings.librarySortDateAdded.tr),
          ('title', AppStrings.librarySortTitle.tr),
          ('progress', AppStrings.librarySortProgress.tr),
          ('wordCount', AppStrings.librarySortWordCount.tr),
        ];

        return [
          ...options.map(
            (opt) => PopupMenuItem<String>(
              value: opt.$1,
              child: Row(
                children: [
                  if (currentField == opt.$1)
                    Icon(Icons.check_rounded, size: 16, color: primary)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    opt.$2,
                    style: AppTypography.bodyMedium.copyWith(
                      color: currentField == opt.$1 ? primary : onSurface,
                      fontWeight: currentField == opt.$1
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: '_toggle_direction',
            child: Row(
              children: [
                Icon(
                  isAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 16,
                  color: primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  isAscending
                      ? AppStrings.librarySortAscending.tr
                      : AppStrings.librarySortDescending.tr,
                  style: AppTypography.bodyMedium.copyWith(color: onSurface),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}
