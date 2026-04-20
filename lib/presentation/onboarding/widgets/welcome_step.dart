import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_gradients.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/widgets/read_it_button.dart';
import 'package:read_it/presentation/widgets/tap_scale.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onBegin;

  const WelcomeStep({super.key, required this.onBegin});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xxl),

            // Skip to app link
            Align(
              alignment: Alignment.topRight,
              child: TapScale(
                onTap: onBegin,
                child: Text(
                  AppStrings.onboardingSkip.tr,
                  style: AppTypography.label.copyWith(color: onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Streak preview badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: AppGradients.streakLight,
                  borderRadius: AppRadius.fullBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: AppColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      AppStrings.onboardingStreakBadge.tr,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                AppStrings.onboardingMindfulJourney.tr,
                style: AppTypography.label.copyWith(color: onSurfaceVariant),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Headline
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTypography.displayLarge.copyWith(
                  color: onSurface,
                  fontSize: 38,
                  height: 1.15,
                ),
                children: [
                  TextSpan(text: AppStrings.onboardingHeadlinePace.tr),
                  TextSpan(
                    text: AppStrings.onboardingHeadlinePaceItalic.tr,
                    style: AppTypography.displayLarge.copyWith(
                      color: onSurface,
                      fontSize: 38,
                      fontStyle: FontStyle.italic,
                      height: 1.15,
                    ),
                  ),
                  TextSpan(text: AppStrings.onboardingHeadlineSpeed.tr),
                  TextSpan(
                    text: AppStrings.onboardingHeadlineSpeedItalic.tr,
                    style: AppTypography.displayLarge.copyWith(
                      color: onSurface,
                      fontSize: 38,
                      fontStyle: FontStyle.italic,
                      height: 1.15,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Subtitle
            Text(
              AppStrings.onboardingSubtitle.tr,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // GET STARTED CTA
            ReadItButton(
              label: AppStrings.onboardingGetStarted.tr,
              onTap: onBegin,
            ),
            const SizedBox(height: AppSpacing.md),

            // Social proof
            Center(
              child: Text(
                AppStrings.onboardingSocialProof.tr,
                style: AppTypography.bodySmall.copyWith(
                  color: onSurfaceVariant,
                ),
              ),
            ),

            const Spacer(),

            // Bottom value props
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ValueProp(
                    icon: Icons.do_not_disturb_on_outlined,
                    label: AppStrings.onboardingValueDistraction.tr,
                    color: primary,
                    onSurfaceVariant: onSurfaceVariant,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color:
                        (isDark
                                ? AppColors.outlineVariant
                                : AppColors.lightOutlineVariant)
                            .withValues(alpha: 0.4),
                  ),
                  _ValueProp(
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

class _ValueProp extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color onSurfaceVariant;

  const _ValueProp({
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
