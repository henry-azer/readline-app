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
import 'package:read_it/presentation/widgets/brand_mark.dart';
import 'package:read_it/data/models/document_model.dart';
import 'package:read_it/presentation/home/widgets/import_content_sheet.dart';
import 'package:read_it/presentation/library/viewmodels/library_viewmodel.dart';
import 'package:read_it/presentation/library/widgets/library_body.dart';
import 'package:read_it/presentation/library/widgets/library_filter_sheet.dart';
import 'package:read_it/presentation/library/widgets/multi_select_toolbar.dart';
import 'package:read_it/presentation/library/widgets/new_reading_fab.dart';

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

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (ctx) => LibraryFilterSheet(
        selectedStatuses: _viewModel.filterStatuses$.value,
        selectedSourceTypes: _viewModel.filterSourceTypes$.value,
        selectedDateRange: _viewModel.filterDateRange$.value,
        onStatusChanged: _viewModel.setFilterStatuses,
        onSourceTypeChanged: _viewModel.setFilterSourceTypes,
        onDateRangeChanged: _viewModel.setFilterDateRange,
        onClearAll: _viewModel.clearAllAdvancedFilters,
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
    final onPrimary = isDark ? AppColors.onPrimary : AppColors.lightOnPrimary;

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
          StreamBuilder<int>(
            stream: _viewModel.activeFilterCount$,
            initialData: _viewModel.activeFilterCount,
            builder: (context, snap) {
              final activeCount = snap.data ?? 0;
              return IconButton(
                icon: Badge(
                  isLabelVisible: activeCount > 0,
                  backgroundColor: primary,
                  textColor: onPrimary,
                  textStyle: AppTypography.labelMicro,
                  label: Text('$activeCount'),
                  child: Icon(Icons.tune_rounded, color: onSurfaceVariant),
                ),
                onPressed: _openFilterSheet,
              );
            },
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
                child: LibraryBody(
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
