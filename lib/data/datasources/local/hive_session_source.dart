import 'package:hive/hive.dart';
import 'package:read_it/data/models/reading_session_model.dart';

class HiveSessionSource {
  static const _boxName = 'reading_sessions';

  Future<Box<dynamic>> _openBox() => Hive.openBox(_boxName);

  Future<List<ReadingSessionModel>> getAll() async {
    try {
      final box = await _openBox();
      return box.values
          .map((e) => ReadingSessionModel.fromMap(e as Map<dynamic, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(ReadingSessionModel session) async {
    try {
      final box = await _openBox();
      await box.put(session.id, session.toMap());
    } catch (_) {}
  }
}
