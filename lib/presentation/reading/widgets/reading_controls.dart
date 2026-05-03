import 'dart:async';

import 'package:flutter/material.dart';
import 'package:read_it/core/di/injection.dart';
import 'package:read_it/core/services/haptic_service.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/constants/app_constants.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_breakpoints.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/entities/reading_state.dart';
import 'package:read_it/presentation/widgets/glass_container.dart';
import 'package:read_it/presentation/widgets/tap_scale.dart';

/// Glass-effect controls bar at the bottom of the reading screen.
///
/// Layout: [Font−] [Speed−] [Play/Pause + WPM] [Speed+] [Font+]
class ReadingControls extends StatelessWidget {
  final ReadingState state;
  final VoidCallback onPlayPause;
  final VoidCallback onSpeedDecrease;
  final VoidCallback onSpeedIncrease;
  final VoidCallback onFontSizeDecrease;
  final VoidCallback onFontSizeIncrease;
  final bool canDecreaseFontSize;
  final bool canIncreaseFontSize;
  final ValueChanged<double> onSeek;

  static const int _minWpm = AppConstants.minWpm;
  static const int _maxWpm = AppConstants.maxWpm;

  const ReadingControls({
    super.key,
    required this.state,
    required this.onPlayPause,
    required this.onSpeedDecrease,
    required this.onSpeedIncrease,
    required this.onFontSizeDecrease,
    required this.onFontSizeIncrease,
    required this.canDecreaseFontSize,
    required this.canIncreaseFontSize,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final screenWidth = context.screenWidth;

    final progress = state.totalWords > 0
        ? state.currentWordIndex / state.totalWords
        : 0.0;

    // ── Responsive sizing ──────────────────────────────────────────────
    final bool isCompact = screenWidth < AppBreakpoints.compact;
    final bool isExpanded = screenWidth >= AppBreakpoints.expanded;

    final double playSize = isCompact
        ? 48
        : isExpanded
        ? 64
        : 56;
    final double playIcon = isCompact
        ? 24
        : isExpanded
        ? 32
        : 28;
    final double speedSize = isCompact
        ? 30
        : isExpanded
        ? 42
        : 36;
    final double speedIcon = isCompact
        ? 14
        : isExpanded
        ? 20
        : 17;
    final double fontSize = isCompact
        ? 24
        : isExpanded
        ? 34
        : 28;
    final double fontIcon = isCompact
        ? 11
        : isExpanded
        ? 16
        : 13;
    final double labelSize = isCompact
        ? 9
        : isExpanded
        ? 12
        : 10;
    final double hPad = isCompact
        ? AppSpacing.sm
        : isExpanded
        ? AppSpacing.xl
        : AppSpacing.md;

    return GlassContainer(
      blur: 16,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppRadius.xl),
        topRight: Radius.circular(AppRadius.xl),
      ),
      padding: EdgeInsets.only(
        left: hPad,
        right: hPad,
        top: AppSpacing.sm,
        bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Seekable progress bar ─────────────────────────────────────
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              activeTrackColor: primary,
              inactiveTrackColor: onSurfaceVariant.withValues(alpha: 0.15),
              thumbColor: primary,
              overlayColor: primary.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(value: progress.clamp(0.0, 1.0), onChanged: onSeek),
          ),

          // ── Time labels — elapsed (left) / remaining (right) ──────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(_elapsedSeconds(state)),
                  style: AppTypography.label.copyWith(
                    color: onSurfaceVariant,
                    fontSize: labelSize,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  '-${_formatTime(_remainingSeconds(state))}',
                  style: AppTypography.label.copyWith(
                    color: onSurfaceVariant,
                    fontSize: labelSize,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Control row — all icons on same baseline ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CircleAction(
                icon: Icons.text_decrease_rounded,
                size: fontSize,
                iconSize: fontIcon,
                color: onSurfaceVariant,
                enabled: canDecreaseFontSize,
                onTap: onFontSizeDecrease,
              ),
              _CircleAction(
                icon: Icons.remove_rounded,
                size: speedSize,
                iconSize: speedIcon,
                color: onSurfaceVariant,
                enabled: state.currentWpm > _minWpm,
                onTap: onSpeedDecrease,
              ),
              _PlayPauseButton(
                isPlaying: state.isPlaying,
                primary: primary,
                onTap: onPlayPause,
                size: playSize,
                iconSize: playIcon,
              ),
              _CircleAction(
                icon: Icons.add_rounded,
                size: speedSize,
                iconSize: speedIcon,
                color: onSurfaceVariant,
                enabled: state.currentWpm < _maxWpm,
                onTap: onSpeedIncrease,
              ),
              _CircleAction(
                icon: Icons.text_increase_rounded,
                size: fontSize,
                iconSize: fontIcon,
                color: onSurfaceVariant,
                enabled: canIncreaseFontSize,
                onTap: onFontSizeIncrease,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.smd),

          // ── Speed label — centered below controls ──────────────────────
          Text(
            '${state.currentWpm} ${AppStrings.readingWpm.tr}',
            style: AppTypography.label.copyWith(
              color: onSurfaceVariant,
              fontSize: labelSize,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Time formatting ────────────────────────────────────────────────────────────

int _elapsedSeconds(ReadingState state) {
  final wpm = state.currentWpm > 0 ? state.currentWpm : 1;
  final words = state.currentWordIndex.clamp(0, state.totalWords);
  return (words * 60 / wpm).round();
}

int _remainingSeconds(ReadingState state) {
  final wpm = state.currentWpm > 0 ? state.currentWpm : 1;
  final words = (state.totalWords - state.currentWordIndex).clamp(
    0,
    state.totalWords,
  );
  return (words * 60 / wpm).round();
}

String _formatTime(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;
  final ss = s.toString().padLeft(2, '0');
  if (h > 0) {
    final mm = m.toString().padLeft(2, '0');
    return '$h:$mm:$ss';
  }
  return '$m:$ss';
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final Color primary;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.primary,
    required this.onTap,
    this.size = 56,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      scale: 0.9,
      onTap: () {
        getIt<HapticService>().medium();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppDurations.normal,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: context.isDark
              ? AppColors.onPrimary
              : AppColors.lightOnPrimary,
          size: iconSize,
        ),
      ),
    );
  }
}

class _CircleAction extends StatefulWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    this.size = 36,
    this.iconSize = 18,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_CircleAction> createState() => _CircleActionState();
}

class _CircleActionState extends State<_CircleAction> {
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
  void didUpdateWidget(_CircleAction oldWidget) {
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
