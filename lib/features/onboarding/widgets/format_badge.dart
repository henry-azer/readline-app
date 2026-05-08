import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class FormatBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color onColor;

  const FormatBadge({
    super.key,
    required this.label,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.smBorder),
      child: Text(
        label,
        style: AppTypography.onboardingFormatBadge.copyWith(color: onColor),
      ),
    );
  }
}
