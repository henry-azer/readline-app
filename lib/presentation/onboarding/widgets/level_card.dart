import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:read_it/presentation/widgets/tap_scale.dart';

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
            // Icon bubble + level tag
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceContainerHigh
                        : AppColors.lightSurfaceContainerHigh,
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Icon(level.icon, size: 18, color: onSurface),
                ),
                const Spacer(),
                Text(
                  level.levelTag,
                  style: AppTypography.label.copyWith(
                    color: wpmColor,
                    fontSize: 9,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // Level name
            Text(
              level.label,
              style: AppTypography.titleMedium.copyWith(color: onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // WPM range
            Text(
              level.wpmRange,
              style: AppTypography.label.copyWith(
                color: wpmColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            // Description
            Expanded(
              child: Text(
                level.description,
                style: AppTypography.bodySmall.copyWith(
                  color: onSurfaceVariant,
                  fontSize: 11,
                  height: 1.4,
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
