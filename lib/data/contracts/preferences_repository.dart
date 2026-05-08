import 'package:readline_app/data/models/user_preferences_model.dart';

abstract class PreferencesRepository {
  Future<UserPreferencesModel> get();
  Future<void> save(UserPreferencesModel preferences);
  Future<void> resetToDefaults();
}
