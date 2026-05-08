import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Single stat card in the session summary dialog (icon + value + label).
class SummaryStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outlineVariant;
  final Color primary;

  const SummaryStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outlineVariant,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: 16, color: primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTypography.summaryStatValue.copyWith(color: onSurface),
            ),
          ),
          const SizedBox(height: AppSpacing.micro),
          Text(
            label,
            style: AppTypography.summaryStatLabel.copyWith(
              color: onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
