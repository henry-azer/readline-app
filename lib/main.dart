import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'core/localization/app_localization.dart';
import 'core/localization/language_provider.dart';
import 'core/services/content_generation/magic_content_settings_service.dart';
import 'data/contracts/preferences_repository.dart';

late final LanguageProvider languageProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: SystemUiOverlay.values,
  );
  await Hive.initFlutter();
  await Hive.openBox('definitions_cache');
  await configureDependencies();

  final prefsRepo = getIt<PreferencesRepository>();
  await prefsRepo.preload();
  final prefs = prefsRepo.cached;

  await getIt<MagicContentSettingsService>().init();
  themeModeNotifier.value = prefs.themeMode;

  await AppLocalization.initialize(language: prefs.languageCode);
  languageProvider = LanguageProvider(
    prefsRepo: getIt<PreferencesRepository>(),
  );
  await languageProvider.initialize();

  // Preload splash typefaces so the first frame already has Newsreader/Inter
  // resolved — otherwise google_fonts fetches asynchronously and the splash
  // text visibly swaps from the platform fallback to the brand font.
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.newsreader(),
      GoogleFonts.inter(),
    ]).timeout(const Duration(seconds: 2));
  } catch (_) {
    // Offline / slow network on first launch — proceed; subsequent launches
    // hit the local cache and the flash disappears.
  }

  runApp(const ReadlineApp());
}
