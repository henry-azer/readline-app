import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/services/pdf_processing_service.dart';
import 'package:read_it/data/contracts/document_repository.dart';
import 'package:read_it/data/enums/app_enums.dart';
import 'package:read_it/data/models/pdf_document_model.dart';

class LibraryViewModel {
  final DocumentRepository _docRepo;
  final PdfProcessingService _pdfService;

  final BehaviorSubject<List<PdfDocumentModel>> allDocuments$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<List<PdfDocumentModel>> documents$ =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<String> activeFilter$ = BehaviorSubject.seeded('all');
  final BehaviorSubject<ViewMode> viewMode$ = BehaviorSubject.seeded(
    ViewMode.grid,
  );
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> importError$ = BehaviorSubject.seeded(null);

  LibraryViewModel({
    DocumentRepository? docRepo,
    PdfProcessingService? pdfService,
  }) : _docRepo = docRepo ?? getIt<DocumentRepository>(),
       _pdfService = pdfService ?? getIt<PdfProcessingService>();

  String get currentFilter => activeFilter$.value;
  ViewMode get currentViewMode => viewMode$.value;
  int get documentCount => allDocuments$.value.length;

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    isLoading$.add(true);
    try {
      final docs = await _docRepo.getAll();
      allDocuments$.add(docs);
      _applyFilter(activeFilter$.value);
    } finally {
      isLoading$.add(false);
    }
  }

  void setFilter(String filter) {
    activeFilter$.add(filter);
    _applyFilter(filter);
  }

  void toggleViewMode() {
    final next = viewMode$.value == ViewMode.grid
        ? ViewMode.list
        : ViewMode.grid;
    viewMode$.add(next);
  }

  Future<void> deleteDocument(String id) async {
    await _docRepo.delete(id);
    final updated = allDocuments$.value.where((d) => d.id != id).toList();
    allDocuments$.add(updated);
    _applyFilter(activeFilter$.value);
  }

  Future<void> undoDelete(PdfDocumentModel document) async {
    await _docRepo.save(document);
    final updated = [...allDocuments$.value, document];
    allDocuments$.add(updated);
    _applyFilter(activeFilter$.value);
  }

  Future<bool> importDocument() async {
    importError$.add(null);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty) return false;
      final path = result.files.single.path;
      if (path == null) return false;

      final doc = await _pdfService.processFile(File(path));
      await _docRepo.save(doc);
      await refresh();
      return true;
    } catch (_) {
      importError$.add(AppStrings.errorImportPdf.tr);
      return false;
    }
  }

  void _applyFilter(String filter) {
    final all = allDocuments$.value;
    final filtered = switch (filter) {
      'reading' => all.where((d) => d.readingStatus == 'reading').toList(),
      'completed' => all.where((d) => d.readingStatus == 'completed').toList(),
      _ => all,
    };
    documents$.add(filtered);
  }

  void dispose() {
    allDocuments$.close();
    documents$.close();
    activeFilter$.close();
    viewMode$.close();
    isLoading$.close();
    importError$.close();
  }
}
