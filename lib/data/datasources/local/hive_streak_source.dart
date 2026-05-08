import 'package:hive/hive.dart';
import 'package:readline_app/data/models/streak_model.dart';

class HiveStreakSource {
  static const _boxName = 'streaks';
  static const _key = 'reading_streak';

  Future<Box<dynamic>> _openBox() => Hive.openBox(_boxName);

  Future<StreakModel> getStreak() async {
    try {
      final box = await _openBox();
      final data = box.get(_key);
      if (data == null) return const StreakModel();
      return StreakModel.fromMap(data as Map<dynamic, dynamic>);
    } catch (_) {
      return const StreakModel();
    }
  }

  Future<void> saveStreak(StreakModel streak) async {
    try {
      final box = await _openBox();
      await box.put(_key, streak.toMap());
    } catch (_) {}
  }
}
