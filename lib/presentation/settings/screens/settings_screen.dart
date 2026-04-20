import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/data/models/user_preferences_model.dart';
import 'package:read_it/presentation/settings/viewmodels/settings_viewmodel.dart';
import 'package:read_it/presentation/settings/widgets/advanced_section.dart';
import 'package:read_it/presentation/settings/widgets/appearance_section.dart';
import 'package:read_it/presentation/settings/widgets/live_preview.dart';
import 'package:read_it/presentation/settings/widgets/reading_settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _viewModel;
  bool _wasSaving = false;
  StreamSubscription<bool>? _savingSub;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel();
    _viewModel.init();
    _savingSub = _viewModel.isSaving$.listen((saving) {
      if (_wasSaving && !saving && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.settingsSaved.tr),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      _wasSaving = saving;
    });
  }

  @override
  void dispose() {
    _savingSub?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.settingsTitle.tr,
          style: AppTypography.titleLarge.copyWith(color: onSurface),
        ),
        centerTitle: false,
        actions: [
          // Saving indicator
          StreamBuilder<bool>(
            stream: _viewModel.isSaving$,
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
                            color: onSurfaceVariant,
                          ),
                        ),
                      )
                    : IconButton(
                        key: const ValueKey('gear'),
                        icon: Icon(
                          Icons.settings_outlined,
                          color: onSurfaceVariant,
                        ),
                        onPressed: null,
                      ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<UserPreferencesModel>(
        stream: _viewModel.preferences$,
        builder: (context, snap) {
          final prefs = snap.data ?? const UserPreferencesModel();
          return _SettingsBody(viewModel: _viewModel, prefs: prefs);
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _SettingsBody extends StatelessWidget {
  final SettingsViewModel viewModel;
  final UserPreferencesModel prefs;

  const _SettingsBody({required this.viewModel, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    const hPad = AppSpacing.xl;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Reading Settings ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              hPad,
              AppSpacing.xs,
              hPad,
              AppSpacing.sm,
            ),
            child: _SectionHeader(
              icon: Icons.menu_book_outlined,
              title: AppStrings.settingsSectionReading.tr,
              onSurface: onSurface,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.xl),
            child: ReadingSettingsSection(viewModel: viewModel, prefs: prefs),
          ),
        ),

        // ── Appearance ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.sm),
            child: _SectionHeader(
              icon: Icons.palette_outlined,
              title: AppStrings.settingsSectionAppearance.tr,
              onSurface: onSurface,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.xl),
            child: AppearanceSection(viewModel: viewModel, prefs: prefs),
          ),
        ),

        // ── Advanced ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.sm),
            child: _SectionHeader(
              icon: Icons.tune_rounded,
              title: AppStrings.settingsSectionAdvanced.tr,
              onSurface: onSurface,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.xl),
            child: AdvancedSection(viewModel: viewModel, prefs: prefs),
          ),
        ),

        // ── Live Preview ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.sm),
            child: _SectionHeader(
              icon: Icons.visibility_outlined,
              title: AppStrings.settingsSectionLivePreview.tr,
              onSurface: onSurface,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              hPad,
              0,
              hPad,
              AppSpacing.xxxxl + AppSpacing.xxl,
            ),
            child: LivePreview(prefs: prefs),
          ),
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color onSurface;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: onSurface, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: AppTypography.sectionHeader.copyWith(
            color: onSurface,
          ),
        ),
      ],
    );
  }
}
