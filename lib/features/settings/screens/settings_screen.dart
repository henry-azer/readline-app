import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/router/app_router.dart';
import 'package:readline_app/core/theme/app_breakpoints.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:readline_app/features/settings/widgets/language_picker_sheet.dart';
import 'package:readline_app/features/settings/widgets/section_label.dart';
import 'package:readline_app/features/settings/widgets/settings_divider.dart';
import 'package:readline_app/features/settings/widgets/settings_row_chevron.dart';
import 'package:readline_app/features/settings/widgets/settings_row_toggle.dart';
import 'package:readline_app/features/settings/widgets/settings_section_card.dart';
import 'package:readline_app/features/settings/widgets/theme_picker_sheet.dart';
import 'package:readline_app/widgets/brand_mark.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = SettingsViewModel();
    _vm.init();
  }

  @override
  void dispose() {
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.xl,
        title: const BrandMark(),
        centerTitle: false,
        actions: [
          StreamBuilder<bool>(
            stream: _vm.isSaving$,
            builder: (context, snap) {
              final saving = snap.data == true;
              return AnimatedSwitcher(
                duration: AppDurations.normal,
                child: saving
                    ? Padding(
                        key: const ValueKey('saving'),
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: mutedColor,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('idle')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.maxContentWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            children: [
              const SizedBox(height: AppSpacing.xxs),

              // ── INSIGHTS ────────────────────────────────────────────────
              SectionLabel(text: AppStrings.settingsSectionInsights.tr),
              const SizedBox(height: AppSpacing.smd),
              SettingsSectionCard(
                children: [
                  SettingsRowChevron(
                    icon: Icons.insights_rounded,
                    label: AppStrings.settingsAnalyticsTitle.tr,
                    subtitle: AppStrings.settingsAnalyticsSubtitle.tr,
                    onTap: () => context.push(AppRoutes.analytics),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── AI ──────────────────────────────────────────────────────
              SectionLabel(text: AppStrings.settingsSectionAi.tr),
              const SizedBox(height: AppSpacing.smd),
              SettingsSectionCard(
                children: [
                  StreamBuilder<bool>(
                    stream: _vm.magicEnabled$,
                    builder: (context, enabledSnap) {
                      final enabled = enabledSnap.data ?? false;
                      return Column(
                        children: [
                          SettingsRowToggle(
                            icon: Icons.auto_awesome_outlined,
                            label: AppStrings.magicSettingsRowLabel.tr,
                            value: enabled,
                            onChanged: _vm.saveMagicEnabled,
                          ),
                          if (enabled) ...[
                            const SettingsDivider(),
                            StreamBuilder<bool>(
                              stream: _vm.magicHasKey$,
                              builder: (context, hasKeySnap) {
                                final hasKey = hasKeySnap.data ?? false;
                                final subtitle = hasKey
                                    ? AppStrings
                                          .magicSettingsSubRowSubtitleSet.tr
                                    : AppStrings
                                          .magicSettingsSubRowSubtitleEmpty.tr;
                                return SettingsRowChevron(
                                  icon: Icons.vpn_key_outlined,
                                  label:
                                      AppStrings.magicSettingsSubRowLabel.tr,
                                  subtitle: subtitle,
                                  onTap: () => context.push(
                                    AppRoutes.magicContentSettings,
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── EXPERIENCE ──────────────────────────────────────────────
              SectionLabel(text: AppStrings.settingsExperience.tr),
              const SizedBox(height: AppSpacing.smd),
              SettingsSectionCard(
                children: [
                  StreamBuilder<bool>(
                    stream: _vm.hapticEnabled$,
                    builder: (context, snap) => SettingsRowToggle(
                      icon: Icons.vibration_rounded,
                      label: AppStrings.settingsHapticFeedback.tr,
                      value: snap.data ?? true,
                      onChanged: _vm.saveHapticEnabled,
                    ),
                  ),
                  const SettingsDivider(),
                  StreamBuilder<String?>(
                    stream: _vm.selectedLocale$,
                    builder: (context, snap) {
                      final code = snap.data;
                      final subtitle = code == null
                          ? AppStrings.settingsSystemDefault.tr
                          : _vm.labelForLocale(code);
                      return SettingsRowChevron(
                        icon: Icons.language_outlined,
                        label: AppStrings.settingsLanguage.tr,
                        subtitle: subtitle,
                        onTap: () => LanguagePickerSheet.show(context, _vm),
                      );
                    },
                  ),
                  const SettingsDivider(),
                  StreamBuilder<String>(
                    stream: _vm.themeMode$,
                    builder: (context, snap) {
                      final mode = snap.data ?? 'system';
                      final subtitle = mode == 'dark'
                          ? AppStrings.settingsThemeDark.tr
                          : mode == 'light'
                          ? AppStrings.settingsThemeLight.tr
                          : AppStrings.settingsThemeSystem.tr;
                      return SettingsRowChevron(
                        icon: Icons.dark_mode_outlined,
                        label: AppStrings.settingsTheme.tr,
                        subtitle: subtitle,
                        onTap: () => ThemePickerSheet.show(context, _vm),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── SUPPORT & INFORMATION ───────────────────────────────────
              SectionLabel(text: AppStrings.supportInformation.tr),
              const SizedBox(height: AppSpacing.smd),
              SettingsSectionCard(
                children: [
                  SettingsRowChevron(
                    icon: Icons.help_outline_rounded,
                    label: AppStrings.supportHelpSupport.tr,
                    subtitle: AppStrings.supportHelpSupportDescription.tr,
                    onTap: () => context.push(AppRoutes.helpSupport),
                  ),
                  const SettingsDivider(),
                  SettingsRowChevron(
                    icon: Icons.bug_report_outlined,
                    label: AppStrings.supportBugReport.tr,
                    subtitle: AppStrings.supportBugReportDescription.tr,
                    onTap: () => context.push(AppRoutes.bugReport),
                  ),
                  const SettingsDivider(),
                  SettingsRowChevron(
                    icon: Icons.star_outline_rounded,
                    label: AppStrings.supportRateApp.tr,
                    subtitle: AppStrings.supportRateAppDescription.tr,
                    onTap: () => context.push(AppRoutes.rateApp),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── LEGAL ────────────────────────────────────────────────────
              SectionLabel(text: AppStrings.aboutLegal.tr),
              const SizedBox(height: AppSpacing.smd),
              SettingsSectionCard(
                children: [
                  SettingsRowChevron(
                    icon: Icons.privacy_tip_outlined,
                    label: AppStrings.aboutPrivacyPolicy.tr,
                    onTap: () => context.push(AppRoutes.privacyPolicy),
                  ),
                  const SettingsDivider(),
                  SettingsRowChevron(
                    icon: Icons.description_outlined,
                    label: AppStrings.aboutTermsOfService.tr,
                    onTap: () => context.push(AppRoutes.termsOfService),
                  ),
                  const SettingsDivider(),
                  SettingsRowChevron(
                    icon: Icons.info_outline_rounded,
                    label: AppStrings.aboutTitle.tr,
                    onTap: () => context.push(AppRoutes.about),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Version footer ──────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    StreamBuilder<String>(
                      stream: _vm.version$,
                      builder: (context, vSnap) => Text(
                        AppStrings.settingsVersionLabel.trParams({
                          'name': AppStrings.aboutAppName.tr,
                          'version': vSnap.data ?? '',
                        }),
                        style: AppTypography.settingsEyebrow.copyWith(
                          color: mutedColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      AppStrings.footerMadeForReaders.tr,
                      textAlign: TextAlign.center,
                      style: AppTypography.label.copyWith(
                        color: mutedColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: AppSpacing.bottomNavClearance + AppSpacing.xxl,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
