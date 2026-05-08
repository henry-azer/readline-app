import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatChip({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.smBorder,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.homeStatNumber.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.micro),
            Text(
              label,
              style: AppTypography.homeMicroLabelTiny.copyWith(
                color: color.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
