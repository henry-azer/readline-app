import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/glass_container.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class TargetChip extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final Color primaryColor;
  final Color onSurfaceVariant;
  final bool isDark;
  final VoidCallback onTap;

  const TargetChip({
    super.key,
    required this.minutes,
    required this.isSelected,
    required this.primaryColor,
    required this.onSurfaceVariant,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = '$minutes ${AppStrings.homeMinutesSuffix.tr}';
    final style = isSelected
        ? AppTypography.targetChipSelected
        : AppTypography.labelMedium;

    return TapScale(
      onTap: onTap,
      child: GlassContainer(
        blur: 8,
        borderRadius: AppRadius.mdBorder,
        backgroundColor: isSelected
            ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.15)
            : AppColors.glassBackground(isDark),
        borderColor: isSelected
            ? primaryColor.withValues(alpha: 0.4)
            : AppColors.glassBorder(isDark),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smd,
        ),
        child: Text(
          label,
          style: style.copyWith(
            color: isSelected ? primaryColor : onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
