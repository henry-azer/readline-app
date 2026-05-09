import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/features/vocabulary/viewmodels/vocabulary_viewmodel.dart';
import 'package:readline_app/features/vocabulary/widgets/vocabulary_filter_chip.dart';

/// Horizontal row of difficulty filter chips driving [VocabularyViewModel].
class VocabularyFilterChips extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final VocabularyStats stats;

  const VocabularyFilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final filters = <(String, String, int)>[
      ('all', AppStrings.vocabFilterAll.tr, stats.total),
      ('easy', AppStrings.vocabFilterEasy.tr, stats.easy),
      ('medium', AppStrings.vocabFilterMedium.tr, stats.medium),
      ('hard', AppStrings.vocabFilterHard.tr, stats.hard),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: filters.map((f) {
          final (key, label, count) = f;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: VocabularyFilterChip(
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
