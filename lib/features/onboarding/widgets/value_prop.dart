import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class ValueProp extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color onSurfaceVariant;

  const ValueProp({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: onSurfaceVariant),
        ),
      ],
    );
  }
}
