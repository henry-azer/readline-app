import 'package:go_router/go_router.dart';
import 'package:read_it/core/router/app_page_transitions.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/data/contracts/preferences_repository.dart';
import 'package:read_it/presentation/shell/app_shell.dart';
import 'package:read_it/presentation/home/screens/home_screen.dart';
import 'package:read_it/presentation/library/screens/library_screen.dart';
import 'package:read_it/presentation/vocabulary/screens/vocabulary_screen.dart';
import 'package:read_it/presentation/analytics/screens/analytics_screen.dart';
import 'package:read_it/presentation/onboarding/screens/onboarding_screen.dart';
import 'package:read_it/presentation/reading/screens/reading_screen.dart';
import 'package:read_it/presentation/settings/screens/settings_screen.dart';
import 'package:read_it/presentation/splash/screens/splash_screen.dart';
import 'package:read_it/presentation/vocabulary/screens/review_session_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const library = '/library';
  static const vocabulary = '/vocabulary';
  static const analytics = '/analytics';
  static const onboarding = '/onboarding';
  static const reading = '/reading';
  static const settings = '/settings';
  static const review = '/review';
}

/// Cached onboarding completion state to avoid hitting the repository
/// on every navigation event.
bool? _onboardingCompleted;

/// Call this after onboarding completes to update the cached state.
void markOnboardingCompleted() {
  _onboardingCompleted = true;
}

/// Call this to reset the cached onboarding flag (e.g. after clearing all data).
void resetOnboardingFlag() {
  _onboardingCompleted = false;
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) async {
    // Let splash handle its own navigation
    if (state.matchedLocation == AppRoutes.splash) return null;

    if (_onboardingCompleted == null) {
      final prefs = await getIt<PreferencesRepository>().get();
      _onboardingCompleted = prefs.onboardingCompleted;
    }
    final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
    if (!_onboardingCompleted! && !isOnboarding) {
      return AppRoutes.onboarding;
    }
    if (_onboardingCompleted! && isOnboarding) {
      return AppRoutes.home;
    }
    return null;
  },
  routes: [
    // Splash (initial route)
    GoRoute(
      path: AppRoutes.splash,
      builder: (ctx, state) => const SplashScreen(),
    ),
    // Onboarding (full-screen, no nav)
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (ctx, state) => slideUpFadePage(
        state: state,
        child: const OnboardingScreen(),
      ),
    ),
    // Shell route for persistent bottom nav (4 tabs)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (ctx, st) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.library,
              builder: (ctx, st) => const LibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.vocabulary,
              builder: (ctx, st) => const VocabularyScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.analytics,
              builder: (ctx, st) => const AnalyticsScreen(),
            ),
          ],
        ),
      ],
    ),
    // Full-screen routes (outside shell, no bottom nav)
    GoRoute(
      path: '${AppRoutes.reading}/:documentId',
      pageBuilder: (_, state) => slideUpFadePage(
        state: state,
        child: ReadingScreen(
          documentId: state.pathParameters['documentId']!,
          autoPlay: state.uri.queryParameters['autoPlay'] == 'true',
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (ctx, state) => slideUpFadePage(
        state: state,
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.review,
      pageBuilder: (ctx, state) => slideUpFadePage(
        state: state,
        child: const ReviewSessionScreen(),
      ),
    ),
  ],
);
