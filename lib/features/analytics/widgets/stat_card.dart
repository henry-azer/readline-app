import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String label;
  final int targetValue;
  final String formattedValue;
  final String? sublabel;
  final bool isDark;

  const StatCard({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.label,
    required this.targetValue,
    required this.formattedValue,
    this.sublabel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? AppColors.surfaceContainer
        : AppColors.lightSurfaceContainerLowest;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.lgBorder,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Accent icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: AppRadius.smBorder,
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),

          // Animated count-up value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: targetValue),
                duration: AppDurations.reveal,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Text(
                    _formatAnimatedValue(value),
                    style: AppTypography.analyticsStatNumber.copyWith(
                      color: onSurface,
                    ),
                  );
                },
              ),
              if (sublabel != null) ...[
                const SizedBox(width: AppSpacing.micro),
                Text(
                  sublabel!,
                  style: AppTypography.analyticsStatUnit.copyWith(
                    color: onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),

          // Label
          Text(
            label.toUpperCase(),
            style: AppTypography.analyticsStatLabel.copyWith(
              color: onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// During animation, format the interpolated int the same way as the final value.
  /// We use the same formatting logic that produced [formattedValue] for the target.
  String _formatAnimatedValue(int value) {
    // If targetValue is 0, just show "0" or the formatted zero.
    if (targetValue == 0) return formattedValue;

    // Scale the formatted value proportionally
    // For simple int values, just return the int
    if (formattedValue == '$targetValue') return '$value';

    // For percentage values like "85%"
    if (formattedValue.endsWith('%')) return '$value%';

    // For formatted values with k/M suffix or decimal
    if (formattedValue.contains('k') || formattedValue.contains('M')) {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      }
      if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}k';
      }
      return '$value';
    }

    // For hour values like "1.5" or "23m"
    if (formattedValue.endsWith('m')) {
      return '${value}m';
    }
    if (formattedValue.contains('.')) {
      // Decimal hours
      final ratio = targetValue > 0 ? value / targetValue : 0.0;
      final targetDouble = double.tryParse(
        formattedValue.replaceAll(RegExp(r'[^0-9.]'), ''),
      );
      if (targetDouble != null) {
        return (targetDouble * ratio).toStringAsFixed(1);
      }
    }

    return '$value';
  }
}
