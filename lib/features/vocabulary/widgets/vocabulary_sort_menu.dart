import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/vocabulary/viewmodels/vocabulary_viewmodel.dart';

/// Popup menu for vocabulary sort options.
class VocabularySortMenu extends StatelessWidget {
  final VocabSortOption currentSort;
  final bool ascending;
  final ValueChanged<VocabSortOption> onSortChanged;
  final VoidCallback onDirectionToggle;

  const VocabularySortMenu({
    super.key,
    required this.currentSort,
    required this.ascending,
    required this.onSortChanged,
    required this.onDirectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final menuBg = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerLowest;

    return PopupMenuButton<String>(
      icon: Icon(Icons.sort_rounded, size: 20, color: onSurfaceVariant),
      color: menuBg,
      onSelected: (value) {
        if (value == 'direction') {
          onDirectionToggle();
        } else {
          final option = switch (value) {
            'alphabetical' => VocabSortOption.alphabetical,
            'difficulty' => VocabSortOption.difficulty,
            _ => VocabSortOption.dateAdded,
          };
          onSortChanged(option);
        }
      },
      itemBuilder: (context) => [
        _buildItem(
          value: 'dateAdded',
          label: AppStrings.vocabSortDateAdded.tr,
          isSelected: currentSort == VocabSortOption.dateAdded,
          onSurface: onSurface,
          primary: primary,
        ),
        _buildItem(
          value: 'alphabetical',
          label: AppStrings.vocabSortAlphabetical.tr,
          isSelected: currentSort == VocabSortOption.alphabetical,
          onSurface: onSurface,
          primary: primary,
        ),
        _buildItem(
          value: 'difficulty',
          label: AppStrings.vocabSortDifficulty.tr,
          isSelected: currentSort == VocabSortOption.difficulty,
          onSurface: onSurface,
          primary: primary,
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'direction',
          child: Row(
            children: [
              Icon(
                ascending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 16,
                color: primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                ascending
                    ? AppStrings.vocabSortAscending.tr
                    : AppStrings.vocabSortDescending.tr,
                style: AppTypography.bodyMedium.copyWith(color: primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildItem({
    required String value,
    required String label,
    required bool isSelected,
    required Color onSurface,
    required Color primary,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (isSelected)
            Icon(Icons.check_rounded, size: 16, color: primary)
          else
            const SizedBox(width: AppSpacing.md),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isSelected ? primary : onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
