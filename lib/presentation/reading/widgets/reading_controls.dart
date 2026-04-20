import 'package:flutter/material.dart';
import 'package:read_it/core/constants/app_constants.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/entities/reading_state.dart';
import 'package:read_it/presentation/widgets/glass_container.dart';

/// Glass-effect controls bar at the bottom of the reading screen.
///
/// Displays:
/// - Font/typography toggle (left)
/// - Speed display with decrease/increase buttons
/// - Play/Pause button (center, prominent)
/// - Progress (words read / total)
/// - Stop button (right)
class ReadingControls extends StatelessWidget {
  final ReadingState state;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final VoidCallback onSpeedDecrease;
  final VoidCallback onSpeedIncrease;

  static const int _minWpm = AppConstants.minWpm;
  static const int _maxWpm = AppConstants.maxWpm;

  const ReadingControls({
    super.key,
    required this.state,
    required this.onPlayPause,
    required this.onStop,
    required this.onSpeedDecrease,
    required this.onSpeedIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    final progress = state.totalWords > 0
        ? state.currentWordIndex / state.totalWords
        : 0.0;

    return GlassContainer(
      blur: 16,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppRadius.xl),
        topRight: Radius.circular(AppRadius.xl),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Progress bar ────────────────────────────────────────────────
          ClipRRect(
            borderRadius: AppRadius.fullBorder,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: onSurfaceVariant.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Control row ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left — font toggle (decorative / future use)
              _IconAction(
                icon: Icons.text_fields_rounded,
                label: AppStrings.readingFontSize.tr,
                color: onSurfaceVariant,
                onTap: () {}, // Font cycle — future feature
              ),

              // Speed controls
              _SpeedControl(
                wpm: state.currentWpm,
                onDecrease: onSpeedDecrease,
                onIncrease: onSpeedIncrease,
                canDecrease: state.currentWpm > _minWpm,
                canIncrease: state.currentWpm < _maxWpm,
                primary: primary,
                onSurface: onSurface,
                onSurfaceVariant: onSurfaceVariant,
              ),

              // Center — Play/Pause (prominent)
              _PlayPauseButton(
                isPlaying: state.isPlaying,
                primary: primary,
                onTap: onPlayPause,
              ),

              // Progress label
              _ProgressLabel(
                wordsRead: state.currentWordIndex,
                total: state.totalWords,
                onSurfaceVariant: onSurfaceVariant,
              ),

              // Right — Stop / bookmark
              _IconAction(
                icon: Icons.stop_rounded,
                label: null,
                color: onSurfaceVariant,
                onTap: onStop,
                tooltip: AppStrings.readingEndSession.tr,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final Color primary;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
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
          size: 28,
        ),
      ),
    );
  }
}

class _SpeedControl extends StatelessWidget {
  final int wpm;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final bool canDecrease;
  final bool canIncrease;
  final Color primary;
  final Color onSurface;
  final Color onSurfaceVariant;

  const _SpeedControl({
    required this.wpm,
    required this.onDecrease,
    required this.onIncrease,
    required this.canDecrease,
    required this.canIncrease,
    required this.primary,
    required this.onSurface,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: canDecrease ? onDecrease : null,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: onSurfaceVariant.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.remove,
              size: 14,
              color: canDecrease
                  ? onSurfaceVariant
                  : onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$wpm',
              style: AppTypography.titleMedium.copyWith(
                color: onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              AppStrings.readingWpm.tr,
              style: AppTypography.label.copyWith(
                color: onSurfaceVariant,
                fontSize: 8,
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          onTap: canIncrease ? onIncrease : null,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: onSurfaceVariant.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              size: 14,
              color: canIncrease
                  ? onSurfaceVariant
                  : onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressLabel extends StatelessWidget {
  final int wordsRead;
  final int total;
  final Color onSurfaceVariant;

  const _ProgressLabel({
    required this.wordsRead,
    required this.total,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? ((wordsRead / total) * 100).round() : 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$pct%',
          style: AppTypography.titleMedium.copyWith(
            color: onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        Text(
          '${_compact(wordsRead)}/${_compact(total)}',
          style: AppTypography.label.copyWith(
            color: onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  String _compact(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            if (label != null)
              Text(
                label!,
                style: AppTypography.label.copyWith(color: color, fontSize: 8),
              ),
          ],
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
