import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class LibraryFilterChips extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final Map<String, int> counts;

  const LibraryFilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    this.counts = const {},
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final filters = [
      ('all', AppStrings.libraryFilterAll.tr, counts['all'] ?? 0),
      ('unread', AppStrings.libraryFilterNotStarted.tr, counts['unread'] ?? 0),
      ('reading', AppStrings.libraryFilterReading.tr, counts['reading'] ?? 0),
      (
        'completed',
        AppStrings.libraryFilterCompleted.tr,
        counts['completed'] ?? 0,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: filters.map((f) {
          final (key, label, count) = f;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: _Chip(
              label: label,
              count: count,
              isSelected: activeFilter == key,
              onTap: () => onFilterChanged(key),
              isDark: isDark,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _Chip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final surfaceHigh = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.short,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.msl,
          vertical: AppSpacing.sxs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primary : surfaceHigh,
          borderRadius: AppRadius.fullBorder,
        ),
        child: Text(
          count > 0 ? '$label ($count)' : label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected
                ? (isDark ? AppColors.onPrimary : AppColors.lightOnPrimary)
                : onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
