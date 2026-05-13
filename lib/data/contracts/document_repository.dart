import 'package:readline_app/data/models/document_model.dart';

abstract class DocumentRepository {
  List<DocumentModel> get cachedAll;
  Future<void> preload();
  Future<List<DocumentModel>> getAll();
  Future<DocumentModel?> getById(String id);
  Future<void> save(DocumentModel document);
  Future<void> delete(String id);
  Future<List<DocumentModel>> getByStatus(String status);
  Future<void> updateProgress(String id, int currentPage, int wordsRead);

  /// Resets a document's progress to the beginning so it can be re-read.
  /// Sets `wordsRead`/`currentPage` back to 0 and status to `reading`.
  Future<void> resetProgress(String id);
}
