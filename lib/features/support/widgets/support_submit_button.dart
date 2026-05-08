import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class SupportSubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const SupportSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accent = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onAccent = isDark ? AppColors.onPrimary : AppColors.lightOnPrimary;

    return GestureDetector(
      onTap: isSubmitting ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.msl),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent,
          borderRadius: AppRadius.lgBorder,
        ),
        child: isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(onAccent),
                ),
              )
            : Text(
                AppStrings.supportSubmit.tr,
                style: AppTypography.button.copyWith(color: onAccent),
              ),
      ),
    );
  }
}
