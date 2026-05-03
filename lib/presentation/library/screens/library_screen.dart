import 'package:flutter/material.dart';
import 'package:read_it/app.dart' show libraryChangeNotifier;
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/router/app_router.dart';
import 'package:read_it/data/enums/app_enums.dart';
import 'package:read_it/presentation/widgets/brand_mark.dart';
import 'package:read_it/data/models/document_model.dart';
import 'package:read_it/presentation/home/widgets/import_content_sheet.dart';
import 'package:read_it/presentation/library/viewmodels/library_viewmodel.dart'
    show LibraryBodyState, LibraryViewModel;
import 'package:read_it/presentation/library/widgets/empty_filter_state.dart';
import 'package:read_it/presentation/library/widgets/empty_library_state.dart';
import 'package:read_it/presentation/library/widgets/filter_chips.dart';
import 'package:read_it/presentation/library/widgets/library_grid_view.dart';
import 'package:read_it/presentation/library/widgets/library_list_view.dart';
import 'package:read_it/presentation/library/widgets/library_search_bar.dart';
import 'package:read_it/presentation/library/widgets/library_sort_menu.dart';
import 'package:read_it/presentation/library/widgets/multi_select_toolbar.dart';
import 'package:read_it/presentation/library/widgets/new_reading_fab.dart';
import 'package:read_it/presentation/library/widgets/view_mode_toggle.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final LibraryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LibraryViewModel();
    _viewModel.init();
    libraryChangeNotifier.addListener(_onLibraryChanged);
  }

  void _onLibraryChanged() => _viewModel.refresh();

  @override
  void dispose() {
    libraryChangeNotifier.removeListener(_onLibraryChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _openImportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.transparent,
      builder: (ctx) =>
          ImportContentSheet(onContentAdded: () => _viewModel.refresh()),
    );
  }

  void _openEditSheet(DocumentModel document) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.transparent,
      builder: (ctx) => ImportContentSheet(
        onContentAdded: () => _viewModel.refresh(),
        existingDocument: document,
      ),
    );
  }

  Future<void> _confirmDelete(DocumentModel document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = context.isDark;
        final textColor = isDark
            ? AppColors.onSurface
            : AppColors.lightOnSurface;
        final subtextColor = isDark
            ? AppColors.onSurfaceVariant
            : AppColors.lightOnSurfaceVariant;
        final errorColor = isDark ? AppColors.error : AppColors.lightError;
        final bgColor = isDark
            ? AppColors.surfaceContainerHigh
            : AppColors.lightSurfaceContainerLowest;

        return AlertDialog(
          backgroundColor: bgColor,
          title: Text(
            AppStrings.libraryDeleteConfirmTitle.tr,
            style: AppTypography.titleMedium.copyWith(color: textColor),
          ),
          content: Text(
            AppStrings.libraryDeleteConfirmBody.trParams({
              'title': document.title,
            }),
            style: AppTypography.bodyMedium.copyWith(color: subtextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                AppStrings.cancel.tr,
                style: AppTypography.button.copyWith(color: subtextColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                AppStrings.remove.tr,
                style: AppTypography.button.copyWith(color: errorColor),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _viewModel.deleteDocument(document.id);
    libraryChangeNotifier.value++;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.libraryRemoveBody.trParams({'title': document.title}),
        ),
        duration: AppDurations.snackbarLong,
        action: SnackBarAction(
          label: AppStrings.undo.tr,
          onPressed: () {
            _viewModel.undoDelete(document);
            libraryChangeNotifier.value++;
          },
        ),
      ),
    );
  }

  void _showDocumentContextMenu(DocumentModel doc) {
    final isDark = context.isDark;
    final textColor = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final subtextColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final errorColor = isDark ? AppColors.error : AppColors.lightError;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
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
              const SizedBox(height: AppSpacing.lg),

              // Document title
              Text(
                doc.title,
                style: AppTypography.titleMedium.copyWith(color: textColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Edit
              _ContextMenuItem(
                icon: Icons.edit_rounded,
                label: AppStrings.libraryEditDocument.tr,
                color: textColor,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openEditSheet(doc);
                },
              ),

              // Select multiple
              _ContextMenuItem(
                icon: Icons.checklist_rounded,
                label: AppStrings.librarySelectMultiple.tr,
                color: textColor,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _viewModel.activateMultiSelectWith(doc.id);
                },
              ),

              // Delete
              _ContextMenuItem(
                icon: Icons.delete_outline_rounded,
                label: AppStrings.libraryDeleteAction.tr,
                color: errorColor,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _confirmDelete(doc);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: AppSpacing.lg,
        title: const BrandMark(),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.auto_stories_rounded, color: onSurfaceVariant),
            onPressed: () => context.push(AppRoutes.vocabulary),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<List<DocumentModel>>(
        stream: _viewModel.allDocuments$,
        builder: (context, snap) {
          final docs = snap.data ?? const [];
          if (docs.isEmpty) return const SizedBox.shrink();
          return StreamBuilder<bool>(
            stream: _viewModel.isMultiSelectMode$,
            builder: (context, multiSnap) {
              if (multiSnap.data ?? false) return const SizedBox.shrink();
              return NewReadingFab(onPressed: _openImportSheet);
            },
          );
        },
      ),
      body: StreamBuilder<bool>(
        stream: _viewModel.isLoading$,
        builder: (context, loadingSnap) {
          final isLoading = loadingSnap.data ?? true;

          if (isLoading) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          return Stack(
            children: [
              RefreshIndicator(
                color: primary,
                onRefresh: _viewModel.refresh,
                child: _LibraryBody(
                  viewModel: _viewModel,
                  onImport: _openImportSheet,
                  onDeleteDocument: _confirmDelete,
                  onEditDocument: _openEditSheet,
                  onLongPress: _showDocumentContextMenu,
                ),
              ),

              // Multi-select toolbar overlay
              StreamBuilder<bool>(
                stream: _viewModel.isMultiSelectMode$,
                builder: (context, multiSnap) {
                  if (!(multiSnap.data ?? false)) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: AppSpacing.xl,
                    child: StreamBuilder<Set<String>>(
                      stream: _viewModel.selectedIds$,
                      builder: (context, selSnap) {
                        return MultiSelectToolbar(
                          selectedCount: (selSnap.data ?? {}).length,
                          onCancel: _viewModel.exitMultiSelect,
                          onDelete: () async {
                            await _viewModel.deleteSelectedDocuments();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _LibraryBody extends StatelessWidget {
  final LibraryViewModel viewModel;
  final VoidCallback onImport;
  final Future<void> Function(DocumentModel) onDeleteDocument;
  final ValueChanged<DocumentModel> onEditDocument;
  final ValueChanged<DocumentModel> onLongPress;

  const _LibraryBody({
    required this.viewModel,
    required this.onImport,
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

// ── Context menu item ───────────────────────────────────────────────────────

class _ContextMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContextMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
