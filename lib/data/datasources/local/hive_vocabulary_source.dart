import 'package:hive/hive.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';

class HiveVocabularySource {
  static const _boxName = 'vocabulary';

  Future<Box<dynamic>> _openBox() => Hive.openBox(_boxName);

  Future<List<VocabularyWordModel>> getAll() async {
    try {
      final box = await _openBox();
      return box.values
          .map((e) => VocabularyWordModel.fromMap(e as Map<dynamic, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(VocabularyWordModel word) async {
    try {
      final box = await _openBox();
      await box.put(word.id, word.toMap());
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
    } catch (_) {}
  }
}
