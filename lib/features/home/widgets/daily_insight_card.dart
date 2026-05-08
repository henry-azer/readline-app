import 'dart:math';

import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

const _tipKeys = [
  AppStrings.homeTip1,
  AppStrings.homeTip2,
  AppStrings.homeTip3,
  AppStrings.homeTip4,
  AppStrings.homeTip5,
  AppStrings.homeTip6,
  AppStrings.homeTip7,
  AppStrings.homeTip8,
  AppStrings.homeTip9,
  AppStrings.homeTip10,
  AppStrings.homeTip11,
  AppStrings.homeTip12,
  AppStrings.homeTip13,
  AppStrings.homeTip14,
  AppStrings.homeTip15,
  AppStrings.homeTip16,
  AppStrings.homeTip17,
  AppStrings.homeTip18,
  AppStrings.homeTip19,
  AppStrings.homeTip20,
  AppStrings.homeTip21,
  AppStrings.homeTip22,
  AppStrings.homeTip23,
  AppStrings.homeTip24,
  AppStrings.homeTip25,
];

class DailyInsightCard extends StatefulWidget {
  const DailyInsightCard({super.key});

  @override
  State<DailyInsightCard> createState() => _DailyInsightCardState();
}

class _DailyInsightCardState extends State<DailyInsightCard> {
  /// Picked once when the home screen mounts after each app launch.
  /// Stays stable across rebuilds and tab switches.
  late final int _tipIndex = Random().nextInt(_tipKeys.length);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    final tip = _tipKeys[_tipIndex].tr;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: primary.withValues(alpha: 0.15), width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 14, color: primary),
              const SizedBox(width: AppSpacing.sxs),
              Text(
                AppStrings.homeTipTitle.tr,
                style: AppTypography.homeBadgeLabel.copyWith(color: primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tip,
            style: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
