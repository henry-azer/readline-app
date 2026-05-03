import 'package:flutter/material.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/data/enums/app_enums.dart';

class ViewModeToggle extends StatelessWidget {
  final ViewMode viewMode;
  final VoidCallback onToggle;
  final bool isDark;

  const ViewModeToggle({
    super.key,
    required this.viewMode,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceHigh = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: surfaceHigh,
        borderRadius: AppRadius.smBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleIcon(
            icon: Icons.grid_view_rounded,
            isSelected: viewMode == ViewMode.grid,
            onTap: onToggle,
            primary: primary,
            onSurfaceVariant: onSurfaceVariant,
            surfaceHigh: surfaceHigh,
            isDark: isDark,
          ),
          _ToggleIcon(
            icon: Icons.list_rounded,
            isSelected: viewMode == ViewMode.list,
            onTap: onToggle,
            primary: primary,
            onSurfaceVariant: onSurfaceVariant,
            surfaceHigh: surfaceHigh,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primary;
  final Color onSurfaceVariant;
  final Color surfaceHigh;
  final bool isDark;

  const _ToggleIcon({
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
