import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/data/contracts/content_generation_service.dart';
import 'package:readline_app/features/home/viewmodels/magic_content_viewmodel.dart';
import 'package:readline_app/features/home/widgets/magic_chip_button.dart';
import 'package:readline_app/features/home/widgets/magic_section_label.dart';
import 'package:readline_app/features/home/widgets/magic_segment_button.dart';
import 'package:readline_app/widgets/readline_button.dart';
import 'package:readline_app/widgets/sheet_handle.dart';

class MagicContentSheet extends StatefulWidget {
  final ValueChanged<GeneratedContent> onGenerated;

  const MagicContentSheet({super.key, required this.onGenerated});

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<GeneratedContent> onGenerated,
  }) {
    final isDark = context.isDark;
    final sheetBg = isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: sheetBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => MagicContentSheet(onGenerated: onGenerated),
    );
  }

  @override
  State<MagicContentSheet> createState() => _MagicContentSheetState();
}

class _MagicContentSheetState extends State<MagicContentSheet> {
  late final MagicContentViewModel _vm;
  final _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = MagicContentViewModel();
    _topicController.addListener(() => _vm.setTopic(_topicController.text));
  }

  @override
  void dispose() {
    _topicController.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    FocusScope.of(context).unfocus();
    final result = await _vm.generate();
    if (!mounted || result == null) return;
    widget.onGenerated(result);
    Navigator.of(context).pop();
  }

  String _errorMessage(ContentGenerationError error) => switch (error) {
    ContentGenerationError.network => AppStrings.magicErrorNetwork.tr,
    ContentGenerationError.timeout => AppStrings.magicErrorTimeout.tr,
    ContentGenerationError.empty => AppStrings.magicErrorEmpty.tr,
    ContentGenerationError.server => AppStrings.magicErrorServer.tr,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final errorColor = isDark ? AppColors.error : AppColors.lightError;

    return SafeArea(
      top: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
          ),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: SheetHandle()),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: primary,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    AppStrings.magicSheetTitle.tr,
                    style: AppTypography.titleMedium.copyWith(color: onSurface),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                AppStrings.magicSheetSubtitle.tr,
                style: AppTypography.bodySmall.copyWith(
                  color: onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              MagicSectionLabel(
                text: AppStrings.magicCategoryLabel.tr,
                color: onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              StreamBuilder<String>(
                stream: _vm.selectedCategory$,
                builder: (context, snap) {
                  final selected = snap.data ?? 'general';
                  return Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: MagicContentViewModel.categories.map((c) {
                      final isSelected = c.id == selected;
                      return MagicChipButton(
                        label: c.labelKey.tr,
                        isSelected: isSelected,
                        onTap: () => _vm.setCategory(c.id),
                        primary: primary,
                        onSurfaceVariant: onSurfaceVariant,
                        isDark: isDark,
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              MagicSectionLabel(
                text: AppStrings.magicLengthLabel.tr,
                color: onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              StreamBuilder<MagicContentLength>(
                stream: _vm.selectedLength$,
                builder: (context, snap) {
                  final selected = snap.data ?? MagicContentLength.medium;
                  return Row(
                    children: [
                      MagicSegmentButton(
                        label: AppStrings.magicLengthShort.tr,
                        isSelected: selected == MagicContentLength.short,
                        onTap: () => _vm.setLength(MagicContentLength.short),
                        primary: primary,
                        onSurface: onSurface,
                        isDark: isDark,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      MagicSegmentButton(
                        label: AppStrings.magicLengthMedium.tr,
                        isSelected: selected == MagicContentLength.medium,
                        onTap: () => _vm.setLength(MagicContentLength.medium),
                        primary: primary,
                        onSurface: onSurface,
                        isDark: isDark,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      MagicSegmentButton(
                        label: AppStrings.magicLengthLong.tr,
                        isSelected: selected == MagicContentLength.long,
                        onTap: () => _vm.setLength(MagicContentLength.long),
                        primary: primary,
                        onSurface: onSurface,
                        isDark: isDark,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              MagicSectionLabel(
                text: AppStrings.magicDifficultyLabel.tr,
                color: onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              StreamBuilder<ContentDifficulty>(
                stream: _vm.selectedDifficulty$,
                builder: (context, snap) {
                  final selected = snap.data ?? ContentDifficulty.intermediate;
                  return Row(
                    children: [
                      MagicSegmentButton(
                        label: AppStrings.magicDifficultyBeginner.tr,
                        isSelected: selected == ContentDifficulty.beginner,
                        onTap: () =>
                            _vm.setDifficulty(ContentDifficulty.beginner),
                        primary: primary,
                        onSurface: onSurface,
                        isDark: isDark,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      MagicSegmentButton(
                        label: AppStrings.magicDifficultyIntermediate.tr,
                        isSelected: selected == ContentDifficulty.intermediate,
                        onTap: () =>
                            _vm.setDifficulty(ContentDifficulty.intermediate),
                        primary: primary,
                        onSurface: onSurface,
                        isDark: isDark,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      MagicSegmentButton(
                        label: AppStrings.magicDifficultyAdvanced.tr,
                        isSelected: selected == ContentDifficulty.advanced,
                        onTap: () =>
                            _vm.setDifficulty(ContentDifficulty.advanced),
                        primary: primary,
                        onSurface: onSurface,
                        isDark: isDark,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              MagicSectionLabel(
                text: AppStrings.magicTopicLabel.tr,
                color: onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _topicController,
                maxLength: 80,
                style: AppTypography.bodyMedium.copyWith(color: onSurface),
                inputFormatters: [LengthLimitingTextInputFormatter(80)],
                decoration: InputDecoration(
                  hintText: AppStrings.magicTopicHint.tr,
                  counterText: '',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceContainerLow
                      : AppColors.lightSurfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.outlineVariant
                          : AppColors.lightOutlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.outlineVariant
                          : AppColors.lightOutlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.mdBorder,
                    borderSide: BorderSide(color: primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              StreamBuilder<ContentGenerationError?>(
                stream: _vm.error$,
                builder: (context, snap) {
                  final error = snap.data;
                  if (error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: errorColor,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            _errorMessage(error),
                            style: AppTypography.bodySmall.copyWith(
                              color: errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              StreamBuilder<bool>(
                stream: _vm.isGenerating$,
                builder: (context, snap) {
                  final isGenerating = snap.data ?? false;
                  return SizedBox(
                    width: double.infinity,
                    child: ReadlineButton(
                      label: isGenerating
                          ? AppStrings.magicGenerating.tr
                          : AppStrings.magicGenerate.tr,
                      icon: isGenerating ? null : Icons.auto_awesome_rounded,
                      onTap: isGenerating ? null : _handleGenerate,
                    ),
                  );
                },
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
