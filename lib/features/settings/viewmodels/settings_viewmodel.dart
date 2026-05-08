import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:readline_app/app.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/localization/language_provider.dart';
import 'package:readline_app/core/localization/language_option.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/models/user_preferences_model.dart';
import 'package:readline_app/main.dart' as app_main;

class SettingsViewModel {
  final PreferencesRepository _prefsRepo;
  final LanguageProvider _languageProvider;

  final BehaviorSubject<UserPreferencesModel> preferences$ =
      BehaviorSubject.seeded(const UserPreferencesModel());
  final BehaviorSubject<bool> isSaving$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<String> themeMode$ = BehaviorSubject.seeded('system');
  final BehaviorSubject<String?> selectedLocale$ = BehaviorSubject.seeded(null);
  final BehaviorSubject<bool> hapticEnabled$ = BehaviorSubject.seeded(true);
  final BehaviorSubject<String> version$ = BehaviorSubject.seeded('');

  late final VoidCallback _localeListener;

  SettingsViewModel({
    PreferencesRepository? prefsRepo,
    LanguageProvider? languageProvider,
  })  : _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>(),
        _languageProvider = languageProvider ?? app_main.languageProvider {
    _localeListener = () {
      selectedLocale$.add(_languageProvider.locale.value?.languageCode);
    };
    _languageProvider.locale.addListener(_localeListener);
  }

  UserPreferencesModel get currentPreferences => preferences$.value;

  List<LanguageOption> get availableLanguages =>
      _languageProvider.availableLanguages;

  String labelForLocale(String? code) {
    if (code == null) return '';
    for (final l in availableLanguages) {
      if (l.code == code) return l.nativeName;
    }
    return '';
  }

  Future<void> init() async {
    final prefs = await _prefsRepo.get();
    preferences$.add(prefs);
    themeMode$.add(prefs.themeMode);
    hapticEnabled$.add(prefs.hapticsEnabled);
    selectedLocale$.add(_languageProvider.locale.value?.languageCode);
    themeModeNotifier.value = prefs.themeMode;
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!version$.isClosed) version$.add(info.version);
    } catch (_) {
      if (!version$.isClosed) version$.add('');
    }
  }

  Future<void> _updateAndSave(UserPreferencesModel updated) async {
    preferences$.add(updated);
    isSaving$.add(true);
    try {
      await _prefsRepo.save(updated);
    } finally {
      isSaving$.add(false);
    }
  }

  Future<void> saveThemeMode(String mode) async {
    themeMode$.add(mode);
    themeModeNotifier.value = mode;
    await _updateAndSave(currentPreferences.copyWith(themeMode: mode));
  }

  Future<void> saveHapticEnabled(bool enabled) async {
    hapticEnabled$.add(enabled);
    getIt<HapticService>().setEnabled(enabled);
    await _updateAndSave(currentPreferences.copyWith(hapticsEnabled: enabled));
  }

  Future<void> saveLocale(String? code) async {
    isSaving$.add(true);
    try {
      await _languageProvider.changeLanguage(code);
      selectedLocale$.add(code);
    } finally {
      isSaving$.add(false);
    }
  }

  void dispose() {
    _languageProvider.locale.removeListener(_localeListener);
    preferences$.close();
    isSaving$.close();
    themeMode$.close();
    selectedLocale$.close();
    hapticEnabled$.close();
    version$.close();
  }
}
