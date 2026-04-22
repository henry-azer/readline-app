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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            const Spacer(flex: 2),

            // Hero illustration
            Center(
              child: SizedBox(
                height: 180,
                width: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryContainer.withValues(alpha: 0.15),
                      ),
                    ),
                    // Inner ring
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryContainer.withValues(alpha: 0.25),
                      ),
                    ),
                    // Center icon
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppGradients.primary(isDark).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        size: 48,
                      ),
                    ),
                    // PDF badge
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.md,
                      child: _FormatBadge(
                        label: AppStrings.onboardingFormatPdf.tr,
                        color: primary,
                        onColor: isDark
                            ? AppColors.onPrimary
                            : AppColors.white,
                      ),
                    ),
                    // TXT badge
                    Positioned(
                      bottom: AppSpacing.md,
                      left: 0,
                      child: _FormatBadge(
                        label: AppStrings.onboardingFormatTxt.tr,
                        color: primary.withValues(alpha: 0.7),
                        onColor: isDark
                            ? AppColors.onPrimary
                            : AppColors.white,
                      ),
                    ),
                    // EPUB badge
                    Positioned(
                      bottom: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: _FormatBadge(
                        label: AppStrings.onboardingFormatEpub.tr,
                        color: primary.withValues(alpha: 0.5),
                        onColor: isDark
                            ? AppColors.onPrimary
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Headline
            Text(
              AppStrings.onboardingImportHeadline.tr,
              textAlign: TextAlign.center,
              style: AppTypography.displayMedium.copyWith(
                color: onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Subtitle
            Text(
              AppStrings.onboardingImportSubtitle.tr,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const Spacer(flex: 2),

            // Error message
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

            // IMPORT TEXT primary CTA
            isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ReadItButton(
                    label: AppStrings.onboardingChooseFromFiles.tr,
                    icon: Icons.upload_file_rounded,
                    onTap: onChooseFromFiles,
                  ),
            const SizedBox(height: AppSpacing.sm),

            // TRY SAMPLE TEXT secondary
            ReadItButton(
              label: AppStrings.onboardingTrySampleText.tr,
              isSecondary: true,
              onTap: isLoading ? null : onSampleText,
            ),
            const SizedBox(height: AppSpacing.lg),

            // SKIP FOR NOW text link
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

class _FormatBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color onColor;

  const _FormatBadge({
    required this.label,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.smBorder,
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: onColor,
          fontSize: 10,
        ),
      ),
    );
  }
}
