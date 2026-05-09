import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/features/support/viewmodels/support_viewmodel.dart';
import 'package:readline_app/features/support/widgets/support_form_field.dart';
import 'package:readline_app/features/support/widgets/support_header.dart';
import 'package:readline_app/features/support/widgets/support_submit_button.dart';
import 'package:readline_app/widgets/app_snackbar.dart';

class BugReportScreen extends StatefulWidget {
  const BugReportScreen({super.key});

  @override
  State<BugReportScreen> createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
  late final SupportViewModel _vm;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = SupportViewModel.bugReport();
  }

  @override
  void dispose() {
    _vm.dispose();
    _nameController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _vm.submit(
      name: _nameController.text,
      subject: _subjectController.text,
      description: _descriptionController.text,
    );

    if (!mounted) return;

    if (result.success) {
      AppSnackbar.success(context, AppStrings.supportSubmitSuccess.tr);
    } else {
      AppSnackbar.error(context, AppStrings.supportSubmitError.tr);
    }

    if (result.success) {
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: SupportHeader(title: AppStrings.supportBugReport.tr),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.supportBugReportSubtitle.tr,
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
              const SizedBox(height: AppSpacing.lg),
              SupportFormField(
                controller: _subjectController,
                label: AppStrings.supportSubject.tr,
                hint: AppStrings.supportEnterSubject.tr,
                icon: Icons.bug_report_outlined,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? AppStrings.supportSubjectRequired.tr
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              SupportFormField(
                controller: _descriptionController,
                label: AppStrings.supportDescription.tr,
                hint: AppStrings.supportEnterDescription.tr,
                icon: Icons.description_outlined,
                maxLines: 6,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? AppStrings.supportDescriptionRequired.tr
                    : null,
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
