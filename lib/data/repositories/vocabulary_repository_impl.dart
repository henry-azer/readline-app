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
  Future<List<VocabularyWordModel>> getByMasteryLevel(String level) async {
    final all = await _source.getAll();
    return all.where((w) => w.masteryLevel == level).toList();
  }

  @override
  Future<List<VocabularyWordModel>> getByDocumentId(String documentId) async {
    final all = await _source.getAll();
    return all.where((w) => w.sourceDocumentId == documentId).toList();
  }

  @override
  Future<List<VocabularyWordModel>> getDueForReview() async {
    final all = await _source.getAll();
    final now = DateTime.now();
    return all
        .where(
          (w) =>
              w.masteryLevel != 'mastered' &&
              (w.nextReviewAt == null || w.nextReviewAt!.isBefore(now)),
        )
        .toList();
  }

  @override
  Future<void> updateMastery(String id, String level) async {
    final all = await _source.getAll();
    final matches = all.where((w) => w.id == id);
    if (matches.isEmpty) return;
    await _source.save(matches.first.copyWith(masteryLevel: level));
  }

  @override
  Future<void> clearSourceDocument(String documentId) async {
    final words = await getByDocumentId(documentId);
    for (final word in words) {
      await _source.save(word.copyWith(sourceDocumentId: null));
    }
  }
}
