import 'dart:async';

import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_breakpoints.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/settings/viewmodels/magic_content_settings_viewmodel.dart';
import 'package:readline_app/features/settings/widgets/magic_content_key_card.dart';
import 'package:readline_app/widgets/app_snackbar.dart';

class MagicContentSettingsScreen extends StatefulWidget {
  const MagicContentSettingsScreen({super.key});

  @override
  State<MagicContentSettingsScreen> createState() =>
      _MagicContentSettingsScreenState();
}

class _MagicContentSettingsScreenState
    extends State<MagicContentSettingsScreen> {
  late final MagicContentSettingsViewModel _vm;
  final _keyController = TextEditingController();
  bool _obscured = true;
  StreamSubscription<MagicContentSettingsStatus>? _statusSub;

  @override
  void initState() {
    super.initState();
    _vm = MagicContentSettingsViewModel();
    _vm.init();
    _statusSub = _vm.status$.listen(_handleStatus);
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _keyController.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _handleStatus(MagicContentSettingsStatus status) {
    if (!mounted) return;
    final message = _statusMessage(status);
    switch (status) {
      case MagicContentSettingsStatus.connectionSuccessful:
      case MagicContentSettingsStatus.keySaved:
        AppSnackbar.success(context, message);
      case MagicContentSettingsStatus.invalidKey:
      case MagicContentSettingsStatus.serviceUnreachable:
        AppSnackbar.error(context, message);
    }
  }

  String _statusMessage(MagicContentSettingsStatus status) => switch (status) {
    MagicContentSettingsStatus.connectionSuccessful =>
      AppStrings.magicSettingsStatusValid.tr,
    MagicContentSettingsStatus.invalidKey =>
      AppStrings.magicSettingsStatusInvalid.tr,
    MagicContentSettingsStatus.serviceUnreachable =>
      AppStrings.magicSettingsStatusUnreachable.tr,
    MagicContentSettingsStatus.keySaved =>
      AppStrings.magicSettingsStatusSaved.tr,
  };

  Future<void> _handleClear() async {
    final previous = await _vm.clearKey();
    if (!mounted) return;
    _keyController.clear();
    if (previous == null) return;
    AppSnackbar.info(
      context,
      AppStrings.magicSettingsStatusCleared.tr,
      actionLabel: AppStrings.undo.tr,
      onAction: () {
        _vm.restoreKey(previous);
        _keyController.text = previous;
      },
    );
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
        titleSpacing: AppSpacing.md,
        title: Text(
          AppStrings.magicSettingsTitle.tr,
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.onSurface : AppColors.lightOnSurface,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.maxContentWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            children: [
              const SizedBox(height: AppSpacing.md),

              StreamBuilder<bool>(
                stream: _vm.hasKey$,
                builder: (context, hasKeySnap) {
                  final hasKey = hasKeySnap.data ?? false;
                  return StreamBuilder<bool>(
                    stream: _vm.isWorking$,
                    builder: (context, busySnap) {
                      final isBusy = busySnap.data ?? false;
                      return MagicContentKeyCard(
                        controller: _keyController,
                        obscured: _obscured,
                        onToggleObscured: () =>
                            setState(() => _obscured = !_obscured),
                        enabled: true,
                        onChanged: (_) {},
                        onTest: () => _vm.testConnection(_keyController.text),
                        onSave: () => _vm.saveKey(_keyController.text),
                        isBusy: isBusy,
                        onClear: hasKey ? _handleClear : null,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                AppStrings.magicSettingsDisclaimer.tr,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: mutedColor),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
