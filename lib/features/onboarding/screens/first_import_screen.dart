import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_gradients.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/onboarding/widgets/format_badge.dart';
import 'package:readline_app/widgets/readline_button.dart';
import 'package:readline_app/widgets/tap_scale.dart';

class FirstImportScreen extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onChooseFromFiles;
  final VoidCallback onSampleText;
  final VoidCallback onSkip;

  const FirstImportScreen({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.onChooseFromFiles,
    required this.onSampleText,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primaryContainer = isDark
        ? AppColors.primaryContainer
        : AppColors.lightPrimaryContainer;
    final badgeOnColor = isDark ? AppColors.onPrimary : AppColors.white;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            const Spacer(flex: 2),

            Center(
              child: SizedBox(
                height: 180,
                width: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryContainer.withValues(alpha: 0.15),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryContainer.withValues(alpha: 0.25),
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppGradients.primary(isDark).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: const Icon(Icons.auto_stories_rounded, size: 48),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.md,
                      child: FormatBadge(
                        label: AppStrings.onboardingFormatPdf.tr,
                        color: primary,
                        onColor: badgeOnColor,
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.md,
                      left: 0,
                      child: FormatBadge(
                        label: AppStrings.onboardingFormatTxt.tr,
                        color: primary.withValues(alpha: 0.7),
                        onColor: badgeOnColor,
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: FormatBadge(
                        label: AppStrings.onboardingFormatDocx.tr,
                        color: primary.withValues(alpha: 0.5),
                        onColor: badgeOnColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text(
              AppStrings.onboardingImportHeadline.tr,
              textAlign: TextAlign.center,
              style: AppTypography.displayMedium.copyWith(color: onSurface),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              AppStrings.onboardingImportSubtitle.tr,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(color: onSurfaceVariant),
            ),
            const Spacer(flex: 2),

            if (errorMessage != null) ...[
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.error : AppColors.lightError,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ReadlineButton(
                    label: AppStrings.onboardingChooseFromFiles.tr,
                    icon: Icons.upload_file_rounded,
                    onTap: onChooseFromFiles,
                  ),
            const SizedBox(height: AppSpacing.sm),

            ReadlineButton(
              label: AppStrings.onboardingTrySampleText.tr,
              isSecondary: true,
              onTap: isLoading ? null : onSampleText,
            ),
            const SizedBox(height: AppSpacing.lg),

            Center(
              child: TapScale(
                onTap: isLoading ? null : onSkip,
                child: Text(
                  AppStrings.onboardingSkipForNow.tr,
                  style: AppTypography.label.copyWith(color: onSurfaceVariant),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
