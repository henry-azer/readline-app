import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/onboarding/widgets/value_prop.dart';
import 'package:readline_app/widgets/readline_button.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onBegin;

  const WelcomeScreen({super.key, required this.onBegin});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final dividerColor =
        (isDark ? AppColors.outlineVariant : AppColors.lightOutlineVariant)
            .withValues(alpha: 0.4);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            Center(
              child: Text(
                AppStrings.onboardingMindfulJourney.tr,
                style: AppTypography.label.copyWith(color: onSurfaceVariant),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxxl),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTypography.onboardingHeadline.copyWith(
                  color: onSurface,
                ),
                children: [
                  TextSpan(text: AppStrings.onboardingHeadlinePace.tr),
                  TextSpan(
                    text: AppStrings.onboardingHeadlinePaceItalic.tr,
                    style: AppTypography.onboardingHeadlineItalic.copyWith(
                      color: onSurface,
                    ),
                  ),
                  TextSpan(text: AppStrings.onboardingHeadlineSpeed.tr),
                  TextSpan(
                    text: AppStrings.onboardingHeadlineSpeedItalic.tr,
                    style: AppTypography.onboardingHeadlineItalic.copyWith(
                      color: onSurface,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xxxxl + AppSpacing.md),

            Text(
              AppStrings.onboardingSubtitle.tr,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(color: onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            ReadlineButton(
              label: AppStrings.onboardingGetStarted.tr,
              onTap: onBegin,
            ),
            const SizedBox(height: AppSpacing.md),

            Center(
              child: Text(
                AppStrings.onboardingSocialProof.tr,
                style: AppTypography.bodySmall.copyWith(
                  color: onSurfaceVariant,
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ValueProp(
                    icon: Icons.do_not_disturb_on_outlined,
                    label: AppStrings.onboardingValueDistraction.tr,
                    color: primary,
                    onSurfaceVariant: onSurfaceVariant,
                  ),
                  Container(width: 1, height: 32, color: dividerColor),
                  ValueProp(
                    icon: Icons.psychology_outlined,
                    label: AppStrings.onboardingValueIntellect.tr,
                    color: primary,
                    onSurfaceVariant: onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
