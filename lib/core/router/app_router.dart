import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/router/app_page_transitions.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/data/contracts/preferences_repository.dart';
import 'package:readline_app/features/shell/app_shell.dart';
import 'package:readline_app/features/home/screens/home_screen.dart';
import 'package:readline_app/features/library/screens/library_screen.dart';
import 'package:readline_app/features/vocabulary/screens/vocabulary_screen.dart';
import 'package:readline_app/features/analytics/screens/analytics_screen.dart';
import 'package:readline_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:readline_app/features/reading/screens/reading_screen.dart';
import 'package:readline_app/features/settings/screens/settings_screen.dart';
import 'package:readline_app/features/splash/screens/splash_screen.dart';
import 'package:readline_app/features/vocabulary/screens/review_session_screen.dart';
import 'package:readline_app/features/about/screens/about_screen.dart';
import 'package:readline_app/features/about/screens/privacy_policy_screen.dart';
import 'package:readline_app/features/about/screens/terms_of_service_screen.dart';
import 'package:readline_app/features/settings/screens/magic_content_settings_screen.dart';
import 'package:readline_app/features/support/screens/bug_report_screen.dart';
import 'package:readline_app/features/support/screens/help_support_screen.dart';
import 'package:readline_app/features/support/screens/rate_app_screen.dart';

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
  static const about = '/about';
  static const privacyPolicy = '/privacy-policy';
  static const termsOfService = '/terms-of-service';
  static const helpSupport = '/help-support';
  static const bugReport = '/bug-report';
  static const rateApp = '/rate-app';
  static const magicContentSettings = '/settings/magic-content';
}

/// Per-branch navigator keys for the persistent shell. Exposed so the
/// shell's center "+" button can push modal routes on the *active branch's*
/// navigator (keeping the bottom nav bar visible) instead of the root
/// navigator (which covers the whole screen).
final List<GlobalKey<NavigatorState>> shellBranchNavigatorKeys = [
  GlobalKey<NavigatorState>(debugLabel: 'home_branch_nav'),
  GlobalKey<NavigatorState>(debugLabel: 'library_branch_nav'),
  GlobalKey<NavigatorState>(debugLabel: 'vocab_branch_nav'),
  GlobalKey<NavigatorState>(debugLabel: 'settings_branch_nav'),
];

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
      pageBuilder: (ctx, state) =>
          slideUpFadePage(state: state, child: const OnboardingScreen()),
    ),
    // Shell route for persistent bottom nav (4 tabs)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: shellBranchNavigatorKeys[0],
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (ctx, st) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: shellBranchNavigatorKeys[1],
          routes: [
            GoRoute(
              path: AppRoutes.library,
              builder: (ctx, st) => const LibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: shellBranchNavigatorKeys[2],
          routes: [
            GoRoute(
              path: AppRoutes.vocabulary,
              builder: (ctx, st) => const VocabularyScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: shellBranchNavigatorKeys[3],
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (ctx, st) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    // Full-screen routes (outside shell, no bottom nav)
    GoRoute(
      path: '${AppRoutes.reading}/:documentId',
      pageBuilder: (_, state) => immersiveFadePage(
        state: state,
        child: ReadingScreen(
          documentId: state.pathParameters['documentId']!,
          restart: state.uri.queryParameters['restart'] == 'true',
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.analytics,
      pageBuilder: (ctx, state) =>
          slideUpFadePage(state: state, child: const AnalyticsScreen()),
    ),
    GoRoute(
      path: AppRoutes.review,
      pageBuilder: (ctx, state) =>
          slideUpFadePage(state: state, child: const ReviewSessionScreen()),
    ),
    GoRoute(
      path: AppRoutes.about,
      pageBuilder: (ctx, state) =>
          slideUpFadePage(state: state, child: const AboutScreen()),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      pageBuilder: (ctx, state) =>
          slideUpFadePage(state: state, child: const PrivacyPolicyScreen()),
    ),
    GoRoute(
      path: AppRoutes.termsOfService,
      pageBuilder: (ctx, state) =>
          slideUpFadePage(state: state, child: const TermsOfServiceScreen()),
    ),
    GoRoute(
      path: AppRoutes.helpSupport,
      pageBuilder: (ctx, state) =>
          slideUpFadePage(state: state, child: const HelpSupportScreen()),
    ),
    GoRoute(
      path: AppRoutes.bugReport,
      pageBuilder: (ctx, state) =>
          slideUpFadePage(state: state, child: const BugReportScreen()),
    ),
    GoRoute(
      path: AppRoutes.rateApp,
      pageBuilder: (ctx, state) =>
          slideUpFadePage(state: state, child: const RateAppScreen()),
    ),
    GoRoute(
      path: AppRoutes.magicContentSettings,
      pageBuilder: (ctx, state) => slideUpFadePage(
        state: state,
        child: const MagicContentSettingsScreen(),
      ),
    ),
  ],
);
