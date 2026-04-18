import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/pdf_processing/providers/pdf_processing_provider.dart';
import 'features/reading_display/providers/reading_display_provider.dart';
import 'features/user_preferences/providers/user_preferences_provider.dart';
import 'features/analytics/providers/analytics_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/analytics_screen.dart';

class ReadItApp extends StatelessWidget {
  const ReadItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, preferencesProvider, child) {
        return MaterialApp(
          title: 'Read-It',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: preferencesProvider.preferences.themeMode,
          home: const HomeScreen(),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/analytics': (context) => const AnalyticsScreen(),
          },
        );
      },
    );
  }
}
