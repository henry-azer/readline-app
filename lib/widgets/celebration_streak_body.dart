import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/celebration_data.dart';
import 'package:readline_app/widgets/celebration_tier_helpers.dart';

/// Padlock-checkpoint-style body for streak-milestone celebrations: fire
/// emoji, gradient streak number, "DAY STREAK" label, tier pill, message.
class CelebrationStreakBody extends StatelessWidget {
  static const String _fireEmoji = '\u{1F525}';

  final CelebrationData celebration;
  final (Color, Color) tierColors;

  const CelebrationStreakBody({
    super.key,
    required this.celebration,
    required this.tierColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final mutedColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final messageKey = celebration.messageKey;
    final message = messageKey == 'celebration.combinedMessage'
        ? AppStrings.celebrationCombinedMessage.trParams({
            'n': '${celebration.streakCount}',
          })
        : AppStrings.celebrationStreakMessage.trParams({
            'n': '${celebration.streakCount}',
          });

    final numberGradient = LinearGradient(
      colors: [tierColors.$1, tierColors.$2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_fireEmoji, style: AppTypography.celebrationEmoji),
        const SizedBox(height: AppSpacing.md),

        ShaderMask(
          shaderCallback: (rect) => numberGradient.createShader(rect),
          child: Text(
            '${celebration.streakCount}',
            style: AppTypography.celebrationStreakNumber.copyWith(
              color: AppColors.onSurface, // overridden by ShaderMask
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),

        ShaderMask(
          shaderCallback: (rect) => numberGradient.createShader(rect),
          child: Text(
            AppStrings.homeStreakLabel.tr,
            style: AppTypography.celebrationStreakLabel.copyWith(
              color: AppColors.onSurface, // overridden by ShaderMask
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

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
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: mutedColor,
            height: 1.4,
          ),
        ),

        if (celebration.minutesRead > 0 &&
            messageKey == 'celebration.combinedMessage') ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.celebrationDailyTargetMessage.trParams({
              'n': '${celebration.minutesRead.round()}',
            }),
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ],
    );
  }
}
