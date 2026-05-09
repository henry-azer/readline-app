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

class LibraryBody extends StatelessWidget {
  final LibraryViewModel viewModel;
  final Future<void> Function(DocumentModel) onDeleteDocument;
  final ValueChanged<DocumentModel> onEditDocument;
  final ValueChanged<DocumentModel> onLongPress;
  final FocusNode? searchFocusNode;
  final VoidCallback? onSearchFieldTap;

  const LibraryBody({
    super.key,
    required this.viewModel,
    required this.onDeleteDocument,
    required this.onEditDocument,
    required this.onLongPress,
    this.searchFocusNode,
    this.onSearchFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

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

        return Column(
          children: [
            // Sticky header — title + count, mirrors the vocabulary screen.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.libraryMyLibrary.tr,
                      style: AppTypography.displayMedium.copyWith(
                        color: onSurface,
                      ),
                    ),
                  ),
                  if (totalCount > 0) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
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
                    ),
                  ],
                ],
              ),
            ),

            // Sticky search bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: LibrarySearchBar(
                onChanged: viewModel.setSearchQuery,
                onClear: viewModel.clearSearch,
                focusNode: searchFocusNode,
                onTap: onSearchFieldTap,
              ),
            ),

            // Sticky filter chips
            if (totalCount > 0)
              Padding(
                padding: const EdgeInsets.only(
                    top: AppSpacing.xs, bottom: AppSpacing.md
                ),
                child: LibraryFilterChips(
                  activeFilter: filter,
                  onFilterChanged: viewModel.setFilter,
                  counts: viewModel.filterCounts,
                ),
              ),

            // Pull-to-refresh applies only to the list area — header / search /
            // filters above stay still, matching the vocabulary screen.
            Expanded(
              child: RefreshIndicator(
                color: primary,
                onRefresh: viewModel.refresh,
                child: _buildList(
                  context: context,
                  isDark: isDark,
                  docs: docs,
                  filter: filter,
                  viewMode: viewMode,
                  totalCount: totalCount,
                  selectedIds: selectedIds,
                  isMultiSelect: isMultiSelect,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList({
    required BuildContext context,
    required bool isDark,
    required List<DocumentModel> docs,
    required String filter,
    required ViewMode viewMode,
    required int totalCount,
    required Set<String> selectedIds,
    required bool isMultiSelect,
  }) {
    if (totalCount == 0) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [EmptyLibraryState(isDark: isDark)],
      );
    }
    if (docs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyFilterState(
            filter: filter,
            isDark: isDark,
            searchQuery: viewModel.searchQuery$.value,
          ),
        ],
      );
    }
    return AnimatedSwitcher(
      duration: AppDurations.calm,
      child: viewMode == ViewMode.grid
          ? LibraryGridView(
              key: const ValueKey('grid'),
              docs: docs,
              viewModel: viewModel,
              selectedIds: selectedIds,
              isMultiSelect: isMultiSelect,
              onDeleteDocument: onDeleteDocument,
              onEditDocument: onEditDocument,
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
              onEditDocument: onEditDocument,
              onLongPress: onLongPress,
              searchQuery: viewModel.searchQuery$.value,
            ),
    );
  }
}
