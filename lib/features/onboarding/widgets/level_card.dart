import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/models/reading_level.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class LevelCard extends StatelessWidget {
  final ReadingLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final surface = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final outlineVariant = isDark
        ? AppColors.outlineVariant
        : AppColors.lightOutlineVariant;
    final iconBg = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;

    final wpmColor = Color.lerp(
      primary,
      isDark ? AppColors.tertiary : AppColors.lightTertiaryContainer,
      (level.levelNumber - 1) / 3,
    )!;

    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.short,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: isSelected ? primary : outlineVariant.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: isDark ? 0.15 : 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Icon(level.icon, size: 18, color: onSurface),
                ),
                const Spacer(),
                Text(
                  level.levelTag,
                  style: AppTypography.levelTag.copyWith(color: wpmColor),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              level.label,
              style: AppTypography.titleMedium.copyWith(color: onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.micro),
            Text(
              level.wpmRange,
              style: AppTypography.levelWpm.copyWith(color: wpmColor),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Expanded(
              child: Text(
                level.description,
                style: AppTypography.levelDescription.copyWith(
                  color: onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
