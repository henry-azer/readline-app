import 'package:hive/hive.dart';
import 'package:readline_app/data/models/word_definition_model.dart';

class HiveDefinitionCacheSource {
  static const _boxName = 'definitions_cache';

  Future<Box<dynamic>> _openBox() => Hive.openBox(_boxName);

  Future<WordDefinitionModel?> get(String word) async {
    try {
      final box = await _openBox();
      final data = box.get(word.toLowerCase());
      if (data == null) return null;
      return WordDefinitionModel.fromMap(data as Map<dynamic, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(String word, WordDefinitionModel definition) async {
    try {
      final box = await _openBox();
      await box.put(word.toLowerCase(), definition.toMap());
    } catch (_) {}
  }
}
