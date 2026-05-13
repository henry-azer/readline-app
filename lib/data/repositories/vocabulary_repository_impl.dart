import 'package:readline_app/data/contracts/vocabulary_repository.dart';
import 'package:readline_app/data/datasources/local/hive_vocabulary_source.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final HiveVocabularySource _source;
  List<VocabularyWordModel> _cache = const [];

  VocabularyRepositoryImpl(this._source);

  @override
  List<VocabularyWordModel> get cachedAll => _cache;

  @override
  Future<void> preload() async {
    _cache = await _source.getAll();
  }

  @override
  Future<void> save(VocabularyWordModel word) async {
    await _source.save(word);
    _cache = await _source.getAll();
  }

  @override
  Future<List<VocabularyWordModel>> getAll() async {
    _cache = await _source.getAll();
    return _cache;
  }

  @override
  Future<void> delete(String id) async {
    await _source.delete(id);
    _cache = _cache.where((w) => w.id != id).toList();
  }

  @override
  Future<List<VocabularyWordModel>> getByDocumentId(String documentId) async {
    final all = await _source.getAll();
    return all.where((w) => w.sourceDocumentId == documentId).toList();
  }

  @override
  Future<void> clearSourceDocument(String documentId) async {
    final words = await getByDocumentId(documentId);
    for (final word in words) {
      await _source.save(word.copyWith(sourceDocumentId: null));
    }
  }
}
