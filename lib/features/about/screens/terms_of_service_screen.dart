import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/support/widgets/support_header.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final mutedColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: SupportHeader(title: AppStrings.aboutTermsOfService.tr),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Text(
          AppStrings.aboutTermsOfServiceContent.tr,
          style: AppTypography.legalBody.copyWith(color: mutedColor),
        ),
      ),
    );
  }
}
