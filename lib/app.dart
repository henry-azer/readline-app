import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localization.dart';
import 'core/localization/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'main.dart' show languageProvider;

/// Global theme mode notifier. 'system' | 'light' | 'dark'
final themeModeNotifier = ValueNotifier<String>('system');

class ReadItApp extends StatelessWidget {
  const ReadItApp({super.key});

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
