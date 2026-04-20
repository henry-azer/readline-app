import 'package:read_it/data/contracts/preferences_repository.dart';
import 'package:read_it/data/datasources/local/hive_preferences_source.dart';
import 'package:read_it/data/models/user_preferences_model.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final HivePreferencesSource _source;
  Future<void> _pendingUpdate = Future.value();

  PreferencesRepositoryImpl(this._source);

  @override
  Future<UserPreferencesModel> get() => _source.getPreferences();

  @override
  Future<void> save(UserPreferencesModel preferences) {
    _pendingUpdate = _pendingUpdate.then((_) async {
      await _source.savePreferences(preferences);
    });
    return _pendingUpdate;
  }

  @override
  Future<void> resetToDefaults() {
    _pendingUpdate = _pendingUpdate.then((_) async {
      final current = await _source.getPreferences();
      // Preserve onboarding state when resetting
      await _source.savePreferences(
        const UserPreferencesModel().copyWith(
          onboardingCompleted: current.onboardingCompleted,
          readingLevel: current.readingLevel,
        ),
      );
    });
    return _pendingUpdate;
  }
}
