import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/streak_model.dart';

/// Animated streak badge shown in the reading screen app bar.
/// Shows fire icon + "{n} DAY STREAK" in amber/tertiary.
class StreakBadge extends StatefulWidget {
  final StreakModel streak;

  const StreakBadge({super.key, required this.streak});

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.slow);
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.streak.currentStreak;
    final milestone = widget.streak.milestoneLabel;

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer.withValues(alpha: 0.9),
            borderRadius: AppRadius.fullBorder,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 14,
                color: AppColors.lightTertiary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                milestone != null
                    ? AppStrings.readingStreakDays.trParams({
                        'n': '$count',
                        'milestone': milestone.toUpperCase(),
                      })
                    : AppStrings.readingStreakMilestone.trParams({
                        'n': '$count',
                      }),
                style: AppTypography.readingMicroLabel.copyWith(
                  color: AppColors.lightTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
