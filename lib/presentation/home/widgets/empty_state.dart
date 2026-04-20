import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/home/widgets/reading_tip_card.dart';
import 'package:read_it/presentation/widgets/read_it_button.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onImportPdf;

  const EmptyState({super.key, required this.onImportPdf});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxxl),

        // Hero illustration
        _HeroIllustration(isDark: isDark),

        const SizedBox(height: AppSpacing.xxl),

        // Headline
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            AppStrings.homeEmptyHeadline.tr,
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium.copyWith(color: onSurface),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Text(
            AppStrings.homeEmptyBody.tr,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(color: onSurfaceVariant),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // CTA button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: ReadItButton(
            label: AppStrings.homeImportPdf.tr,
            icon: Icons.upload_file_rounded,
            onTap: onImportPdf,
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Reading tip
        const ReadingTipCard(tipIndex: 0),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  final bool isDark;

  const _HeroIllustration({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainer;
    final iconColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Container(
      width: 180,
      height: 160,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.lgBorder,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorative circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color:
                  (isDark
                          ? AppColors.primaryContainer
                          : AppColors.lightPrimaryContainer)
                      .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
          ),
          Icon(
            Icons.laptop_mac_rounded,
            size: 72,
            color: iconColor.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
