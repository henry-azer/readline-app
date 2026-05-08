import 'package:hive/hive.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';

class HivePreferencesSource {
  static const _boxName = 'preferences';
  static const _key = 'user_preferences';

  Future<Box<dynamic>> _openBox() => Hive.openBox(_boxName);

  Future<UserPreferencesModel> getPreferences() async {
    try {
      final box = await _openBox();
      final data = box.get(_key);
      if (data == null) return const UserPreferencesModel();
      return UserPreferencesModel.fromMap(data as Map<dynamic, dynamic>);
    } catch (_) {
      return const UserPreferencesModel();
    }
  }

  Future<void> savePreferences(UserPreferencesModel prefs) async {
    try {
      final box = await _openBox();
      await box.put(_key, prefs.toMap());
    } catch (_) {}
  }
}
