import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:readline_app/app.dart' show libraryChangeNotifier;
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/services/pdf_processing_service.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/data/contracts/document_repository.dart';
import 'package:readline_app/data/models/document_model.dart';

class ImportContentViewModel {
  static const int maxTitleLength = 30;
  static const int performanceWarningThreshold = 100000;
  static const int _maxPdfSizeMb = 50;
  static const int _maxTxtSizeMb = 10;

  final DocumentRepository _docRepo;
  final PdfProcessingService _pdfService;
  final DocumentModel? existingDocument;

  final BehaviorSubject<String?> pickedFilePath$ = BehaviorSubject.seeded(null);
  final BehaviorSubject<String?> pickedFileName$ = BehaviorSubject.seeded(null);
  final BehaviorSubject<String?> pickedFileType$ = BehaviorSubject.seeded(null);
  final BehaviorSubject<int> wordCount$ = BehaviorSubject.seeded(0);
  final BehaviorSubject<bool> isProcessing$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> contentError$ = BehaviorSubject.seeded(null);
  final BehaviorSubject<bool> contentChanged$ = BehaviorSubject.seeded(false);
  final PublishSubject<int> fileTooLargeMb$ = PublishSubject<int>();

  Timer? _wordCountDebounce;

  ImportContentViewModel({
    DocumentRepository? docRepo,
    PdfProcessingService? pdfService,
    this.existingDocument,
  }) : _docRepo = docRepo ?? getIt<DocumentRepository>(),
       _pdfService = pdfService ?? getIt<PdfProcessingService>() {
    if (existingDocument != null) {
      wordCount$.add(existingDocument!.totalWords);
    }
  }

  bool get isEditMode => existingDocument != null;

  bool hasContent(String text) =>
      text.trim().isNotEmpty || pickedFilePath$.value != null;

  String? defaultTitleFromFile() {
    final fname = pickedFileName$.value;
    if (fname == null) return null;
    return fname.replaceAll(RegExp(r'\.[^.]+$'), '');
  }

  void onTextChanged(String text) {
    _wordCountDebounce?.cancel();
    _wordCountDebounce = Timer(AppDurations.debounce, () {
      final trimmed = text.trim();
      final count = trimmed.isEmpty
          ? 0
          : trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      wordCount$.add(count);
      contentError$.add(null);
    });
    if (isEditMode && !contentChanged$.value) {
      final originalText = existingDocument!.extractedText;
      if (text.trim() != originalText.trim()) {
        contentChanged$.add(true);
      }
    }
    if (contentError$.value != null) {
      contentError$.add(null);
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'md'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final fileSize = await file.length();
    final ext = result.files.single.extension?.toLowerCase() ?? '';

    final maxBytes =
        (ext == 'pdf' ? _maxPdfSizeMb : _maxTxtSizeMb) * 1024 * 1024;
    if (fileSize > maxBytes) {
      fileTooLargeMb$.add(ext == 'pdf' ? _maxPdfSizeMb : _maxTxtSizeMb);
      return;
    }

    final fileName = result.files.single.name;
    final sourceType = ext == 'pdf' ? 'pdf' : 'txt';
    pickedFilePath$.add(result.files.single.path);
    pickedFileName$.add(fileName);
    pickedFileType$.add(sourceType);
    contentError$.add(null);
    contentChanged$.add(true);
  }

  void clearFile() {
    pickedFilePath$.add(null);
    pickedFileName$.add(null);
    pickedFileType$.add(null);
  }

  bool _validate({required bool hasContent}) {
    if (!hasContent && !isEditMode) {
      contentError$.add(AppStrings.homeImportSheetContentRequired.tr);
      return false;
    }
    return true;
  }

  String _resolveTitle({required String title, required String text}) {
    final t = title.trim();
    if (t.isNotEmpty) return t;
    final tx = text.trim();
    if (tx.isNotEmpty) {
      final firstLine = tx.split('\n').first.trim();
      if (firstLine.isNotEmpty) {
        return firstLine.length > maxTitleLength
            ? firstLine.substring(0, maxTitleLength)
            : firstLine;
      }
    }
    final fromFile = defaultTitleFromFile();
    if (fromFile != null) return fromFile;
    return AppStrings.homeImportSheetUntitled.tr;
  }

  Future<DocumentModel> _processContent(String text) async {
    final path = pickedFilePath$.value;
    if (path != null) {
      if (pickedFileType$.value == 'pdf') {
        return await _pdfService.processFile(File(path));
      } else {
        final file = File(path);
        String t;
        try {
          t = await file.readAsString(encoding: utf8);
        } catch (_) {
          t = await file.readAsString(encoding: latin1);
        }
        return await _pdfService.processSampleText(t);
      }
    }
    return await _pdfService.processSampleText(text.trim());
  }

  /// Saves a new document. Returns the saved doc or null on validation/error.
  Future<DocumentModel?> save({
    required String title,
    required String text,
  }) async {
    if (!_validate(hasContent: hasContent(text))) return null;
    isProcessing$.add(true);
    try {
      final doc = await _processContent(text);
      final resolvedTitle = _resolveTitle(title: title, text: text);
      final sourceType = pickedFilePath$.value != null
          ? (pickedFileType$.value ?? 'pdf')
          : 'text_input';
      final finalDoc = doc.copyWith(
        title: resolvedTitle,
        sourceType: sourceType,
      );
      await _docRepo.save(finalDoc);
      libraryChangeNotifier.value++;
      return finalDoc;
    } catch (_) {
      isProcessing$.add(false);
      return null;
    }
  }

  /// Saves an edited document. Returns the updated doc or null on error.
  Future<DocumentModel?> saveEdit({
    required String title,
    required String text,
  }) async {
    isProcessing$.add(true);
    try {
      final existing = existingDocument!;
      final resolvedTitle = _resolveTitle(title: title, text: text);
      DocumentModel updatedDoc;
      if (contentChanged$.value) {
        final doc = await _processContent(text);
        updatedDoc = DocumentModel(
          id: existing.id,
          title: resolvedTitle,
          filePath: doc.filePath,
          fileName: doc.fileName,
          totalPages: doc.totalPages,
          currentPage: 0,
          totalWords: doc.totalWords,
          wordsRead: 0,
          complexityScore: doc.complexityScore,
          complexityLevel: doc.complexityLevel,
          extractedText: doc.extractedText,
          readingStatus: 'unread',
          importedAt: existing.importedAt,
          lastReadAt: existing.lastReadAt,
          thumbnailPath: doc.thumbnailPath,
          sourceType: pickedFilePath$.value != null
              ? (pickedFileType$.value ?? existing.sourceType)
              : existing.sourceType,
        );
      } else {
        updatedDoc = existing.copyWith(title: resolvedTitle);
      }
      await _docRepo.save(updatedDoc);
      libraryChangeNotifier.value++;
      return updatedDoc;
    } catch (_) {
      isProcessing$.add(false);
      return null;
    }
  }

  void dispose() {
    _wordCountDebounce?.cancel();
    pickedFilePath$.close();
    pickedFileName$.close();
    pickedFileType$.close();
    wordCount$.close();
    isProcessing$.close();
    contentError$.close();
    contentChanged$.close();
    fileTooLargeMb$.close();
  }
}
