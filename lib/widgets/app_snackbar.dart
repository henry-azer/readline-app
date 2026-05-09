import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/widgets/app_snackbar_overlay.dart';

/// Visual flavour of an [AppSnackbar]. Drives the leading accent stripe
/// color so the user can see at a glance whether something succeeded,
/// failed, or is just informational.
enum AppSnackbarVariant { info, success, error }

/// Single canonical snackbar surface for the app — uses the design tokens
/// (surface palette, typography, spacing, radius) so every snackbar across
/// the app reads as the same component.
///
/// Implementation note: rather than [ScaffoldMessenger.showSnackBar], we
/// drive an [OverlayEntry] ourselves. ScaffoldMessenger's floating snackbar
/// anchors to the *inner* Scaffold (the per-screen one), which doesn't know
/// about the shell's bottom nav — that left snackbars either too high or
/// hidden behind the shell. The overlay approach lets us pin the snackbar
/// directly above the shell nav and run a custom slide+fade animation.
abstract final class AppSnackbar {
  // Total height of the shell's bottom nav above the system safe area.
  // Mirrors `kNavBarContentHeight (64) + _centerButtonOverlap (22)` from
  // `readline_nav_bar.dart`. Hardcoded here to avoid a cross-feature import
  // — if those nav constants change, bump this.
  static const double _shellNavHeight = 86.0;

  static OverlayEntry? _current;
  static AppSnackbarOverlayState? _currentState;

  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(
    context,
    message,
    variant: AppSnackbarVariant.info,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(
    context,
    message,
    variant: AppSnackbarVariant.success,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(
    context,
    message,
    variant: AppSnackbarVariant.error,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static void _show(
    BuildContext context,
    String message, {
    required AppSnackbarVariant variant,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final hasAction = actionLabel != null && onAction != null;
    final duration = hasAction
        ? AppDurations.snackbarLong
        : AppDurations.snackbar;

    // Tear down any in-flight snackbar instantly so the new one slides up
    // from the bottom instead of stacking on top of the old one.
    _currentState?.cancelAndDisposeImmediately();
    _current?.remove();
    _current = null;
    _currentState = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => AppSnackbarOverlay(
        message: message,
        variant: variant,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
        bottomOffset: _shellNavHeight + AppSpacing.xs,
        onStateCreated: (state) => _currentState = state,
        onRemove: () {
          if (_current == entry) {
            _current = null;
            _currentState = null;
          }
          entry.remove();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}
