import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:readline_app/core/services/content_generation/magic_content_settings_service.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';

class _FakePrefsRepo implements PreferencesRepository {
  UserPreferencesModel _value = const UserPreferencesModel();
  @override
  UserPreferencesModel get cached => _value;
  @override
  Future<void> preload() async {}
  @override
  Future<UserPreferencesModel> get() async => _value;
  @override
  Future<void> save(UserPreferencesModel prefs) async => _value = prefs;
  @override
  Future<void> resetToDefaults() async => _value = const UserPreferencesModel();
}

class _InMemorySecureStorage extends FlutterSecureStoragePlatform {
  final Map<String, String> _store = {};

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async =>
      _store.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async =>
      _store.clear();

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async =>
      _store[key];

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async =>
      Map.of(_store);

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _store[key] = value;
  }
}

void main() {
  late _FakePrefsRepo prefs;
  late MagicContentSettingsService service;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _InMemorySecureStorage();
    prefs = _FakePrefsRepo();
    service = MagicContentSettingsService(prefsRepo: prefs);
  });

  tearDown(() {
    service.dispose();
  });

  group('init', () {
    test('seeds streams from persisted state — defaults', () async {
      await service.init();
      expect(service.enabled$.value, false);
      expect(service.hasKey$.value, false);
    });

    test('seeds enabled=true and hasKey=true when persisted', () async {
      await prefs.save(const UserPreferencesModel(magicContentEnabled: true));
      await const FlutterSecureStorage().write(
        key: 'magic_content.groq_api_key',
        value: 'gsk_test',
      );
      await service.init();
      expect(service.enabled$.value, true);
      expect(service.hasKey$.value, true);
    });
  });

  group('setEnabled', () {
    test('persists and emits', () async {
      await service.init();
      await service.setEnabled(true);
      expect(service.enabled$.value, true);
      expect((await prefs.get()).magicContentEnabled, true);

      await service.setEnabled(false);
      expect(service.enabled$.value, false);
      expect((await prefs.get()).magicContentEnabled, false);
    });
  });

  group('saveKey / getKey / deleteKey', () {
    test('saveKey persists and emits hasKey=true', () async {
      await service.init();
      await service.saveKey('gsk_xyz');
      expect(service.hasKey$.value, true);
      expect(await service.getKey(), 'gsk_xyz');
    });

    test('deleteKey clears storage and emits hasKey=false', () async {
      await service.init();
      await service.saveKey('gsk_xyz');
      await service.deleteKey();
      expect(service.hasKey$.value, false);
      expect(await service.getKey(), null);
    });

    test('saveKey then saveKey again overwrites', () async {
      await service.init();
      await service.saveKey('gsk_a');
      await service.saveKey('gsk_b');
      expect(await service.getKey(), 'gsk_b');
    });
  });
}
