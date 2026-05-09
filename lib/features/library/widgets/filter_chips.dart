import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/features/library/widgets/library_filter_chip.dart';

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
            child: LibraryFilterChip(
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
