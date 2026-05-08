import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/router/app_router.dart';
import 'package:readline_app/core/services/pdf_processing_service.dart';
import 'package:readline_app/data/contracts/document_repository.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/data/models/reading_level.dart';

/// Resolves `.tr` at call time so the locale is never frozen.
List<ReadingLevel> _buildReadingLevels() => [
  ReadingLevel(
    id: 'beginner',
    label: AppStrings.onboardingLevelBeginner.tr,
    levelTag: AppStrings.onboardingLevelBeginnerTag.tr,
    wpmRange: AppStrings.onboardingLevelBeginnerRange.tr,
    description: AppStrings.onboardingLevelBeginnerDesc.tr,
    icon: Icons.eco_outlined,
    levelNumber: 1,
  ),
  ReadingLevel(
    id: 'intermediate',
    label: AppStrings.onboardingLevelIntermediate.tr,
    levelTag: AppStrings.onboardingLevelIntermediateTag.tr,
    wpmRange: AppStrings.onboardingLevelIntermediateRange.tr,
    description: AppStrings.onboardingLevelIntermediateDesc.tr,
    icon: Icons.menu_book_outlined,
    levelNumber: 2,
  ),
  ReadingLevel(
    id: 'advanced',
    label: AppStrings.onboardingLevelAdvanced.tr,
    levelTag: AppStrings.onboardingLevelAdvancedTag.tr,
    wpmRange: AppStrings.onboardingLevelAdvancedRange.tr,
    description: AppStrings.onboardingLevelAdvancedDesc.tr,
    icon: Icons.rocket_launch_outlined,
    levelNumber: 3,
  ),
  ReadingLevel(
    id: 'expert',
    label: AppStrings.onboardingLevelExpert.tr,
    levelTag: AppStrings.onboardingLevelExpertTag.tr,
    wpmRange: AppStrings.onboardingLevelExpertRange.tr,
    description: AppStrings.onboardingLevelExpertDesc.tr,
    icon: Icons.bolt_outlined,
    levelNumber: 4,
  ),
];

/// WPM defaults per reading level.
int _wpmForLevel(String levelId) {
  switch (levelId) {
    case 'beginner':
      return 100;
    case 'intermediate':
      return 200;
    case 'advanced':
      return 300;
    case 'expert':
      return 425;
    default:
      return 200;
  }
}

/// Combined state for the onboarding content area.
typedef OnboardingContentState = ({
  int step,
  String selectedLevel,
  bool isLoading,
  String? errorMsg,
});

class OnboardingViewModel {
  final PreferencesRepository _prefsRepo;
  final DocumentRepository _docRepo;
  final PdfProcessingService _pdfService;

  final BehaviorSubject<int> step$ = BehaviorSubject.seeded(0);
  final BehaviorSubject<String> selectedLevel$ = BehaviorSubject.seeded('');
  final BehaviorSubject<bool> isLoading$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> errorMessage$ = BehaviorSubject.seeded(null);

  /// Combined stream for the onboarding content — replaces 4 nested StreamBuilders.
  late final Stream<OnboardingContentState> contentState$ = Rx.combineLatest4(
    step$,
    selectedLevel$,
    isLoading$,
    errorMessage$,
    (step, selectedLevel, isLoading, errorMsg) => (
      step: step,
      selectedLevel: selectedLevel,
      isLoading: isLoading,
      errorMsg: errorMsg,
    ),
  );

  OnboardingViewModel({
    PreferencesRepository? prefsRepo,
    DocumentRepository? docRepo,
    PdfProcessingService? pdfService,
  }) : _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>(),
       _docRepo = docRepo ?? getIt<DocumentRepository>(),
       _pdfService = pdfService ?? getIt<PdfProcessingService>();

  List<ReadingLevel> get levels => _buildReadingLevels();

  void nextStep() {
    if (step$.value < 2) step$.add(step$.value + 1);
  }

  void previousStep() {
    if (step$.value > 0) step$.add(step$.value - 1);
  }

  void selectLevel(String levelId) {
    selectedLevel$.add(levelId);
  }

  void handleSwipeVelocity(double velocity) {
    const threshold = 300.0;
    if (velocity < -threshold) {
      nextStep();
    } else if (velocity > threshold) {
      previousStep();
    }
  }

  /// Saves preferences and navigates to home.
  Future<void> completeOnboarding(BuildContext context) async {
    isLoading$.add(true);
    errorMessage$.add(null);
    try {
      final prefs = await _prefsRepo.get();
      final level = selectedLevel$.value.isEmpty
          ? 'intermediate'
          : selectedLevel$.value;
      await _prefsRepo.save(
        prefs.copyWith(
          onboardingCompleted: true,
          readingLevel: level,
          readingSpeedWpm: _wpmForLevel(level),
        ),
      );
      markOnboardingCompleted();
      if (context.mounted) {
        context.go(AppRoutes.home);
      }
    } catch (_) {
      errorMessage$.add(AppStrings.errorSomethingWrong.tr);
    } finally {
      isLoading$.add(false);
    }
  }

  /// Handles "Import PDF" — opens file picker, processes, saves, then completes.
  Future<void> importPdf(BuildContext context) async {
    errorMessage$.add(null);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) return;

      isLoading$.add(true);
      final doc = await _pdfService.processFile(File(path));
      await _docRepo.save(doc);
      if (!context.mounted) return;
      await completeOnboarding(context);
    } catch (_) {
      errorMessage$.add(AppStrings.errorImportPdf.tr);
      isLoading$.add(false);
    }
  }

  /// Handles "Use sample text" — loads bundled asset, saves, then navigates to reading.
  Future<void> useSampleText(BuildContext context) async {
    isLoading$.add(true);
    errorMessage$.add(null);
    try {
      final text = await rootBundle.loadString('assets/sample/sample_text.txt');
      final doc = await _pdfService.processSampleText(text);
      await _docRepo.save(doc);
      if (!context.mounted) return;

      // Save onboarding prefs
      final prefs = await _prefsRepo.get();
      final level = selectedLevel$.value.isEmpty
          ? 'intermediate'
          : selectedLevel$.value;
      await _prefsRepo.save(
        prefs.copyWith(
          onboardingCompleted: true,
          readingLevel: level,
          readingSpeedWpm: _wpmForLevel(level),
        ),
      );
      markOnboardingCompleted();

      if (context.mounted) {
        context.go('${AppRoutes.reading}/${doc.id}?autoPlay=true');
      }
    } catch (_) {
      errorMessage$.add(AppStrings.errorSampleText.tr);
      isLoading$.add(false);
    }
  }

  void dispose() {
    step$.close();
    selectedLevel$.close();
    isLoading$.close();
    errorMessage$.close();
  }
}
