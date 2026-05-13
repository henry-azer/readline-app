import 'package:readline_app/app.dart' show preferencesChangeNotifier;
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/datasources/local/hive_preferences_source.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final HivePreferencesSource _source;
  Future<void> _pendingUpdate = Future.value();
  UserPreferencesModel _cache = const UserPreferencesModel();

  PreferencesRepositoryImpl(this._source);

  @override
  UserPreferencesModel get cached => _cache;

  @override
  Future<void> preload() async {
    _cache = await _source.getPreferences();
  }

  @override
  Future<UserPreferencesModel> get() async {
    return _cache;
  }

  @override
  Future<void> save(UserPreferencesModel preferences) {
    _cache = preferences;
    _pendingUpdate = _pendingUpdate.then((_) async {
      await _source.savePreferences(preferences);
      preferencesChangeNotifier.value++;
    });
    return _pendingUpdate;
  }

  @override
  Future<void> resetToDefaults() {
    _pendingUpdate = _pendingUpdate.then((_) async {
      // Preserve onboarding state when resetting
      final reset = const UserPreferencesModel().copyWith(
        onboardingCompleted: _cache.onboardingCompleted,
        readingLevel: _cache.readingLevel,
      );
      _cache = reset;
      await _source.savePreferences(reset);
      preferencesChangeNotifier.value++;
    });
    return _pendingUpdate;
  }
}
