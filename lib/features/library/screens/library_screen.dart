import 'package:flutter/material.dart';
import 'package:readline_app/app.dart' show libraryChangeNotifier;
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/app_snackbar.dart';
import 'package:readline_app/widgets/brand_mark.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/home/widgets/import_content_sheet.dart';
import 'package:readline_app/features/library/viewmodels/library_viewmodel.dart';
import 'package:readline_app/features/library/widgets/library_body.dart';
import 'package:readline_app/features/library/widgets/multi_select_toolbar.dart';
import 'package:readline_app/features/library/widgets/new_reading_fab.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final LibraryViewModel _viewModel;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = LibraryViewModel();
    _viewModel.init();
    libraryChangeNotifier.addListener(_onLibraryChanged);
  }

  void _onLibraryChanged() => _viewModel.refresh();

  void _onSearchFieldTap() => getIt<HapticService>().light();

  @override
  void dispose() {
    libraryChangeNotifier.removeListener(_onLibraryChanged);
    _searchFocusNode.dispose();
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
    AppSnackbar.info(
      context,
      AppStrings.libraryRemoveBody.trParams({'title': document.title}),
      actionLabel: AppStrings.undo.tr,
      onAction: () {
        _viewModel.undoDelete(document);
        libraryChangeNotifier.value++;
      },
    );
  }

  // Long-press now activates multi-select directly — the previous bottom-sheet
  // popup is gone; per-doc edit / delete actions live as inline icon buttons
  // on each card / tile.
  void _activateMultiSelect(DocumentModel doc) =>
      _viewModel.activateMultiSelectWith(doc.id);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: AppSpacing.xl,
        title: const BrandMark(),
        centerTitle: false,
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
      // Tap anywhere outside the search field to dismiss the keyboard —
      // mirrors the vocabulary screen behavior.
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_searchFocusNode.hasFocus) _searchFocusNode.unfocus();
        },
        child: StreamBuilder<bool>(
          stream: _viewModel.isLoading$,
          builder: (context, loadingSnap) {
            final isLoading = loadingSnap.data ?? true;

            if (isLoading) {
              return Center(child: CircularProgressIndicator(color: primary));
            }

            return Stack(
              children: [
                LibraryBody(
                  viewModel: _viewModel,
                  onDeleteDocument: _confirmDelete,
                  onEditDocument: _openEditSheet,
                  onLongPress: _activateMultiSelect,
                  searchFocusNode: _searchFocusNode,
                  onSearchFieldTap: _onSearchFieldTap,
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
      ),
    );
  }
}

