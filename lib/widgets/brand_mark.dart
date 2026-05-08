import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_gradients.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Branded icon + "Readline" text mark for AppBar title.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppGradients.primary(isDark).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: const Icon(Icons.auto_stories_rounded, size: 24),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          AppStrings.generalAppName.tr,
          style: AppTypography.brandMark.copyWith(color: primaryColor),
        ),
      ],
    );
  }
}
