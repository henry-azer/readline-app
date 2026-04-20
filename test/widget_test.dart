import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:read_it/app.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/language_provider.dart';
import 'package:read_it/data/contracts/preferences_repository.dart';
import 'package:read_it/main.dart' as app_main;

void main() {
  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('read_it_test');
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

  testWidgets('ReadItApp renders without crashing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    await tester.pumpWidget(const ReadItApp());
    await tester.pumpAndSettle();
    expect(find.byType(ReadItApp), findsOneWidget);
  });
}
