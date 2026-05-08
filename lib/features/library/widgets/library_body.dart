import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/enums/view_mode.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/library/viewmodels/library_viewmodel.dart'
    show LibraryBodyState, LibraryViewModel;
import 'package:readline_app/features/library/widgets/empty_filter_state.dart';
import 'package:readline_app/features/library/widgets/empty_library_state.dart';
import 'package:readline_app/features/library/widgets/filter_chips.dart';
import 'package:readline_app/features/library/widgets/library_grid_view.dart';
import 'package:readline_app/features/library/widgets/library_list_view.dart';
import 'package:readline_app/features/library/widgets/library_search_bar.dart';
import 'package:readline_app/features/library/widgets/library_sort_menu.dart';
import 'package:readline_app/features/library/widgets/view_mode_toggle.dart';

class LibraryBody extends StatelessWidget {
  final LibraryViewModel viewModel;
  final Future<void> Function(DocumentModel) onDeleteDocument;
  final ValueChanged<DocumentModel> onEditDocument;
  final ValueChanged<DocumentModel> onLongPress;

  const LibraryBody({
    super.key,
    required this.viewModel,
    required this.onDeleteDocument,
    required this.onEditDocument,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return StreamBuilder<LibraryBodyState>(
      stream: viewModel.bodyState$,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final docs = state?.docs ?? const [];
        final filter = state?.filter ?? 'all';
        final viewMode = state?.viewMode ?? ViewMode.grid;
        final totalCount = viewModel.documentCount;
        final selectedIds = state?.selectedIds ?? const <String>{};
        final isMultiSelect = state?.isMultiSelect ?? false;
        final sortField = state?.sortField ?? 'lastRead';
        final sortAsc = state?.sortAsc ?? false;

        return _buildContent(
          context: context,
          isDark: isDark,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          docs: docs,
          filter: filter,
          viewMode: viewMode,
          totalCount: totalCount,
          selectedIds: selectedIds,
          isMultiSelect: isMultiSelect,
          sortField: sortField,
          sortAsc: sortAsc,
        );
      },
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required bool isDark,
    required Color onSurface,
    required Color onSurfaceVariant,
    required List<DocumentModel> docs,
    required String filter,
    required ViewMode viewMode,
    required int totalCount,
    required Set<String> selectedIds,
    required bool isMultiSelect,
    required String sortField,
    required bool sortAsc,
  }) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Header: "My Library" + count + sort + view toggle
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.libraryMyLibrary.tr,
                        style: AppTypography.displayMedium.copyWith(
                          color: onSurface,
                        ),
                      ),
                      if (totalCount > 0) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          totalCount == 1
                              ? AppStrings.libraryActiveDocument.trParams({
                                  'n': '$totalCount',
                                })
                              : AppStrings.libraryActiveDocuments.trParams({
                                  'n': '$totalCount',
                                }),
                          style: AppTypography.label.copyWith(
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (totalCount > 0) ...[
                  // Sort menu
                  LibrarySortMenu(
                    currentField: sortField,
                    isAscending: sortAsc,
                    onFieldChanged: viewModel.setSortField,
                    onDirectionToggled: viewModel.toggleSortDirection,
                  ),
                  // View mode toggle
                  ViewModeToggle(
                    viewMode: viewMode,
                    onToggle: viewModel.toggleViewMode,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              bottom: AppSpacing.xs,
            ),
            child: LibrarySearchBar(
              onChanged: viewModel.setSearchQuery,
              onClear: viewModel.clearSearch,
            ),
          ),
        ),

        // Filter chips
        if (totalCount > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: LibraryFilterChips(
                activeFilter: filter,
                onFilterChanged: viewModel.setFilter,
                counts: viewModel.filterCounts,
              ),
            ),
          ),

        // Documents grid / list
        if (totalCount == 0)
          // True empty state — no documents at all
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyLibraryState(isDark: isDark),
          )
        else if (docs.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyFilterState(
              filter: filter,
              isDark: isDark,
              searchQuery: viewModel.searchQuery$.value,
            ),
          )
        else
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: AppDurations.calm,
              child: viewMode == ViewMode.grid
                  ? LibraryGridView(
                      key: const ValueKey('grid'),
                      docs: docs,
                      viewModel: viewModel,
                      selectedIds: selectedIds,
                      isMultiSelect: isMultiSelect,
                      onDeleteDocument: onDeleteDocument,
                      onLongPress: onLongPress,
                      searchQuery: viewModel.searchQuery$.value,
                    )
                  : LibraryListView(
                      key: const ValueKey('list'),
                      docs: docs,
                      viewModel: viewModel,
                      selectedIds: selectedIds,
                      isMultiSelect: isMultiSelect,
                      onDeleteDocument: onDeleteDocument,
                      onLongPress: onLongPress,
                      searchQuery: viewModel.searchQuery$.value,
                    ),
            ),
          ),
      ],
    );
  }
}
