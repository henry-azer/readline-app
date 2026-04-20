import 'package:read_it/data/models/vocabulary_word_model.dart';

abstract class VocabularyRepository {
  Future<void> save(VocabularyWordModel word);
  Future<List<VocabularyWordModel>> getAll();
  Future<void> delete(String id);
  Future<List<VocabularyWordModel>> getByMasteryLevel(String level);
  Future<List<VocabularyWordModel>> getByDocumentId(String documentId);
  Future<List<VocabularyWordModel>> getDueForReview();
  Future<void> updateMastery(String id, String level);
}
