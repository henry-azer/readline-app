import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/celebration_data.dart';
import 'package:readline_app/widgets/celebration_tier_helpers.dart';

/// Body for non-streak celebrations (daily target, words milestone): tier
/// badge circle, tier label pill, title, and message.
class CelebrationStandardBody extends StatelessWidget {
  final CelebrationData celebration;
  final (Color, Color) tierColors;
  final String title;
  final String message;

  const CelebrationStandardBody({
    super.key,
    required this.celebration,
    required this.tierColors,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onPrimary = isDark ? AppColors.onPrimary : AppColors.lightOnPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [tierColors.$1, tierColors.$2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(tierIcon(celebration.tier), size: 36, color: onPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: tierColors.$1.withValues(alpha: 0.15),
            borderRadius: AppRadius.fullBorder,
          ),
          child: Text(
            tierLabel(celebration.tier),
            style: AppTypography.celebrationTierLabel.copyWith(
              color: tierColors.$1,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.headlineMedium.copyWith(color: onSurface),
        ),
        const SizedBox(height: AppSpacing.xs),

        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
