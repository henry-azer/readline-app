import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/home/viewmodels/home_viewmodel.dart';

class StatsBar extends StatelessWidget {
  final HomeStats stats;
  final bool hasDocuments;

  const StatsBar({super.key, required this.stats, required this.hasDocuments});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final surfaceColor = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    final borderColor = isDark
        ? AppColors.outlineVariant
        : AppColors.lightOutlineVariant;

    final avgSpeedLabel = hasDocuments && stats.avgSpeedWpm > 0
        ? '${stats.avgSpeedWpm}'
        : '---';
    final wordsLabel = hasDocuments && stats.totalWordsRead > 0
        ? _formatWords(stats.totalWordsRead)
        : '0';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          _StatItem(
            label: AppStrings.homeStatDocuments.tr,
            value: '${stats.totalDocs}',
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _StatItem(
            label: AppStrings.homeStatSpeed.tr,
            value: avgSpeedLabel,
            isDark: isDark,
          ),
          _Divider(isDark: isDark),
          _StatItem(
            label: AppStrings.homeStatWords.tr,
            value: wordsLabel,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  String _formatWords(int words) {
    if (words >= 1000000) {
      return '${(words / 1000000).toStringAsFixed(1)}M';
    }
    if (words >= 1000) {
      return '${(words / 1000).toStringAsFixed(0)}k';
    }
    return '$words';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _StatItem({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: onSurface,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: (isDark ? AppColors.outlineVariant : AppColors.lightOutlineVariant)
          .withValues(alpha: 0.5),
    );
  }
}
