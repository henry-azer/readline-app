import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rxdart/rxdart.dart';

import 'package:readline_app/data/contracts/preferences_repository.dart';

/// Owns the user's magic-content preferences:
/// - `enabled` — toggle in Settings (persisted in Hive prefs).
/// - the API key — opaque string persisted in OS-encrypted secure storage.
///
/// Exposes reactive streams; consumers use `enabled$` and `hasKey$` to react
/// to changes without re-reading from disk.
class MagicContentSettingsService {
  static const _keyStorageKey = 'magic_content.groq_api_key';

  final PreferencesRepository _prefsRepo;
  final FlutterSecureStorage _secureStorage;

  final BehaviorSubject<bool> enabled$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> hasKey$ = BehaviorSubject.seeded(false);

  MagicContentSettingsService({
    required PreferencesRepository prefsRepo,
    FlutterSecureStorage? secureStorage,
  })  : _prefsRepo = prefsRepo,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Loads persisted state into the streams. Call once at app startup,
  /// after `configureDependencies()`.
  Future<void> init() async {
    final prefs = await _prefsRepo.get();
    enabled$.add(prefs.magicContentEnabled);
    final key = await _secureStorage.read(key: _keyStorageKey);
    hasKey$.add(key != null && key.isNotEmpty);
  }

  Future<bool> isEnabled() async => enabled$.value;

  Future<String?> getKey() async {
    return _secureStorage.read(key: _keyStorageKey);
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await _prefsRepo.get();
    await _prefsRepo.save(prefs.copyWith(magicContentEnabled: value));
    enabled$.add(value);
  }

  Future<void> saveKey(String key) async {
    await _secureStorage.write(key: _keyStorageKey, value: key);
    hasKey$.add(true);
  }

  Future<void> deleteKey() async {
    await _secureStorage.delete(key: _keyStorageKey);
    hasKey$.add(false);
  }

  void dispose() {
    enabled$.close();
    hasKey$.close();
  }
}
