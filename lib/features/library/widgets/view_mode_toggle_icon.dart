import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';

/// Single icon button inside the library's grid/list view mode toggle.
class ViewModeToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primary;
  final Color onSurfaceVariant;
  final Color surfaceHigh;
  final bool isDark;

  const ViewModeToggleIcon({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.primary,
    required this.onSurfaceVariant,
    required this.surfaceHigh,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBg = isDark
        ? AppColors.surfaceContainerHighest
        : AppColors.lightSurfaceContainerHighest;

    return GestureDetector(
      onTap: isSelected ? null : onTap,
      child: AnimatedContainer(
        duration: AppDurations.calm,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : AppColors.transparent,
          borderRadius: AppRadius.smBorder,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? primary : onSurfaceVariant,
        ),
      ),
    );
  }
}
