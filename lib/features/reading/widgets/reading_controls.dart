import 'package:flutter/material.dart';
import 'package:readline_app/core/constants/app_constants.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_breakpoints.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/entities/reading_state.dart';
import 'package:readline_app/features/reading/widgets/circle_action_button.dart';
import 'package:readline_app/features/reading/widgets/play_pause_button.dart';
import 'package:readline_app/widgets/glass_container.dart';

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

    final double playSize = isCompact ? 48 : isExpanded ? 64 : 56;
    final double playIcon = isCompact ? 24 : isExpanded ? 32 : 28;
    final double speedSize = isCompact ? 30 : isExpanded ? 42 : 36;
    final double speedIcon = isCompact ? 14 : isExpanded ? 20 : 17;
    final double fontSize = isCompact ? 24 : isExpanded ? 34 : 28;
    final double fontIcon = isCompact ? 11 : isExpanded ? 16 : 13;
    final double labelSize = isCompact ? 9 : isExpanded ? 12 : 10;
    final double hPad = isCompact
        ? AppSpacing.sm
        : isExpanded
        ? AppSpacing.xl
        : AppSpacing.md;

    final captionStyle = AppTypography.tabularCaption(
      fontSize: labelSize,
    ).copyWith(color: onSurfaceVariant);

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
                Text(_formatTime(_elapsedSeconds(state)), style: captionStyle),
                Text(
                  '-${_formatTime(_remainingSeconds(state))}',
                  style: captionStyle,
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
              CircleActionButton(
                icon: Icons.text_decrease_rounded,
                size: fontSize,
                iconSize: fontIcon,
                color: onSurfaceVariant,
                enabled: canDecreaseFontSize,
                onTap: onFontSizeDecrease,
              ),
              CircleActionButton(
                icon: Icons.remove_rounded,
                size: speedSize,
                iconSize: speedIcon,
                color: onSurfaceVariant,
                enabled: state.currentWpm > _minWpm,
                onTap: onSpeedDecrease,
              ),
              PlayPauseButton(
                isPlaying: state.isPlaying,
                primary: primary,
                onTap: onPlayPause,
                size: playSize,
                iconSize: playIcon,
              ),
              CircleActionButton(
                icon: Icons.add_rounded,
                size: speedSize,
                iconSize: speedIcon,
                color: onSurfaceVariant,
                enabled: state.currentWpm < _maxWpm,
                onTap: onSpeedIncrease,
              ),
              CircleActionButton(
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
            style: captionStyle,
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
