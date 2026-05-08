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
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final surface = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final filters = [
      ('all', AppStrings.libraryFilterAll.tr),
      ('unread', AppStrings.libraryFilterNotStarted.tr),
      ('reading', AppStrings.libraryFilterReading.tr),
      ('completed', AppStrings.libraryFilterCompleted.tr),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: filters.length,
        separatorBuilder: (ctx, idx) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final (value, label) = filters[index];
          final isSelected = activeFilter == value;
          final count = counts[value] ?? 0;
          final displayLabel = count > 0 ? '$label · $count' : label;

          return GestureDetector(
            onTap: () => onFilterChanged(value),
            child: AnimatedContainer(
              duration: AppDurations.short,
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected ? primary : surface,
                borderRadius: AppRadius.fullBorder,
                border: Border.all(
                  color: isSelected
                      ? primary
                      : (isDark
                            ? AppColors.outlineVariant
                            : AppColors.lightOutlineVariant),
                  width: 1.5,
                ),
              ),
              child: Text(
                displayLabel,
                style: AppTypography.label.copyWith(
                  color: isSelected
                      ? (isDark
                            ? AppColors.onPrimary
                            : AppColors.lightOnPrimary)
                      : onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
