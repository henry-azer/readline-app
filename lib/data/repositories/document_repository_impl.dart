import 'package:readline_app/data/contracts/document_repository.dart';
import 'package:readline_app/data/datasources/local/hive_document_source.dart';
import 'package:readline_app/data/models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final HiveDocumentSource _source;
  Future<void> _pendingUpdate = Future.value();
  List<DocumentModel> _cache = const [];

  DocumentRepositoryImpl(this._source);

  @override
  List<DocumentModel> get cachedAll => _cache;

  @override
  Future<void> preload() async {
    _cache = await _source.getAll();
  }

  @override
  Future<List<DocumentModel>> getAll() async {
    _cache = await _source.getAll();
    return _cache;
  }

  @override
  Future<DocumentModel?> getById(String id) => _source.getById(id);

  @override
  Future<void> save(DocumentModel document) async {
    await _source.save(document);
    _cache = await _source.getAll();
  }

  @override
  Future<void> delete(String id) async {
    await _source.delete(id);
    _cache = _cache.where((d) => d.id != id).toList();
  }

  @override
  Future<List<DocumentModel>> getByStatus(String status) async {
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

  @override
  Future<void> resetProgress(String id) {
    _pendingUpdate = _pendingUpdate.then((_) async {
      final doc = await _source.getById(id);
      if (doc == null) return;
      await _source.save(
        doc.copyWith(
          currentPage: 0,
          wordsRead: 0,
          readingStatus: 'reading',
          lastReadAt: DateTime.now(),
        ),
      );
    });
    return _pendingUpdate;
  }
}
