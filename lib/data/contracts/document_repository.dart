import 'package:read_it/data/models/pdf_document_model.dart';

abstract class DocumentRepository {
  Future<List<PdfDocumentModel>> getAll();
  Future<PdfDocumentModel?> getById(String id);
  Future<void> save(PdfDocumentModel document);
  Future<void> delete(String id);
  Future<List<PdfDocumentModel>> getByStatus(String status);
  Future<void> updateProgress(String id, int currentPage, int wordsRead);
}
