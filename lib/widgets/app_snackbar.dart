import 'dart:async';

import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

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
  static _AppSnackbarOverlayState? _currentState;

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
      builder: (ctx) => _AppSnackbarOverlay(
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

class _AppSnackbarOverlay extends StatefulWidget {
  final String message;
  final AppSnackbarVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final double bottomOffset;
  final ValueChanged<_AppSnackbarOverlayState> onStateCreated;
  final VoidCallback onRemove;

  const _AppSnackbarOverlay({
    required this.message,
    required this.variant,
    required this.actionLabel,
    required this.onAction,
    required this.duration,
    required this.bottomOffset,
    required this.onStateCreated,
    required this.onRemove,
  });

  @override
  State<_AppSnackbarOverlay> createState() => _AppSnackbarOverlayState();
}

class _AppSnackbarOverlayState extends State<_AppSnackbarOverlay>
    with SingleTickerProviderStateMixin {
  static const _enterDuration = Duration(milliseconds: 320);
  static const _exitDuration = Duration(milliseconds: 220);

  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _autoDismiss;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    widget.onStateCreated(this);
    _controller = AnimationController(
      vsync: this,
      duration: _enterDuration,
      reverseDuration: _exitDuration,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _controller.forward();
    _autoDismiss = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_disposed || !mounted) return;
    _autoDismiss?.cancel();
    try {
      await _controller.reverse();
    } catch (_) {
      // controller can be disposed mid-reverse if cancelled
    }
    if (!_disposed) widget.onRemove();
  }

  /// Cancels timers and removes the overlay synchronously — used when a new
  /// snackbar wants to take over without waiting for the old one's exit
  /// animation to finish.
  void cancelAndDisposeImmediately() {
    _disposed = true;
    _autoDismiss?.cancel();
    if (_controller.isAnimating) _controller.stop();
  }

  @override
  void dispose() {
    _disposed = true;
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerHigh;
    final textColor = isDark
        ? AppColors.onSurface
        : AppColors.lightOnSurface;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final accent = _accent(widget.variant, isDark: isDark);
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final mediaPaddingBottom = MediaQuery.paddingOf(context).bottom;
    final hasAction = widget.actionLabel != null && widget.onAction != null;

    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: widget.bottomOffset + mediaPaddingBottom,
      child: SafeArea(
        top: false,
        bottom: false,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Material(
              color: AppColors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: AppRadius.mdBorder,
                  boxShadow: [
                    isDark
                        ? AppColors.darkAmbientShadow(blur: 24, opacity: 0.35)
                        : AppColors.ambientShadow(blur: 16, opacity: 0.10),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(width: 4, color: accent),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Text(
                            widget.message,
                            style: AppTypography.bodyMedium.copyWith(
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      if (hasAction)
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: primary,
                            textStyle: AppTypography.button,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                          ),
                          onPressed: () {
                            widget.onAction?.call();
                            _dismiss();
                          },
                          child: Text(widget.actionLabel!),
                        )
                      else
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: onSurfaceVariant,
                          ),
                          onPressed: _dismiss,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Color _accent(AppSnackbarVariant v, {required bool isDark}) {
    switch (v) {
      case AppSnackbarVariant.success:
        return isDark ? AppColors.success : AppColors.lightSuccess;
      case AppSnackbarVariant.error:
        return isDark ? AppColors.error : AppColors.lightError;
      case AppSnackbarVariant.info:
        return isDark ? AppColors.primary : AppColors.lightPrimary;
    }
  }
}
