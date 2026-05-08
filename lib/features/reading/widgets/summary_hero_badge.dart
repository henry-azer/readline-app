import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_gradients.dart';
import 'package:readline_app/core/theme/app_spacing.dart';

/// Gradient hero badge displayed at the top of the session summary dialog.
class SummaryHeroBadge extends StatelessWidget {
  final bool isDark;
  final Color primary;

  const SummaryHeroBadge({
    super.key,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: 0.08),
        border: Border.all(
          color: primary.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.smd),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.primary(isDark),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.35),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 30,
              color: isDark ? AppColors.onPrimary : AppColors.lightOnPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
