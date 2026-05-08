import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class SocialChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SocialChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accent = isDark ? AppColors.primary : AppColors.lightPrimary;
    final fill = accent.withValues(alpha: 0.08);
    final borderColor = accent.withValues(alpha: 0.20);

    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.msl,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: AppSpacing.sxs),
            Text(
              label,
              style: AppTypography.socialChipLabel.copyWith(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
