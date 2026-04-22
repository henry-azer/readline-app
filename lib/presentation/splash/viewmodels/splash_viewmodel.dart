import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/router/app_router.dart';
import 'package:read_it/data/contracts/preferences_repository.dart';

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

    // Android: allow animations to play
    await Future.delayed(const Duration(milliseconds: 1000));
    targetRoute$.add(route);
  }

  void dispose() {
    targetRoute$.close();
  }
}
