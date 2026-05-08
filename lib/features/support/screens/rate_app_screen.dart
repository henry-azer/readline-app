import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/support/viewmodels/rate_app_viewmodel.dart';
import 'package:readline_app/features/support/widgets/support_form_field.dart';
import 'package:readline_app/features/support/widgets/support_header.dart';
import 'package:readline_app/features/support/widgets/support_submit_button.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  late final RateAppViewModel _vm;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = RateAppViewModel();
  }

  @override
  void dispose() {
    _vm.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final outcome = await _vm.submit(
      name: _nameController.text,
      description: _descriptionController.text,
    );

    if (!mounted) return;

    final messageKey = switch (outcome) {
      RateSubmitOutcome.success => AppStrings.supportThankYouFeedback,
      RateSubmitOutcome.missingRating => AppStrings.supportSelectRating,
      RateSubmitOutcome.alreadySubmitting => AppStrings.supportSubmitError,
      RateSubmitOutcome.networkError => AppStrings.supportSubmitError,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageKey.tr)),
    );

    if (outcome == RateSubmitOutcome.success) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).maybePop();
    }
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
    final accent = isDark ? AppColors.primary : AppColors.lightPrimary;
    final dim = isDark
        ? AppColors.outlineVariant
        : AppColors.lightOutlineVariant;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: SupportHeader(title: AppStrings.supportRateApp.tr),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.supportRateAppSubtitle.tr,
                style: AppTypography.bodyMedium.copyWith(
                  color: mutedColor,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SupportFormField(
                controller: _nameController,
                label: AppStrings.supportYourName.tr,
                hint: AppStrings.supportEnterYourName.tr,
                icon: Icons.person_outline_rounded,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? AppStrings.supportNameRequired.tr
                    : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                AppStrings.supportRatingLabel.tr.toUpperCase(),
                style: AppTypography.label.copyWith(color: mutedColor),
              ),
              const SizedBox(height: AppSpacing.sm),
              StreamBuilder<int>(
                stream: _vm.rating$,
                builder: (context, ratingSnap) {
                  final rating = ratingSnap.data ?? 0;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: AppRadius.lgBorder,
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.supportHowWouldYouRate.tr,
                          style: AppTypography.bodySmall.copyWith(
                            color: mutedColor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final star = index + 1;
                            return GestureDetector(
                              onTap: () => _vm.setRating(star),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sxs,
                                ),
                                child: Icon(
                                  star <= rating
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 40,
                                  color: star <= rating ? accent : dim,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              SupportFormField(
                controller: _descriptionController,
                label: AppStrings.supportDescription.tr,
                hint: AppStrings.supportEnterDescription.tr,
                icon: Icons.chat_bubble_outline_rounded,
                maxLines: 6,
              ),
              const SizedBox(height: AppSpacing.x2l),
              StreamBuilder<bool>(
                stream: _vm.isSubmitting$,
                builder: (context, snap) {
                  return SupportSubmitButton(
                    isSubmitting: snap.data ?? false,
                    onPressed: _submitForm,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
