import 'dart:async';

import 'package:flutter/material.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/theme/app_durations.dart';

/// Circular icon button used in the reading controls bar.
///
/// Supports tap and press-and-hold repeat (after a short delay). Fires a
/// `light` haptic on initial press but not on repeat ticks.
class CircleActionButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const CircleActionButton({
    super.key,
    required this.icon,
    this.size = 36,
    this.iconSize = 18,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<CircleActionButton> createState() => _CircleActionButtonState();
}

class _CircleActionButtonState extends State<CircleActionButton> {
  static const _holdDelay = Duration(milliseconds: 400);
  static const _repeatInterval = Duration(milliseconds: 80);

  bool _pressed = false;
  Timer? _holdDelayTimer;
  Timer? _repeatTimer;

  void _startPress() {
    if (!widget.enabled) return;
    setState(() => _pressed = true);
    getIt<HapticService>().light();
    widget.onTap();
    _holdDelayTimer = Timer(_holdDelay, _beginRepeating);
  }

  void _beginRepeating() {
    _repeatTimer = Timer.periodic(_repeatInterval, (_) {
      if (!widget.enabled) {
        _endPress();
        return;
      }
      widget.onTap();
    });
  }

  void _endPress() {
    _holdDelayTimer?.cancel();
    _holdDelayTimer = null;
    _repeatTimer?.cancel();
    _repeatTimer = null;
    if (mounted && _pressed) setState(() => _pressed = false);
  }

  @override
  void didUpdateWidget(CircleActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && (_holdDelayTimer != null || _repeatTimer != null)) {
      _endPress();
    }
  }

  @override
  void dispose() {
    _holdDelayTimer?.cancel();
    _repeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final circle = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        widget.icon,
        size: widget.iconSize,
        color: widget.enabled
            ? widget.color
            : widget.color.withValues(alpha: 0.3),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => _startPress() : null,
      onTapUp: (_) => _endPress(),
      onTapCancel: _endPress,
      child: reduceMotion
          ? AnimatedOpacity(
              opacity: _pressed ? 0.7 : 1.0,
              duration: AppDurations.instant,
              child: circle,
            )
          : AnimatedScale(
              scale: _pressed ? 0.95 : 1.0,
              duration: AppDurations.quick,
              child: circle,
            ),
    );
  }
}
