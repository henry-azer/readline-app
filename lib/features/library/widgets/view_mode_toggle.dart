import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/data/enums/view_mode.dart';
import 'package:readline_app/features/library/widgets/view_mode_toggle_icon.dart';

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
          ViewModeToggleIcon(
            icon: Icons.grid_view_rounded,
            isSelected: viewMode == ViewMode.grid,
            onTap: onToggle,
            primary: primary,
            onSurfaceVariant: onSurfaceVariant,
            surfaceHigh: surfaceHigh,
            isDark: isDark,
          ),
          ViewModeToggleIcon(
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
