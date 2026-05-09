import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/library/widgets/library_filter_section_label.dart';
import 'package:readline_app/features/library/widgets/library_filter_sheet_chip.dart';

class LibraryFilterSheet extends StatefulWidget {
  final Set<String> selectedStatuses;
  final Set<String> selectedSourceTypes;
  final String? selectedDateRange;
  final ValueChanged<Set<String>> onStatusChanged;
  final ValueChanged<Set<String>> onSourceTypeChanged;
  final ValueChanged<String?> onDateRangeChanged;
  final VoidCallback onClearAll;

  const LibraryFilterSheet({
    super.key,
    required this.selectedStatuses,
    required this.selectedSourceTypes,
    this.selectedDateRange,
    required this.onStatusChanged,
    required this.onSourceTypeChanged,
    required this.onDateRangeChanged,
    required this.onClearAll,
  });

  @override
  State<LibraryFilterSheet> createState() => _LibraryFilterSheetState();
}

class _LibraryFilterSheetState extends State<LibraryFilterSheet> {
  late Set<String> _statuses;
  late Set<String> _sourceTypes;
  late String? _dateRange;

  @override
  void initState() {
    super.initState();
    _statuses = Set.from(widget.selectedStatuses);
    _sourceTypes = Set.from(widget.selectedSourceTypes);
    _dateRange = widget.selectedDateRange;
  }

  void _toggleStatus(String status) {
    setState(() {
      if (_statuses.contains(status)) {
        _statuses.remove(status);
      } else {
        _statuses.add(status);
      }
    });
    widget.onStatusChanged(Set.from(_statuses));
  }

  void _toggleSourceType(String type) {
    setState(() {
      if (_sourceTypes.contains(type)) {
        _sourceTypes.remove(type);
      } else {
        _sourceTypes.add(type);
      }
    });
    widget.onSourceTypeChanged(Set.from(_sourceTypes));
  }

  void _setDateRange(String? range) {
    setState(() => _dateRange = _dateRange == range ? null : range);
    widget.onDateRangeChanged(_dateRange);
  }

  void _clearAll() {
    setState(() {
      _statuses.clear();
      _sourceTypes.clear();
      _dateRange = null;
    });
    widget.onClearAll();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final subtextColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    final hasActive =
        _statuses.isNotEmpty || _sourceTypes.isNotEmpty || _dateRange != null;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
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
                    color: subtextColor.withValues(alpha: 0.3),
                    borderRadius: AppRadius.fullBorder,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title + Clear
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.libraryFilterTitle.tr,
                    style: AppTypography.headlineMedium.copyWith(
                      color: textColor,
                    ),
                  ),
                  if (hasActive)
                    GestureDetector(
                      onTap: _clearAll,
                      child: Text(
                        AppStrings.libraryFilterClearAll.tr,
                        style: AppTypography.labelMedium.copyWith(
                          color: primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Status section
              LibraryFilterSectionLabel(
                label: AppStrings.libraryFilterStatus.tr,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  LibraryFilterSheetChip(
                    label: AppStrings.libraryFilterNotStarted.tr,
                    isSelected: _statuses.contains('unread'),
                    onTap: () => _toggleStatus('unread'),
                    isDark: isDark,
                  ),
                  LibraryFilterSheetChip(
                    label: AppStrings.libraryFilterReading.tr,
                    isSelected: _statuses.contains('reading'),
                    onTap: () => _toggleStatus('reading'),
                    isDark: isDark,
                  ),
                  LibraryFilterSheetChip(
                    label: AppStrings.libraryFilterCompleted.tr,
                    isSelected: _statuses.contains('completed'),
                    onTap: () => _toggleStatus('completed'),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Source type section
              LibraryFilterSectionLabel(
                label: AppStrings.libraryFilterSourceType.tr,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  LibraryFilterSheetChip(
                    label: AppStrings.documentSourceTypeTextInput.tr,
                    isSelected: _sourceTypes.contains('text_input'),
                    onTap: () => _toggleSourceType('text_input'),
                    isDark: isDark,
                  ),
                  LibraryFilterSheetChip(
                    label: AppStrings.documentSourceTypePdf.tr,
                    isSelected: _sourceTypes.contains('pdf'),
                    onTap: () => _toggleSourceType('pdf'),
                    isDark: isDark,
                  ),
                  LibraryFilterSheetChip(
                    label: AppStrings.documentSourceTypeTxt.tr,
                    isSelected: _sourceTypes.contains('txt'),
                    onTap: () => _toggleSourceType('txt'),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date range section
              LibraryFilterSectionLabel(
                label: AppStrings.libraryFilterDateRange.tr,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  LibraryFilterSheetChip(
                    label: AppStrings.libraryFilterToday.tr,
                    isSelected: _dateRange == 'today',
                    onTap: () => _setDateRange('today'),
                    isDark: isDark,
                  ),
                  LibraryFilterSheetChip(
                    label: AppStrings.libraryFilterThisWeek.tr,
                    isSelected: _dateRange == 'thisWeek',
                    onTap: () => _setDateRange('thisWeek'),
                    isDark: isDark,
                  ),
                  LibraryFilterSheetChip(
                    label: AppStrings.libraryFilterThisMonth.tr,
                    isSelected: _dateRange == 'thisMonth',
                    onTap: () => _setDateRange('thisMonth'),
                    isDark: isDark,
                  ),
                  LibraryFilterSheetChip(
                    label: AppStrings.libraryFilterAllTime.tr,
                    isSelected: _dateRange == null,
                    onTap: () => _setDateRange(null),
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

