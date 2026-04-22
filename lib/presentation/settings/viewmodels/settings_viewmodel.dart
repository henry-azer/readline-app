import 'package:hive_flutter/hive_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:read_it/app.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/data/contracts/preferences_repository.dart';
import 'package:read_it/data/models/user_preferences_model.dart';

class SettingsViewModel {
  final PreferencesRepository _prefsRepo;

  final BehaviorSubject<UserPreferencesModel> preferences$ =
      BehaviorSubject.seeded(const UserPreferencesModel());
  final BehaviorSubject<bool> isSaving$ = BehaviorSubject.seeded(false);

  SettingsViewModel({PreferencesRepository? prefsRepo})
    : _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>();

  UserPreferencesModel get currentPreferences => preferences$.value;

  Future<void> init() async {
    final prefs = await _prefsRepo.get();
    preferences$.add(prefs);
    // Sync global theme notifier to persisted value on init
    themeModeNotifier.value = prefs.themeMode;
  }

  // ── Mutation helpers ─────────────────────────────────────────────────────────

  Future<void> _updateAndSave(UserPreferencesModel updated) async {
    preferences$.add(updated);
    isSaving$.add(true);
    try {
      await _prefsRepo.save(updated);
    } finally {
      isSaving$.add(false);
    }
  }

  // ── Reading settings ─────────────────────────────────────────────────────────

  /// Update the subject only (for live slider feedback without persisting).
  void previewSpeed(int wpm) =>
      preferences$.add(currentPreferences.copyWith(readingSpeedWpm: wpm));

  void previewLineSpacing(double spacing) =>
      preferences$.add(currentPreferences.copyWith(lineSpacing: spacing));

  void previewFontSize(int size) =>
      preferences$.add(currentPreferences.copyWith(fontSize: size));

  void previewFocusLines(int lines) =>
      preferences$.add(currentPreferences.copyWith(focusWindowLines: lines));

  /// Update and persist (for onChangeEnd).
  Future<void> updateSpeed(int wpm) =>
      _updateAndSave(currentPreferences.copyWith(readingSpeedWpm: wpm));

  Future<void> updateLineSpacing(double spacing) =>
      _updateAndSave(currentPreferences.copyWith(lineSpacing: spacing));

  Future<void> updateFontSize(int size) =>
      _updateAndSave(currentPreferences.copyWith(fontSize: size));

  Future<void> updateFocusLines(int lines) =>
      _updateAndSave(currentPreferences.copyWith(focusWindowLines: lines));

  // ── Appearance ───────────────────────────────────────────────────────────────

  Future<void> updateThemeMode(String mode) async {
    themeModeNotifier.value = mode;
    await _updateAndSave(currentPreferences.copyWith(themeMode: mode));
  }

  Future<void> updateFontFamily(String family) =>
      _updateAndSave(currentPreferences.copyWith(fontFamily: family));

  // ── Advanced ─────────────────────────────────────────────────────────────────

  Future<void> toggleVocabCollection() => _updateAndSave(
    currentPreferences.copyWith(
      enableVocabCollection: !currentPreferences.enableVocabCollection,
    ),
  );

  Future<void> toggleAnalytics() => _updateAndSave(
    currentPreferences.copyWith(
      enableAnalytics: !currentPreferences.enableAnalytics,
    ),
  );

  Future<void> resetToDefaults() async {
    isSaving$.add(true);
    try {
      await _prefsRepo.resetToDefaults();
      final defaults = const UserPreferencesModel();
      preferences$.add(defaults);
      themeModeNotifier.value = defaults.themeMode;
    } finally {
      isSaving$.add(false);
    }
  }

  /// Clears all Hive boxes — removes all app data.
  Future<void> clearAllData() async {
    const boxNames = [
      'preferences',
      'documents',
      'reading_sessions',
      'streaks',
      'vocabulary',
    ];
    for (final name in boxNames) {
      final box = await Hive.openBox(name);
      await box.clear();
    }
  }

  void dispose() {
    preferences$.close();
    isSaving$.close();
  }
}
