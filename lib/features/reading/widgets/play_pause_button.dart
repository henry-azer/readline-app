import 'package:flutter/material.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/services/haptic_service.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final Color primary;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const PlayPauseButton({
    super.key,
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
