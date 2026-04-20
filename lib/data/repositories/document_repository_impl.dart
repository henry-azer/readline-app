import 'package:read_it/data/contracts/document_repository.dart';
import 'package:read_it/data/datasources/local/hive_document_source.dart';
import 'package:read_it/data/models/pdf_document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final HiveDocumentSource _source;
  Future<void> _pendingUpdate = Future.value();

  DocumentRepositoryImpl(this._source);

  @override
  Future<List<PdfDocumentModel>> getAll() => _source.getAll();

  @override
  Future<PdfDocumentModel?> getById(String id) => _source.getById(id);

  @override
  Future<void> save(PdfDocumentModel document) => _source.save(document);

  @override
  Future<void> delete(String id) => _source.delete(id);

  @override
  Future<List<PdfDocumentModel>> getByStatus(String status) async {
    final all = await _source.getAll();
    return all.where((d) => d.readingStatus == status).toList();
  }

  @override
  Future<void> updateProgress(String id, int currentPage, int wordsRead) {
    _pendingUpdate = _pendingUpdate.then((_) async {
      final doc = await _source.getById(id);
      if (doc == null) return;
      final status = wordsRead >= doc.totalWords ? 'completed' : 'reading';
      await _source.save(
        doc.copyWith(
          currentPage: currentPage,
          wordsRead: wordsRead,
          readingStatus: status,
          lastReadAt: DateTime.now(),
        ),
      );
    });
    return _pendingUpdate;
  }
}
