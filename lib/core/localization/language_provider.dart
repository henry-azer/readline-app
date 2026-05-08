import 'package:flutter/material.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'app_localization.dart';
import 'language_option.dart';

class LanguageProvider {
  final PreferencesRepository _prefsRepo;
  final ValueNotifier<Locale?> locale = ValueNotifier(null);

  List<LanguageOption> availableLanguages = [];

  List<Locale> get supportedLocales {
    if (availableLanguages.isEmpty) return [const Locale('en')];
    return availableLanguages.map((lang) => Locale(lang.code)).toList();
  }

  bool get isRTL => AppLocalization.isRTL;
  TextDirection get textDirection => AppLocalization.textDirection;
  String get currentLanguageCode => AppLocalization.currentLanguage;

  LanguageProvider({required PreferencesRepository prefsRepo})
    : _prefsRepo = prefsRepo;

  Future<void> initialize() async {
    availableLanguages = await AppLocalization.getAvailableLanguages();
    final prefs = await _prefsRepo.get();
    final saved = prefs.languageCode;
    if (saved != 'en') {
      locale.value = Locale(saved);
    }
    await AppLocalization.initialize(language: saved);
  }

  Future<void> changeLanguage(String? code) async {
    final prefs = await _prefsRepo.get();
    await _prefsRepo.save(prefs.copyWith(languageCode: code ?? 'en'));
    if (code != null) {
      locale.value = Locale(code);
      await AppLocalization.changeLanguage(code);
    } else {
      locale.value = null;
      await AppLocalization.changeLanguage('en');
    }
  }
}
