import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/data/models/celebration_data.dart';

/// Resolves the `(start, end)` gradient pair for a celebration tier across
/// light and dark themes.
(Color, Color) resolveTierColors(CelebrationTier tier, bool isDark) {
  return switch (tier) {
    CelebrationTier.bronze => (
      isDark ? AppColors.tierBronze : AppColors.lightTierBronze,
      isDark ? AppColors.tierBronzeEnd : AppColors.lightTierBronzeEnd,
    ),
    CelebrationTier.silver => (
      isDark ? AppColors.tierSilver : AppColors.lightTierSilver,
      isDark ? AppColors.tierSilverEnd : AppColors.lightTierSilverEnd,
    ),
    CelebrationTier.gold => (
      isDark ? AppColors.tierGold : AppColors.lightTierGold,
      isDark ? AppColors.tierGoldEnd : AppColors.lightTierGoldEnd,
    ),
    CelebrationTier.platinum => (
      isDark ? AppColors.tierPlatinum : AppColors.lightTierPlatinum,
      isDark ? AppColors.tierPlatinumEnd : AppColors.lightTierPlatinumEnd,
    ),
    CelebrationTier.diamond => (
      isDark ? AppColors.tierDiamond : AppColors.lightTierDiamond,
      isDark ? AppColors.tierDiamondEnd : AppColors.lightTierDiamondEnd,
    ),
  };
}

/// Localized name for a celebration tier ("Bronze", "Silver", …).
String tierLabel(CelebrationTier tier) {
  return switch (tier) {
    CelebrationTier.bronze => AppStrings.celebrationTierBronze.tr,
    CelebrationTier.silver => AppStrings.celebrationTierSilver.tr,
    CelebrationTier.gold => AppStrings.celebrationTierGold.tr,
    CelebrationTier.platinum => AppStrings.celebrationTierPlatinum.tr,
    CelebrationTier.diamond => AppStrings.celebrationTierDiamond.tr,
  };
}

/// Material icon paired with each celebration tier.
IconData tierIcon(CelebrationTier tier) {
  return switch (tier) {
    CelebrationTier.bronze => Icons.local_fire_department_rounded,
    CelebrationTier.silver => Icons.auto_awesome_rounded,
    CelebrationTier.gold => Icons.emoji_events_rounded,
    CelebrationTier.platinum => Icons.diamond_rounded,
    CelebrationTier.diamond => Icons.workspace_premium_rounded,
  };
}
