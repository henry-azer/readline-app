import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_curves.dart';
import 'package:readline_app/core/theme/app_durations.dart';

/// Slide-up + fade page transition for full-screen routes.
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

/// Immersive fade-through-black transition for the reading screen.
/// 0–40%: fade to black. 40–100%: fade in the new screen from black.
CustomTransitionPage<void> immersiveFadePage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 600),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return Stack(
        children: [
          // Black curtain — fully opaque during the middle of the transition
          FadeTransition(
            opacity: TweenSequence<double>([
              TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
              TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 60),
            ]).animate(animation),
            child: const ColoredBox(
              color: AppColors.black,
              child: SizedBox.expand(),
            ),
          ),
          // Child fades in during the second half
          FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
            ),
            child: child,
          ),
        ],
      );
    },
  );
}
