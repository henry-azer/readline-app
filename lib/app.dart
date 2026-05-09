import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localization.dart';
import 'core/localization/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'main.dart' show languageProvider;

/// Global theme mode notifier. 'system' | 'light' | 'dark'
final themeModeNotifier = ValueNotifier<String>('system');

/// Bumped whenever library data changes (import, delete, edit).
/// Tab screens listen to this to refresh stale data.
final libraryChangeNotifier = ValueNotifier<int>(0);

/// Bumped whenever a reading session is saved or vocabulary changes —
/// signals analytics-facing surfaces (insights screen, growth card, charts)
/// to recompute. Increment from any code path that writes a session,
/// updates the streak, or mutates the vocabulary collection.
final sessionChangeNotifier = ValueNotifier<int>(0);

/// Bumped whenever the saved-vocabulary set is mutated (word saved, removed,
/// or auto-collected). The vocabulary screen listens to this so words saved
/// from the player popup show up without a manual pull-to-refresh.
final vocabChangeNotifier = ValueNotifier<int>(0);

class ReadlineApp extends StatelessWidget {
  const ReadlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: languageProvider.locale,
      builder: (context, locale, _) {
        return ValueListenableBuilder<String>(
          valueListenable: themeModeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp.router(
              title: AppStrings.generalAppName.tr,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: _resolveThemeMode(themeMode),
              routerConfig: appRouter,
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: languageProvider.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        );
      },
    );
  }
}

ThemeMode _resolveThemeMode(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}
