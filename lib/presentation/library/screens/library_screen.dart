import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/router/app_router.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/widgets/brand_mark.dart';
import 'package:read_it/data/enums/app_enums.dart';
import 'package:read_it/data/models/pdf_document_model.dart';
import 'package:read_it/presentation/library/viewmodels/library_viewmodel.dart';
import 'package:read_it/presentation/library/widgets/document_grid_card.dart';
import 'package:read_it/presentation/library/widgets/document_list_tile.dart';
import 'package:read_it/presentation/library/widgets/filter_chips.dart';
import 'package:read_it/presentation/library/widgets/import_fab.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final LibraryViewModel _viewModel;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _viewModel = LibraryViewModel();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleImport() async {
    setState(() => _isImporting = true);
    final success = await _viewModel.importDocument();
    if (mounted) {
      setState(() => _isImporting = false);
      if (!success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppStrings.errorImportPdf.tr)));
      }
    }
  }

  Future<void> _confirmDelete(PdfDocumentModel document) async {
    await _viewModel.deleteDocument(document.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.libraryRemoveBody.trParams({'title': document.title}),
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _viewModel.undoDelete(document),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
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
        leading: const BrandMark(),
        leadingWidth: 100,
        title: Text(
          AppStrings.libraryTitle.tr,
          style: AppTypography.titleLarge.copyWith(color: onSurface),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: StreamBuilder<bool>(
        stream: _viewModel.isLoading$,
        builder: (context, loadingSnap) {
          final isLoading = loadingSnap.data ?? true;

          if (isLoading) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          return RefreshIndicator(
            color: primary,
            onRefresh: _viewModel.refresh,
            child: _LibraryBody(
              viewModel: _viewModel,
              onImport: _handleImport,
              onDeleteDocument: _confirmDelete,
              isImporting: _isImporting,
            ),
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
  final Future<void> Function(PdfDocumentModel) onDeleteDocument;
  final bool isImporting;

  const _LibraryBody({
    required this.viewModel,
    required this.onImport,
    required this.onDeleteDocument,
    required this.isImporting,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return StreamBuilder<List<PdfDocumentModel>>(
      stream: viewModel.documents$,
      builder: (context, docsSnap) {
        return StreamBuilder<String>(
          stream: viewModel.activeFilter$,
          builder: (context, filterSnap) {
            return StreamBuilder<ViewMode>(
              stream: viewModel.viewMode$,
              builder: (context, modeSnap) {
                final docs = docsSnap.data ?? const [];
                final filter = filterSnap.data ?? 'all';
                final viewMode = modeSnap.data ?? ViewMode.grid;
                final totalCount = viewModel.documentCount;

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header: "My Library" + count + view toggle
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
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    totalCount == 1
                                        ? AppStrings.libraryActiveDocument
                                              .trParams({'n': '$totalCount'})
                                        : AppStrings.libraryActiveDocuments
                                              .trParams({'n': '$totalCount'}),
                                    style: AppTypography.label.copyWith(
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // View mode toggle
                            _ViewModeToggle(
                              viewMode: viewMode,
                              onToggle: viewModel.toggleViewMode,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Filter chips
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: LibraryFilterChips(
                          activeFilter: filter,
                          onFilterChanged: viewModel.setFilter,
                        ),
                      ),
                    ),

                    // Documents grid / list
                    if (docs.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(
                          filter: filter,
                          isDark: isDark,
                          onImport: onImport,
                        ),
                      )
                    else if (viewMode == ViewMode.grid)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          // Extra bottom padding for FAB clearance
                          AppSpacing.xxxxl + AppSpacing.xxl,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                                childAspectRatio: 0.65,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final doc = docs[index];
                            return DocumentGridCard(
                              document: doc,
                              onTap: () =>
                                  context.go('${AppRoutes.reading}/${doc.id}'),
                              onDelete: () => onDeleteDocument(doc),
                            );
                          }, childCount: docs.length),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.xxxxl + AppSpacing.xxl,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final doc = docs[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: DocumentListTile(
                                document: doc,
                                onTap: () => context.go(
                                  '${AppRoutes.reading}/${doc.id}',
                                ),
                                onDelete: () => onDeleteDocument(doc),
                              ),
                            );
                          }, childCount: docs.length),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

// ── View mode toggle ─────────────────────────────────────────────────────────

class _ViewModeToggle extends StatelessWidget {
  final ViewMode viewMode;
  final VoidCallback onToggle;
  final bool isDark;

  const _ViewModeToggle({
    required this.viewMode,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceHigh = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: surfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleIcon(
            icon: Icons.grid_view_rounded,
            isSelected: viewMode == ViewMode.grid,
            onTap: onToggle,
            primary: primary,
            onSurfaceVariant: onSurfaceVariant,
            surfaceHigh: surfaceHigh,
            isDark: isDark,
          ),
          _ToggleIcon(
            icon: Icons.list_rounded,
            isSelected: viewMode == ViewMode.list,
            onTap: onToggle,
            primary: primary,
            onSurfaceVariant: onSurfaceVariant,
            surfaceHigh: surfaceHigh,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primary;
  final Color onSurfaceVariant;
  final Color surfaceHigh;
  final bool isDark;

  const _ToggleIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.primary,
    required this.onSurfaceVariant,
    required this.surfaceHigh,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBg = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerHighest;

    return GestureDetector(
      onTap: isSelected ? null : onTap,
      child: AnimatedContainer(
        duration: AppDurations.short,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? primary : onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;
  final bool isDark;
  final VoidCallback onImport;

  const _EmptyState({
    required this.filter,
    required this.isDark,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final (headline, subtext) = switch (filter) {
      'reading' => (
        AppStrings.libraryEmptyReading.tr,
        AppStrings.libraryEmptyReadingBody.tr,
      ),
      'completed' => (
        AppStrings.libraryEmptyCompleted.tr,
        AppStrings.libraryEmptyCompletedBody.tr,
      ),
      _ => (AppStrings.libraryEmptyAll.tr, AppStrings.libraryEmptyAllBody.tr),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              headline,
              style: AppTypography.headlineMedium.copyWith(color: onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtext,
              style: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (filter == 'all') ...[
              const SizedBox(height: AppSpacing.xl),
              ImportFab(onPressed: onImport),
            ],
          ],
        ),
      ),
    );
  }
}
