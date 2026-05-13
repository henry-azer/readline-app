import 'package:readline_app/data/models/vocabulary_word_model.dart';

abstract class VocabularyRepository {
  Future<void> save(VocabularyWordModel word);
  Future<List<VocabularyWordModel>> getAll();
  Future<void> delete(String id);
  Future<List<VocabularyWordModel>> getByDocumentId(String documentId);
  Future<void> clearSourceDocument(String documentId);
}
