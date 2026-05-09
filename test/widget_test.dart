import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:readline_app/app.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/language_provider.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/main.dart' as app_main;

void main() {
  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('readline_test');
    Hive.init(tempDir.path);
    await configureDependencies();

    final prefsRepo = getIt<PreferencesRepository>();
    final prefs = await prefsRepo.get();
    await AppLocalization.initialize(language: prefs.languageCode);
    app_main.languageProvider = LanguageProvider(
      prefsRepo: getIt<PreferencesRepository>(),
    );
    await app_main.languageProvider.initialize();
  });

  tearDown(() async {
    await Hive.close();
    await getIt.reset();
  });

  testWidgets('ReadlineApp renders without crashing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    await tester.pumpWidget(const ReadlineApp());
    await tester.pumpAndSettle();
    expect(find.byType(ReadlineApp), findsOneWidget);
  });
}
