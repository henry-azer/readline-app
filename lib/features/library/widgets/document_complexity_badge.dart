import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Tiny pill badge showing a document's reading complexity level.
class DocumentComplexityBadge extends StatelessWidget {
  final String level;

  const DocumentComplexityBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final color = _color(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullBorder,
      ),
      child: Text(
        level.toUpperCase(),
        style: AppTypography.labelMicro.copyWith(color: color),
      ),
    );
  }

  static Color _color(String level) {
    switch (level) {
      case 'beginner':
        return AppColors.complexityBeginner;
      case 'intermediate':
        return AppColors.complexityIntermediate;
      case 'advanced':
        return AppColors.complexityAdvanced;
      case 'expert':
        return AppColors.complexityExpert;
      default:
        return AppColors.onSurfaceVariant;
    }
  }
}
