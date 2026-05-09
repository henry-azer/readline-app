import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/router/app_router.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/home/viewmodels/import_content_viewmodel.dart';
import 'package:readline_app/features/home/widgets/import_content_actions.dart';
import 'package:readline_app/widgets/app_snackbar.dart';
import 'package:readline_app/widgets/readline_button.dart';

class ImportContentSheet extends StatefulWidget {
  final VoidCallback? onContentAdded;
  final DocumentModel? existingDocument;

  const ImportContentSheet({
    super.key,
    this.onContentAdded,
    this.existingDocument,
  });

  /// Single canonical entry point to open the import sheet — used by both
  /// the home "Get Started" CTA and the shell's center "+" button so they
  /// behave identically (haptic, transition, modal).
  ///
  /// Pass [navigator] when the caller already has a specific NavigatorState
  /// to push on (e.g. the shell pushing on the active branch's navigator so
  /// the bottom nav bar stays visible). Otherwise the modal pushes on the
  /// nearest navigator above [context]. Optional [existingDocument]
  /// switches the sheet into edit mode.
  static Future<void> show(
    BuildContext context, {
    DocumentModel? existingDocument,
    NavigatorState? navigator,
  }) {
    getIt<HapticService>().light();
    final route = PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: AppColors.barrierOverlay,
      fullscreenDialog: true,
      pageBuilder: (_, _, _) => ImportContentSheet(
        existingDocument: existingDocument,
      ),
      transitionsBuilder: (_, animation, _, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
          child: child,
        );
      },
      transitionDuration: AppDurations.smooth,
      reverseTransitionDuration: AppDurations.calm,
    );
    return (navigator ?? Navigator.of(context)).push(route);
  }

  @override
  State<ImportContentSheet> createState() => _ImportContentSheetState();
}

class _ImportContentSheetState extends State<ImportContentSheet> {
  late final ImportContentViewModel _viewModel;
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    _viewModel = ImportContentViewModel(
      existingDocument: widget.existingDocument,
    );

    final doc = widget.existingDocument;
    if (doc != null) {
      _titleController.text = doc.title;
      _textController.text = doc.extractedText;
    }

    _textController.addListener(
      () => _viewModel.onTextChanged(_textController.text),
    );

    _viewModel.fileTooLargeMb$.listen((maxMb) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        AppStrings.homeImportSheetFileTooLarge.trParams({'n': '$maxMb'}),
      );
    });

    _viewModel.pickedFileName$.listen((fileName) {
      if (!mounted || fileName == null) return;
      if (_titleController.text.trim().isEmpty) {
        final fromFile = _viewModel.defaultTitleFromFile();
        if (fromFile != null) _titleController.text = fromFile;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSaveAndRead() async {
    final doc = await _viewModel.save(
      title: _titleController.text,
      text: _textController.text,
    );
    if (!mounted || doc == null) return;
    widget.onContentAdded?.call();
    context.push('${AppRoutes.reading}/${doc.id}');
    Navigator.of(context).pop();
  }

  Future<void> _handleSaveToLibrary() async {
    final doc = await _viewModel.save(
      title: _titleController.text,
      text: _textController.text,
    );
    if (!mounted) return;
    if (doc == null) {
      AppSnackbar.error(context, AppStrings.errorSomethingWrong.tr);
      return;
    }
    widget.onContentAdded?.call();
    Navigator.of(context).pop();
    AppSnackbar.success(context, AppStrings.homeImportSheetSavedToLibrary.tr);
  }

  Future<void> _handleSaveChanges() async {
    final doc = await _viewModel.saveEdit(
      title: _titleController.text,
      text: _textController.text,
    );
    if (!mounted) return;
    if (doc == null) {
      AppSnackbar.error(context, AppStrings.errorSomethingWrong.tr);
      return;
    }
    widget.onContentAdded?.call();
    Navigator.of(context).pop();
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    final selection = _textController.selection;
    final currentText = _textController.text;
    if (selection.isValid && selection.start >= 0) {
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        text,
      );
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + text.length,
        ),
      );
    } else {
      _textController.text = currentText + text;
      _textController.selection = TextSelection.collapsed(
        offset: _textController.text.length,
      );
    }
  }

  InputDecoration _inputDecoration({
    required bool isDark,
    required String hint,
    String? label,
    String? errorText,
    int? maxLength,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      errorText: errorText,
      counterText: maxLength != null ? null : '',
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: isDark
            ? AppColors.onSurfaceVariant
            : AppColors.lightOnSurfaceVariant,
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: isDark
            ? AppColors.onSurfaceVariant
            : AppColors.lightOnSurfaceVariant,
      ),
      floatingLabelStyle: AppTypography.labelMedium.copyWith(
        color: isDark ? AppColors.primary : AppColors.lightPrimary,
      ),
      filled: true,
      fillColor: isDark
          ? AppColors.surfaceContainerLow
          : AppColors.lightSurfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: AppRadius.mdBorder,
        borderSide: BorderSide(
          color: isDark
              ? AppColors.outlineVariant
              : AppColors.lightOutlineVariant,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBorder,
        borderSide: BorderSide(
          color: isDark
              ? AppColors.outlineVariant
              : AppColors.lightOutlineVariant,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBorder,
        borderSide: BorderSide(
          color: isDark ? AppColors.primary : AppColors.lightPrimary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBorder,
        borderSide: BorderSide(
          color: isDark ? AppColors.error : AppColors.lightError,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final backgroundColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final subtextColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final tertiary = isDark ? AppColors.tertiary : AppColors.lightTertiary;
    final isEdit = _viewModel.isEditMode;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          isEdit
              ? AppStrings.libraryEditDocumentTitle.tr
              : AppStrings.homeImportSheetTitle.tr,
          style: AppTypography.titleMedium.copyWith(color: textColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: _titleController,
              style: AppTypography.bodyLarge.copyWith(color: textColor),
              maxLength: ImportContentViewModel.maxTitleLength,
              decoration: _inputDecoration(
                isDark: isDark,
                hint: AppStrings.homeImportSheetTitleHint.tr,
                label: AppStrings.homeImportSheetTitleLabel.tr,
                maxLength: ImportContentViewModel.maxTitleLength,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Expanded(
              child: StreamBuilder<String?>(
                stream: _viewModel.contentError$,
                builder: (context, errorSnap) {
                  return Stack(
                    children: [
                      TextField(
                        controller: _textController,
                        style: AppTypography.bodyLarge.copyWith(
                          color: textColor,
                        ),
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: _inputDecoration(
                          isDark: isDark,
                          hint: AppStrings.homeImportSheetHint.tr,
                          errorText: errorSnap.data,
                        ),
                      ),
                      Positioned(
                        right: AppSpacing.xs,
                        top: AppSpacing.xs,
                        child: GestureDetector(
                          onTap: _handlePaste,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sxs),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceContainerHigh
                                  : AppColors.lightSurfaceContainerHigh,
                              borderRadius: AppRadius.smBorder,
                            ),
                            child: Icon(
                              Icons.content_paste_rounded,
                              size: 18,
                              color: subtextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            StreamBuilder<int>(
              stream: _viewModel.wordCount$,
              builder: (context, snap) {
                final wordCount = snap.data ?? 0;
                final showRow = wordCount > 0 || _textController.text.isNotEmpty;
                if (!showRow) return const SizedBox.shrink();
                final showWarning = _textController.text.length >
                    ImportContentViewModel.performanceWarningThreshold;
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxs),
                  child: Row(
                    children: [
                      Text(
                        AppStrings.homeImportSheetWordCount.trParams({
                          'n': '$wordCount',
                        }),
                        style: AppTypography.homeShelfMeta.copyWith(
                          color: subtextColor,
                        ),
                      ),
                      if (showWarning) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: tertiary,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            AppStrings.homeImportSheetPerformanceWarning.tr,
                            style: AppTypography.homeBadgeLabel.copyWith(
                              color: tertiary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),

            StreamBuilder<String?>(
              stream: _viewModel.pickedFileName$,
              builder: (context, snap) {
                final fileName = snap.data;
                if (fileName == null) return const SizedBox.shrink();
                final fileType = _viewModel.pickedFileType$.value;
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryContainer
                          : AppColors.lightPrimaryContainer,
                      borderRadius: AppRadius.smBorder,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          fileType == 'pdf'
                              ? Icons.picture_as_pdf_rounded
                              : Icons.description_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.primary
                              : AppColors.lightOnPrimary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            fileName,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.primary
                                  : AppColors.lightOnPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: _viewModel.clearFile,
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.primary
                                : AppColors.lightOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xxl,
                  bottom: AppSpacing.xl,
                ),
                child: StreamBuilder<bool>(
                  stream: _viewModel.isProcessing$,
                  builder: (context, procSnap) {
                    final isProcessing = procSnap.data ?? false;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isProcessing)
                          SizedBox(
                            height: AppSpacing.buttonHeight,
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(primary),
                                ),
                              ),
                            ),
                          )
                        else if (isEdit) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ReadlineButton(
                              label: AppStrings.librarySaveChanges.tr,
                              icon: Icons.save_rounded,
                              onTap: _handleSaveChanges,
                            ),
                          ),
                        ] else
                          ImportContentActions(
                            viewModel: _viewModel,
                            textController: _textController,
                            onSaveAndRead: _handleSaveAndRead,
                            onSaveToLibrary: _handleSaveToLibrary,
                          ),
                        if (!isEdit) ...[
                          const SizedBox(height: AppSpacing.sm),
                          TextButton.icon(
                            onPressed: isProcessing ? null : _viewModel.pickFile,
                            icon: Icon(
                              Icons.attach_file_rounded,
                              size: 18,
                              color: subtextColor,
                            ),
                            label: Text(
                              AppStrings.homeImportSheetPickFile.tr,
                              style: AppTypography.bodyMedium.copyWith(
                                color: subtextColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

