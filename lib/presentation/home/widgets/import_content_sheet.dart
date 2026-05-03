import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/app.dart' show libraryChangeNotifier;
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/router/app_router.dart';
import 'package:read_it/core/services/pdf_processing_service.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/contracts/document_repository.dart';
import 'package:read_it/data/models/document_model.dart';
import 'package:read_it/presentation/widgets/read_it_button.dart';

class ImportContentSheet extends StatefulWidget {
  final VoidCallback? onContentAdded;
  final DocumentModel? existingDocument;

  const ImportContentSheet({
    super.key,
    this.onContentAdded,
    this.existingDocument,
  });

  @override
  State<ImportContentSheet> createState() => _ImportContentSheetState();
}

class _ImportContentSheetState extends State<ImportContentSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _textController = TextEditingController();

  String? _pickedFilePath;
  String? _pickedFileName;
  String? _pickedFileType; // 'pdf', 'txt'
  bool _isProcessing = false;
  int _wordCount = 0;
  Timer? _wordCountDebounce;
  String? _titleError;
  String? _contentError;
  bool _contentChanged = false;

  static const int _maxTitleLength = 100;
  static const int _maxDescLength = 500;
  static const int _performanceWarningThreshold = 100000;
  static const int _maxPdfSizeMb = 50;
  static const int _maxTxtSizeMb = 10;

  bool get _isEditMode => widget.existingDocument != null;

  bool get _hasContent =>
      _textController.text.trim().isNotEmpty || _pickedFilePath != null;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);

    // Pre-fill for edit mode
    final doc = widget.existingDocument;
    if (doc != null) {
      _titleController.text = doc.title;
      _descController.text = doc.description ?? '';
      _textController.text = doc.extractedText;
      _wordCount = doc.totalWords;
    }
  }

  @override
  void dispose() {
    _wordCountDebounce?.cancel();
    _titleController.dispose();
    _descController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _wordCountDebounce?.cancel();
    _wordCountDebounce = Timer(AppDurations.debounce, () {
      if (!mounted) return;
      final text = _textController.text.trim();
      final count = text.isEmpty
          ? 0
          : text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      setState(() {
        _wordCount = count;
        _contentError = null;
      });
    });
    // Track content changes in edit mode
    if (_isEditMode && !_contentChanged) {
      final originalText = widget.existingDocument!.extractedText;
      if (_textController.text.trim() != originalText.trim()) {
        setState(() => _contentChanged = true);
      }
    }
    if (_contentError != null) {
      setState(() => _contentError = null);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'md'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileSize = await file.length();
      final ext = result.files.single.extension?.toLowerCase() ?? '';

      final maxBytes =
          (ext == 'pdf' ? _maxPdfSizeMb : _maxTxtSizeMb) * 1024 * 1024;
      if (fileSize > maxBytes) {
        if (!mounted) return;
        final maxMb = ext == 'pdf' ? _maxPdfSizeMb : _maxTxtSizeMb;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.homeImportSheetFileTooLarge.trParams({'n': '$maxMb'}),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final fileName = result.files.single.name;
      final sourceType = ext == 'pdf' ? 'pdf' : 'txt';

      setState(() {
        _pickedFilePath = result.files.single.path;
        _pickedFileName = fileName;
        _pickedFileType = sourceType;
        _contentError = null;
        _contentChanged = true;
      });

      if (_titleController.text.trim().isEmpty) {
        final nameWithoutExt = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
        _titleController.text = nameWithoutExt;
      }
    }
  }

  bool _validate() {
    bool valid = true;

    if (!_hasContent && !_isEditMode) {
      setState(() {
        _contentError = AppStrings.homeImportSheetContentRequired.tr;
      });
      valid = false;
    }

    return valid;
  }

  String _resolveTitle() {
    final title = _titleController.text.trim();
    if (title.isNotEmpty) return title;

    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final firstLine = text.split('\n').first.trim();
      if (firstLine.isNotEmpty) {
        return firstLine.length > _maxTitleLength
            ? firstLine.substring(0, _maxTitleLength)
            : firstLine;
      }
    }

    if (_pickedFileName != null) {
      return _pickedFileName!.replaceAll(RegExp(r'\.[^.]+$'), '');
    }

    return AppStrings.homeImportSheetUntitled.tr;
  }

  Future<DocumentModel> _processContent() async {
    final pdfService = getIt<PdfProcessingService>();

    if (_pickedFilePath != null) {
      if (_pickedFileType == 'pdf') {
        return await pdfService.processFile(File(_pickedFilePath!));
      } else {
        final file = File(_pickedFilePath!);
        String text;
        try {
          text = await file.readAsString(encoding: utf8);
        } catch (_) {
          text = await file.readAsString(encoding: latin1);
        }
        return await pdfService.processSampleText(text);
      }
    }

    return await pdfService.processSampleText(_textController.text.trim());
  }

  Future<void> _saveAndRead() async {
    if (!_validate()) return;
    setState(() => _isProcessing = true);

    try {
      final docRepo = getIt<DocumentRepository>();
      final doc = await _processContent();

      final title = _resolveTitle();
      final description = _descController.text.trim();
      final sourceType = _pickedFilePath != null
          ? (_pickedFileType ?? 'pdf')
          : 'text_input';

      final finalDoc = doc.copyWith(
        title: title,
        description: description.isNotEmpty ? description : null,
        sourceType: sourceType,
      );

      await docRepo.save(finalDoc);
      libraryChangeNotifier.value++;
      widget.onContentAdded?.call();

      if (!mounted) return;
      context.push('${AppRoutes.reading}/${finalDoc.id}');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.errorSomethingWrong.tr),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveToLibrary() async {
    if (!_validate()) return;
    setState(() => _isProcessing = true);

    try {
      final docRepo = getIt<DocumentRepository>();
      final doc = await _processContent();

      final title = _resolveTitle();
      final description = _descController.text.trim();
      final sourceType = _pickedFilePath != null
          ? (_pickedFileType ?? 'pdf')
          : 'text_input';

      final finalDoc = doc.copyWith(
        title: title,
        description: description.isNotEmpty ? description : null,
        sourceType: sourceType,
      );

      await docRepo.save(finalDoc);
      libraryChangeNotifier.value++;
      widget.onContentAdded?.call();

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.homeImportSheetSavedToLibrary.tr),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.errorSomethingWrong.tr),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isProcessing = true);

    try {
      final docRepo = getIt<DocumentRepository>();
      final existing = widget.existingDocument!;

      final title = _resolveTitle();
      final description = _descController.text.trim();

      DocumentModel updatedDoc;
      if (_contentChanged) {
        // Re-process content
        final doc = await _processContent();
        updatedDoc = doc.copyWith(
          title: title,
          description: description.isNotEmpty ? description : null,
          sourceType: _pickedFilePath != null
              ? (_pickedFileType ?? existing.sourceType)
              : existing.sourceType,
        );
        // Carry over the original id
        updatedDoc = DocumentModel(
          id: existing.id,
          title: updatedDoc.title,
          filePath: updatedDoc.filePath,
          fileName: updatedDoc.fileName,
          totalPages: updatedDoc.totalPages,
          currentPage: 0, // Reset progress
          totalWords: updatedDoc.totalWords,
          wordsRead: 0, // Reset progress
          complexityScore: updatedDoc.complexityScore,
          complexityLevel: updatedDoc.complexityLevel,
          extractedText: updatedDoc.extractedText,
          readingStatus: 'unread',
          importedAt: existing.importedAt,
          lastReadAt: existing.lastReadAt,
          thumbnailPath: updatedDoc.thumbnailPath,
          sourceType: updatedDoc.sourceType,
          description: updatedDoc.description,
        );
      } else {
        updatedDoc = existing.copyWith(
          title: title,
          description: description.isNotEmpty ? description : null,
        );
      }

      await docRepo.save(updatedDoc);
      libraryChangeNotifier.value++;
      widget.onContentAdded?.call();

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.errorSomethingWrong.tr),
          behavior: SnackBarBehavior.floating,
        ),
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          _isEditMode
              ? AppStrings.libraryEditDocumentTitle.tr
              : AppStrings.homeImportSheetTitle.tr,
          style: AppTypography.titleMedium.copyWith(color: textColor),
        ),
      ),
      body: Column(
        children: [
          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  TextField(
                    controller: _titleController,
                    style: AppTypography.bodyLarge.copyWith(color: textColor),
                    maxLength: _maxTitleLength,
                    onChanged: (_) {
                      if (_titleError != null) {
                        setState(() => _titleError = null);
                      }
                    },
                    decoration: _inputDecoration(
                      isDark: isDark,
                      hint: AppStrings.homeImportSheetTitleHint.tr,
                      label: AppStrings.homeImportSheetTitleLabel.tr,
                      errorText: _titleError,
                      maxLength: _maxTitleLength,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Description field
                  TextField(
                    controller: _descController,
                    style: AppTypography.bodyLarge.copyWith(color: textColor),
                    maxLines: 3,
                    minLines: 1,
                    maxLength: _maxDescLength,
                    decoration: _inputDecoration(
                      isDark: isDark,
                      hint: AppStrings.homeImportSheetDescHint.tr,
                      label: AppStrings.homeImportSheetDescLabel.tr,
                      maxLength: _maxDescLength,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Text area
                  Stack(
                    children: [
                      TextField(
                        controller: _textController,
                        style: AppTypography.bodyLarge.copyWith(color: textColor),
                        maxLines: 12,
                        minLines: 6,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: _inputDecoration(
                          isDark: isDark,
                          hint: AppStrings.homeImportSheetHint.tr,
                          errorText: _contentError,
                        ),
                      ),
                      Positioned(
                        right: AppSpacing.xs,
                        top: AppSpacing.xs,
                        child: GestureDetector(
                          onTap: () async {
                            final data = await Clipboard.getData(Clipboard.kTextPlain);
                            if (data?.text != null && data!.text!.isNotEmpty) {
                              final text = data.text!;
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
                          },
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
                  ),

                  // Content changed warning (edit mode)
                  if (_isEditMode && _contentChanged) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: isDark
                              ? AppColors.tertiary
                              : AppColors.lightTertiary,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            AppStrings.libraryContentChangedWarning.tr,
                            style: AppTypography.label.copyWith(
                              color: isDark
                                  ? AppColors.tertiary
                                  : AppColors.lightTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Word count + performance warning
                  if (_wordCount > 0 || _textController.text.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        Text(
                          AppStrings.homeImportSheetWordCount.trParams({
                            'n': '$_wordCount',
                          }),
                          style: AppTypography.label.copyWith(
                            color: subtextColor,
                            fontSize: 11,
                          ),
                        ),
                        if (_textController.text.length >
                            _performanceWarningThreshold) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: isDark
                                ? AppColors.tertiary
                                : AppColors.lightTertiary,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Expanded(
                            child: Text(
                              AppStrings.homeImportSheetPerformanceWarning.tr,
                              style: AppTypography.label.copyWith(
                                color: isDark
                                    ? AppColors.tertiary
                                    : AppColors.lightTertiary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  // Selected file indicator
                  if (_pickedFileName != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
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
                            _pickedFileType == 'pdf'
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
                              _pickedFileName!,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.primary
                                    : AppColors.lightOnPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _pickedFilePath = null;
                              _pickedFileName = null;
                              _pickedFileType = null;
                            }),
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
                  ],
                ],
              ),
            ),
          ),

          // Pinned bottom section
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isProcessing)
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
                  else if (_isEditMode) ...[
                    // Edit mode: Save Changes button
                    SizedBox(
                      width: double.infinity,
                      child: ReadItButton(
                        label: AppStrings.librarySaveChanges.tr,
                        icon: Icons.save_rounded,
                        onTap: _saveChanges,
                      ),
                    ),
                  ] else ...[
                    // Save & Read button (primary)
                    SizedBox(
                      width: double.infinity,
                      child: ReadItButton(
                        label: AppStrings.homeImportSheetStartReading.tr,
                        icon: Icons.play_arrow_rounded,
                        onTap: _hasContent ? _saveAndRead : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Save to Library button (secondary)
                    SizedBox(
                      width: double.infinity,
                      child: ReadItButton(
                        label: AppStrings.homeImportSheetSaveToLibrary.tr,
                        isSecondary: true,
                        onTap: _hasContent ? _saveToLibrary : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),

                  // Pick file text button
                  TextButton.icon(
                    onPressed: _isProcessing ? null : _pickFile,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

