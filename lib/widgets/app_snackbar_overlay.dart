import 'dart:async';

import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/app_snackbar.dart';

/// Animated overlay surface mounted by [AppSnackbar]. Slides up from the
/// bottom, auto-dismisses after [duration], and can be torn down imperatively
/// via [AppSnackbarOverlayState.cancelAndDisposeImmediately] when a new
/// snackbar wants to take over.
class AppSnackbarOverlay extends StatefulWidget {
  final String message;
  final AppSnackbarVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final double bottomOffset;
  final ValueChanged<AppSnackbarOverlayState> onStateCreated;
  final VoidCallback onRemove;

  const AppSnackbarOverlay({
    super.key,
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
  State<AppSnackbarOverlay> createState() => AppSnackbarOverlayState();
}

class AppSnackbarOverlayState extends State<AppSnackbarOverlay>
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
    final textColor = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
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
