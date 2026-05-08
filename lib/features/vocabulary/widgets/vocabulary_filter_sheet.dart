import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/vocabulary/viewmodels/vocabulary_viewmodel.dart';

/// Bottom sheet for advanced vocabulary filtering.
class VocabularyFilterSheet extends StatefulWidget {
  final VocabFilterConfig initialConfig;
  final List<String> sourceDocuments;
  final ValueChanged<VocabFilterConfig> onApply;
  final VoidCallback onClearAll;

  const VocabularyFilterSheet({
    super.key,
    required this.initialConfig,
    required this.sourceDocuments,
    required this.onApply,
    required this.onClearAll,
  });

  @override
  State<VocabularyFilterSheet> createState() => _VocabularyFilterSheetState();
}

class _VocabularyFilterSheetState extends State<VocabularyFilterSheet> {
  late VocabFilterConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
  }

  void _toggleDifficulty(String difficulty) {
    final current = Set<String>.from(_config.difficulties);
    if (current.contains(difficulty)) {
      current.remove(difficulty);
    } else {
      current.add(difficulty);
    }
    setState(() {
      _config = _config.copyWith(difficulties: current);
    });
    widget.onApply(_config);
  }

  void _setSource(String? source) {
    setState(() {
      _config = source == null
          ? _config.copyWith(clearSource: true)
          : _config.copyWith(sourceDocument: source);
    });
    widget.onApply(_config);
  }

  void _setDateRange(String? range) {
    setState(() {
      _config = range == null
          ? _config.copyWith(clearDateRange: true)
          : _config.copyWith(dateRange: range);
    });
    widget.onApply(_config);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurface;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: AppRadius.fullBorder,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title + Clear All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.vocabFilterTitle.tr,
                style: AppTypography.titleMedium.copyWith(color: onSurface),
              ),
              if (!_config.isEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _config = const VocabFilterConfig();
                    });
                    widget.onClearAll();
                  },
                  child: Text(
                    AppStrings.vocabFilterClearAll.tr,
                    style: AppTypography.labelMedium.copyWith(color: primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Difficulty section
          Text(
            AppStrings.vocabFilterDifficulty.tr,
            style: AppTypography.label.copyWith(
              color: onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _DifficultyChip(
                label: AppStrings.vocabFilterEasy.tr,
                color: isDark ? AppColors.success : AppColors.lightSuccess,
                isSelected: _config.difficulties.contains('easy'),
                onTap: () => _toggleDifficulty('easy'),
                isDark: isDark,
              ),
              const SizedBox(width: AppSpacing.xs),
              _DifficultyChip(
                label: AppStrings.vocabFilterMedium.tr,
                color: isDark ? AppColors.tertiary : AppColors.lightTertiary,
                isSelected: _config.difficulties.contains('medium'),
                onTap: () => _toggleDifficulty('medium'),
                isDark: isDark,
              ),
              const SizedBox(width: AppSpacing.xs),
              _DifficultyChip(
                label: AppStrings.vocabFilterHard.tr,
                color: isDark ? AppColors.error : AppColors.lightError,
                isSelected: _config.difficulties.contains('hard'),
                onTap: () => _toggleDifficulty('hard'),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Source document section
          if (widget.sourceDocuments.isNotEmpty) ...[
            Text(
              AppStrings.vocabFilterSource.tr,
              style: AppTypography.label.copyWith(
                color: onSurfaceVariant,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceContainer
                    : AppColors.lightSurfaceContainerLowest,
                borderRadius: AppRadius.smBorder,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _config.sourceDocument,
                  isExpanded: true,
                  hint: Text(
                    AppStrings.vocabFilterAllTime.tr,
                    style: AppTypography.bodyMedium.copyWith(
                      color: onSurfaceVariant,
                    ),
                  ),
                  dropdownColor: isDark
                      ? AppColors.surfaceContainerHigh
                      : AppColors.lightSurface,
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        AppStrings.vocabFilterAllTime.tr,
                        style: AppTypography.bodyMedium.copyWith(
                          color: onSurface,
                        ),
                      ),
                    ),
                    ...widget.sourceDocuments.map(
                      (source) => DropdownMenuItem(
                        value: source,
                        child: Text(
                          source,
                          style: AppTypography.bodyMedium.copyWith(
                            color: onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: _setSource,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Date range section
          Text(
            AppStrings.vocabFilterDateRange.tr,
            style: AppTypography.label.copyWith(
              color: onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              _DateChip(
                label: AppStrings.vocabFilterToday.tr,
                value: 'today',
                isSelected: _config.dateRange == 'today',
                onTap: () => _setDateRange(
                  _config.dateRange == 'today' ? null : 'today',
                ),
                isDark: isDark,
              ),
              _DateChip(
                label: AppStrings.vocabFilterThisWeek.tr,
                value: 'week',
                isSelected: _config.dateRange == 'week',
                onTap: () =>
                    _setDateRange(_config.dateRange == 'week' ? null : 'week'),
                isDark: isDark,
              ),
              _DateChip(
                label: AppStrings.vocabFilterThisMonth.tr,
                value: 'month',
                isSelected: _config.dateRange == 'month',
                onTap: () => _setDateRange(
                  _config.dateRange == 'month' ? null : 'month',
                ),
                isDark: isDark,
              ),
              _DateChip(
                label: AppStrings.vocabFilterAllTime.tr,
                value: 'all',
                isSelected:
                    _config.dateRange == null || _config.dateRange == 'all',
                onTap: () => _setDateRange(null),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Difficulty chip ────────────────────────────────────────────────────────────

class _DifficultyChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _DifficultyChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sxs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : AppColors.transparent,
          borderRadius: AppRadius.fullBorder,
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                      ? AppColors.outlineVariant
                      : AppColors.lightOutlineVariant),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected
                ? color
                : (isDark
                      ? AppColors.onSurfaceVariant
                      : AppColors.lightOnSurfaceVariant),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── Date chip ──────────────────────────────────────────────────────────────────

class _DateChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _DateChip({
    required this.label,
    required this.value,
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
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sxs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primary : surfaceHigh,
          borderRadius: AppRadius.fullBorder,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected
                ? (isDark ? AppColors.onPrimary : AppColors.lightOnPrimary)
                : onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
