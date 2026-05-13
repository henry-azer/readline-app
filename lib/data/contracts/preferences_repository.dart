import 'package:readline_app/data/models/user_preferences_model.dart';

abstract class PreferencesRepository {
  /// Returns the in-memory cached preferences. Available synchronously after
  /// [preload] has completed (called once at app startup).
  UserPreferencesModel get cached;
  Future<void> preload();
  Future<UserPreferencesModel> get();
  Future<void> save(UserPreferencesModel preferences);
  Future<void> resetToDefaults();
}
