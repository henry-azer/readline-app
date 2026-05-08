import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/data/models/streak_model.dart';
import 'package:readline_app/features/home/widgets/daily_goal_glass_card.dart';
import 'package:readline_app/features/home/widgets/streak_glass_card.dart';

class ProgressRow extends StatelessWidget {
  final StreakModel streak;
  final double todayMinutes;
  final int targetMinutes;
  final VoidCallback? onStreakTap;
  final VoidCallback? onGoalEditTap;

  const ProgressRow({
    super.key,
    required this.streak,
    required this.todayMinutes,
    required this.targetMinutes,
    this.onStreakTap,
    this.onGoalEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreakGlassCard(
                streak: streak,
                todayTargetMet: todayMinutes >= targetMinutes,
                onTap: onStreakTap,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: DailyGoalGlassCard(
                todayMinutes: todayMinutes,
                targetMinutes: targetMinutes,
                onEditTap: onGoalEditTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
