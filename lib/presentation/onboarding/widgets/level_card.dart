import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/theme/app_colors.dart';
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

    // Advanced level gets a highlighted accent on the WPM range
    final isAdvanced = level.id == 'advanced';
    final wpmColor = isAdvanced
        ? (isDark ? AppColors.tertiary : const Color(0xFFB44B3C))
        : primary;

    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.md),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon bubble
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceContainerHigh
                        : AppColors.lightSurfaceContainer,
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Icon(level.icon, size: 22, color: onSurface),
                ),
                const Spacer(),
                // Level tag
                Text(
                  level.levelTag,
                  style: AppTypography.label.copyWith(
                    color: isAdvanced ? wpmColor : onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Level name
            Text(
              level.label,
              style: AppTypography.headlineMedium.copyWith(color: onSurface),
            ),
            const SizedBox(height: AppSpacing.xxs),
            // WPM range
            Text(
              level.wpmRange,
              style: AppTypography.labelMedium.copyWith(
                color: wpmColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Description
            Text(
              level.description,
              style: AppTypography.bodySmall.copyWith(
                color: onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
