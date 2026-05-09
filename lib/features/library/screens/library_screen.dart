import 'package:flutter/material.dart';
import 'package:readline_app/app.dart'
    show
        libraryChangeNotifier,
        preferencesChangeNotifier,
        sessionChangeNotifier;
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/widgets/app_snackbar.dart';
import 'package:readline_app/widgets/brand_mark.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/home/widgets/import_content_sheet.dart';
import 'package:readline_app/features/library/viewmodels/library_viewmodel.dart';
import 'package:readline_app/features/library/widgets/library_body.dart';
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
    preferencesChangeNotifier.addListener(_onPreferencesChanged);
    sessionChangeNotifier.addListener(_onSessionChanged);
  }

  void _onLibraryChanged() => _viewModel.refresh();

  // WPM (and other prefs the tile estimates depend on) changed elsewhere —
  // re-run refresh so the cached `currentWpm` and any derived display data
  // get re-read from prefs immediately.
  void _onPreferencesChanged() => _viewModel.refresh();

  // A reading session was saved → the actual-minutes total for that doc
  // changed. Refresh so completed-doc tiles reflect real time spent
  // without waiting for a navigation cycle.
  void _onSessionChanged() => _viewModel.refresh();

  void _onSearchFieldTap() => getIt<HapticService>().light();

  @override
  void dispose() {
    libraryChangeNotifier.removeListener(_onLibraryChanged);
    preferencesChangeNotifier.removeListener(_onPreferencesChanged);
    sessionChangeNotifier.removeListener(_onSessionChanged);
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
    // Route edit through the same full-screen page that the add flow uses,
    // so both screens render the identical AppBar treatment.
    // Library refresh is driven by libraryChangeNotifier from the viewmodel,
    // so we don't need onContentAdded here.
    ImportContentSheet.show(context, existingDocument: document);
  }

  Future<void> _handleDelete(DocumentModel document) async {
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
          return NewReadingFab(onPressed: _openImportSheet);
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

            return LibraryBody(
              viewModel: _viewModel,
              onDeleteDocument: _handleDelete,
              onEditDocument: _openEditSheet,
              searchFocusNode: _searchFocusNode,
              onSearchFieldTap: _onSearchFieldTap,
            );
          },
        ),
      ),
    );
  }
}

