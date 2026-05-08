import 'dart:async';

import 'package:flutter/material.dart';
import 'package:readline_app/core/constants/personal_links.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_gradients.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/about/viewmodels/about_viewmodel.dart';
import 'package:readline_app/features/about/widgets/feature_card.dart';
import 'package:readline_app/features/about/widgets/social_chip.dart';
import 'package:readline_app/features/settings/widgets/section_label.dart';
import 'package:readline_app/features/support/widgets/support_header.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final AboutViewModel _vm;
  StreamSubscription<bool>? _urlFailSub;

  @override
  void initState() {
    super.initState();
    _vm = AboutViewModel();
    _urlFailSub = _vm.urlLaunchFailed$.listen((failed) {
      if (failed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.aboutErrorLaunchingUrl.tr)),
        );
      }
    });
  }

  @override
  void dispose() {
    _urlFailSub?.cancel();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final mutedColor = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final cardColor = isDark
        ? AppColors.surfaceContainer
        : AppColors.lightSurfaceContainerLowest;
    final border =
        (isDark ? AppColors.outlineVariant : AppColors.lightOutlineVariant)
            .withValues(alpha: 0.4);
    final textColor = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    // Wordmark color — same primary used by the AppBar BrandMark and the
    // splash hero so the "Readline" lettering matches across screens.
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: SupportHeader(title: AppStrings.aboutTitle.tr),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            // Same primary-gradient brand icon used by the AppBar BrandMark
            // and the splash hero — paints the icon glyph via ShaderMask so
            // the wordmark identity stays consistent across screens.
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppGradients.primary(isDark).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: const Icon(Icons.auto_stories_rounded, size: 48),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.aboutAppName.tr,
              style: AppTypography.aboutAppName.copyWith(color: primary),
            ),
            const SizedBox(height: AppSpacing.sxs),
            StreamBuilder<String>(
              stream: _vm.version$,
              builder: (context, vSnap) => Text(
                '${AppStrings.aboutVersion.tr} ${vSnap.data ?? '...'}',
                style: AppTypography.bodySmall.copyWith(color: mutedColor),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.aboutAppDescription.tr,
              style: AppTypography.bodyMedium.copyWith(
                color: mutedColor,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x2l),

            // ── Key Features ──────────────────────────────────────────
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SectionLabel(text: AppStrings.aboutKeyFeatures.tr),
            ),
            const SizedBox(height: AppSpacing.sm),
            FeatureCard(
              icon: Icons.menu_book_rounded,
              title: AppStrings.aboutFeatureFocusedTitle.tr,
              description: AppStrings.aboutFeatureFocusedDescription.tr,
            ),
            const SizedBox(height: AppSpacing.smd),
            FeatureCard(
              icon: Icons.translate_rounded,
              title: AppStrings.aboutFeatureVocabTitle.tr,
              description: AppStrings.aboutFeatureVocabDescription.tr,
            ),
            const SizedBox(height: AppSpacing.smd),
            FeatureCard(
              icon: Icons.shield_outlined,
              title: AppStrings.aboutFeaturePrivacyTitle.tr,
              description: AppStrings.aboutFeaturePrivacyDescription.tr,
            ),

            const SizedBox(height: AppSpacing.x2l),

            // ── Developer ──────────────────────────────────────────────
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SectionLabel(text: AppStrings.aboutDeveloperInfo.tr),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: AppRadius.lgBorder,
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  Text(
                    AppStrings.aboutDevelopedBy.tr,
                    style: AppTypography.bodySmall.copyWith(color: mutedColor),
                  ),
                  const SizedBox(height: AppSpacing.sxs),
                  Text(
                    PersonalLinks.developerName,
                    style: AppTypography.aboutDeveloperName.copyWith(
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.smd,
                    runSpacing: AppSpacing.smd,
                    alignment: WrapAlignment.center,
                    children: [
                      SocialChip(
                        icon: Icons.link_rounded,
                        label: AppStrings.aboutLinkedin.tr,
                        onTap: () => _vm.launchExternalUrl(
                          PersonalLinks.getByName('linkedin')!,
                        ),
                      ),
                      SocialChip(
                        icon: Icons.code_rounded,
                        label: AppStrings.aboutGithub.tr,
                        onTap: () => _vm.launchExternalUrl(
                          PersonalLinks.getByName('gitHub')!,
                        ),
                      ),
                      SocialChip(
                        icon: Icons.email_outlined,
                        label: AppStrings.aboutEmail.tr,
                        onTap: () => _vm.launchExternalUrl(
                          PersonalLinks.getByName('mail')!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              AppStrings.aboutCopyright.tr,
              style: AppTypography.aboutCopyright.copyWith(color: mutedColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
