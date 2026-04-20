import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/theme/app_curves.dart';
import 'package:read_it/core/theme/app_durations.dart';

/// Slide-up + fade page transition for full-screen routes.
///
/// Enter: slides up 30px while fading in (350ms, easeOutCubic).
/// Pop: slides down 30px while fading out (350ms, easeInCubic).
CustomTransitionPage<void> slideUpFadePage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.calm,
    reverseTransitionDuration: AppDurations.calm,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AppCurves.enter,
        reverseCurve: AppCurves.exit,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}
