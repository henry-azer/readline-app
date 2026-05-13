import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readline_app/core/services/content_generation/magic_content_settings_service.dart';
import 'package:readline_app/core/services/content_generation/settings_aware_content_generation_service.dart';
import 'package:readline_app/data/contracts/content_generation_service.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeInner implements ContentGenerationService {
  _FakeInner({required this.id, required this.result, this.available = true});

  final String id;
  final ContentGenerationResult result;
  final bool available;
  int isAvailableCalls = 0;
  int generateCalls = 0;

  @override
  Future<bool> isAvailable() async {
    isAvailableCalls++;
    return available;
  }

  @override
  Future<ContentGenerationResult> generate(ContentGenerationRequest req) async {
    generateCalls++;
    return result;
  }
}

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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _sampleRequest = ContentGenerationRequest(
  category: 'general',
  wordCount: 150,
  difficulty: ContentDifficulty.intermediate,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakePrefsRepo prefs;
  late MagicContentSettingsService settings;

  setUp(() async {
    FlutterSecureStoragePlatform.instance = _InMemorySecureStorage();
    prefs = _FakePrefsRepo();
    settings = MagicContentSettingsService(prefsRepo: prefs);
    await settings.init();
  });

  tearDown(() {
    settings.dispose();
  });

  group('isAvailable', () {
    test('disabled → false (does not call inner)', () async {
      final inner = _FakeInner(
        id: 'a',
        result: const ContentGenerationResult(),
      );
      final service = SettingsAwareContentGenerationService(
        settings,
        builder: (_) => inner,
      );
      expect(await service.isAvailable(), false);
      expect(inner.isAvailableCalls, 0);
    });

    test('enabled but no key → false', () async {
      await settings.setEnabled(true);
      final inner = _FakeInner(
        id: 'a',
        result: const ContentGenerationResult(),
      );
      final service = SettingsAwareContentGenerationService(
        settings,
        builder: (_) => inner,
      );
      expect(await service.isAvailable(), false);
      expect(inner.isAvailableCalls, 0);
    });

    test('enabled + key → delegates and returns true', () async {
      await settings.setEnabled(true);
      await settings.saveKey('gsk_a');
      final inner = _FakeInner(
        id: 'a',
        result: const ContentGenerationResult(),
        available: true,
      );
      final service = SettingsAwareContentGenerationService(
        settings,
        builder: (_) => inner,
      );
      expect(await service.isAvailable(), true);
      expect(inner.isAvailableCalls, 1);
    });

    test('enabled + key but inner reports false → false', () async {
      await settings.setEnabled(true);
      await settings.saveKey('gsk_a');
      final inner = _FakeInner(
        id: 'a',
        result: const ContentGenerationResult(),
        available: false,
      );
      final service = SettingsAwareContentGenerationService(
        settings,
        builder: (_) => inner,
      );
      expect(await service.isAvailable(), false);
    });
  });

  group('generate', () {
    test('disabled → server error (does not call inner)', () async {
      final inner = _FakeInner(
        id: 'a',
        result: const ContentGenerationResult(
          content: GeneratedContent(title: 't', body: 'b'),
        ),
      );
      final service = SettingsAwareContentGenerationService(
        settings,
        builder: (_) => inner,
      );
      final result = await service.generate(_sampleRequest);
      expect(result.isSuccess, false);
      expect(result.error, ContentGenerationError.server);
      expect(inner.generateCalls, 0);
    });

    test('enabled but no key → server error', () async {
      await settings.setEnabled(true);
      final inner = _FakeInner(
        id: 'a',
        result: const ContentGenerationResult(
          content: GeneratedContent(title: 't', body: 'b'),
        ),
      );
      final service = SettingsAwareContentGenerationService(
        settings,
        builder: (_) => inner,
      );
      final result = await service.generate(_sampleRequest);
      expect(result.error, ContentGenerationError.server);
      expect(inner.generateCalls, 0);
    });

    test('enabled + key → delegates and returns inner result', () async {
      await settings.setEnabled(true);
      await settings.saveKey('gsk_a');
      final inner = _FakeInner(
        id: 'a',
        result: const ContentGenerationResult(
          content: GeneratedContent(title: 't', body: 'b'),
        ),
      );
      final service = SettingsAwareContentGenerationService(
        settings,
        builder: (_) => inner,
      );
      final result = await service.generate(_sampleRequest);
      expect(result.isSuccess, true);
      expect(inner.generateCalls, 1);
    });
  });

  group('caching / rebuild on key change', () {
    test('reuses cached inner when key unchanged', () async {
      await settings.setEnabled(true);
      await settings.saveKey('gsk_a');
      final builds = <String>[];
      final service = SettingsAwareContentGenerationService(
        settings,
        builder: (key) {
          builds.add(key);
          return _FakeInner(
            id: key,
            result: const ContentGenerationResult(
              content: GeneratedContent(title: 't', body: 'b'),
            ),
          );
        },
      );
      await service.isAvailable();
      await service.isAvailable();
      await service.generate(_sampleRequest);
      expect(builds, ['gsk_a']);
    });

    test('rebuilds inner when key changes', () async {
      await settings.setEnabled(true);
      await settings.saveKey('gsk_a');
      final builds = <String>[];
      final service = SettingsAwareContentGenerationService(
        settings,
        builder: (key) {
          builds.add(key);
          return _FakeInner(
            id: key,
            result: const ContentGenerationResult(
              content: GeneratedContent(title: 't', body: 'b'),
            ),
          );
        },
      );
      await service.isAvailable();
      await settings.saveKey('gsk_b');
      await service.isAvailable();
      expect(builds, ['gsk_a', 'gsk_b']);
    });

    test('clears cache when toggle goes off', () async {
      await settings.setEnabled(true);
      await settings.saveKey('gsk_a');
      final builds = <String>[];
      final service = SettingsAwareContentGenerationService(
        settings,
        builder: (key) {
          builds.add(key);
          return _FakeInner(
            id: key,
            result: const ContentGenerationResult(
              content: GeneratedContent(title: 't', body: 'b'),
            ),
          );
        },
      );
      await service.isAvailable();
      await settings.setEnabled(false);
      expect(await service.isAvailable(), false);
      // Rebuilds when re-enabled
      await settings.setEnabled(true);
      await service.isAvailable();
      expect(builds, ['gsk_a', 'gsk_a']);
    });

    test('clears cache when key deleted', () async {
      await settings.setEnabled(true);
      await settings.saveKey('gsk_a');
      final builds = <String>[];
      final service = SettingsAwareContentGenerationService(
        settings,
        builder: (key) {
          builds.add(key);
          return _FakeInner(
            id: key,
            result: const ContentGenerationResult(
              content: GeneratedContent(title: 't', body: 'b'),
            ),
          );
        },
      );
      await service.isAvailable();
      await settings.deleteKey();
      expect(await service.isAvailable(), false);
      await settings.saveKey('gsk_b');
      await service.isAvailable();
      expect(builds, ['gsk_a', 'gsk_b']);
    });
  });
}
