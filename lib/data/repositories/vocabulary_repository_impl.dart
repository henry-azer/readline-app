import 'package:readline_app/data/contracts/vocabulary_repository.dart';
import 'package:readline_app/data/datasources/local/hive_vocabulary_source.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final HiveVocabularySource _source;

  VocabularyRepositoryImpl(this._source);

  @override
  Future<void> save(VocabularyWordModel word) => _source.save(word);

  @override
  Future<List<VocabularyWordModel>> getAll() => _source.getAll();

  @override
  Future<void> delete(String id) => _source.delete(id);

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
