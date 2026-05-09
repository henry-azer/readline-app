import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/router/app_router.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';

class SplashViewModel {
  final PreferencesRepository _prefsRepo;

  final BehaviorSubject<String?> targetRoute$ = BehaviorSubject.seeded(null);

  SplashViewModel({PreferencesRepository? prefsRepo})
    : _prefsRepo = prefsRepo ?? getIt<PreferencesRepository>();

  Future<void> init() async {
    final prefs = await _prefsRepo.get();
    final onboardingDone = prefs.onboardingCompleted;

    if (onboardingDone) markOnboardingCompleted();

    final route = onboardingDone ? AppRoutes.home : AppRoutes.onboarding;

    // iOS relies on native splash — navigate immediately
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      targetRoute$.add(route);
      return;
    }

    await Future.delayed(AppDurations.stagger);

    // Android: allow animations to play
    targetRoute$.add(route);
  }

  void dispose() {
    targetRoute$.close();
  }
}
