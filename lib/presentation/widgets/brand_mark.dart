import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/theme/app_tracking.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/core/theme/app_colors.dart';

/// Branded "READ-IT" text mark for AppBar leading position.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Text(
        'READ-IT',
        style: AppTypography.label.copyWith(
          letterSpacing: AppTracking.editorial,
          color: primary,
        ),
      ),
    );
  }
}
