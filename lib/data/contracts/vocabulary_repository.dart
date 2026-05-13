import 'package:readline_app/data/models/vocabulary_word_model.dart';

abstract class VocabularyRepository {
  List<VocabularyWordModel> get cachedAll;
  Future<void> preload();
  Future<void> save(VocabularyWordModel word);
  Future<List<VocabularyWordModel>> getAll();
  Future<void> delete(String id);
  Future<List<VocabularyWordModel>> getByDocumentId(String documentId);
  Future<void> clearSourceDocument(String documentId);
}
