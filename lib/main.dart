import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'core/localization/app_localization.dart';
import 'core/localization/language_provider.dart';
import 'data/contracts/preferences_repository.dart';

late final LanguageProvider languageProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await configureDependencies();

  final prefsRepo = getIt<PreferencesRepository>();
  final prefs = await prefsRepo.get();
  themeModeNotifier.value = prefs.themeMode;

  await AppLocalization.initialize(language: prefs.languageCode);
  languageProvider = LanguageProvider(
    prefsRepo: getIt<PreferencesRepository>(),
  );
  await languageProvider.initialize();

  runApp(const ReadItApp());
}
