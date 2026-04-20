import 'dart:async';

import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/presentation/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:read_it/presentation/onboarding/widgets/assessment_step.dart';
import 'package:read_it/presentation/onboarding/widgets/first_import_step.dart';
import 'package:read_it/presentation/onboarding/widgets/welcome_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingViewModel _viewModel;
  late final PageController _pageController;
  StreamSubscription<int>? _stepSub;

  @override
  void initState() {
    super.initState();
    _viewModel = OnboardingViewModel();
    _pageController = PageController();

    // Sync PageView to ViewModel step changes
    _stepSub = _viewModel.step$.listen((step) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          step,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    _viewModel.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: bgColor,
      body: StreamBuilder<int>(
        stream: _viewModel.step$,
        initialData: 0,
        builder: (context, stepSnapshot) {
          final step = stepSnapshot.data ?? 0;

          return Stack(
            children: [
              // Main page content
              StreamBuilder<String>(
                stream: _viewModel.selectedLevel$,
                initialData: '',
                builder: (context, levelSnapshot) {
                  final selectedLevel = levelSnapshot.data ?? '';

                  return StreamBuilder<bool>(
                    stream: _viewModel.isLoading$,
                    initialData: false,
                    builder: (context, loadingSnapshot) {
                      final isLoading = loadingSnapshot.data ?? false;

                      return StreamBuilder<String?>(
                        stream: _viewModel.errorMessage$,
                        initialData: null,
                        builder: (context, errorSnapshot) {
                          final errorMsg = errorSnapshot.data;

                          return PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              // Step 1 — Welcome
                              WelcomeStep(onBegin: _viewModel.nextStep),

                              // Step 2 — Assessment
                              AssessmentStep(
                                selectedLevel: selectedLevel,
                                onSelectLevel: _viewModel.selectLevel,
                                onContinue: _viewModel.nextStep,
                                onCustomizeLater: () {
                                  _viewModel.selectLevel('intermediate');
                                  _viewModel.nextStep();
                                },
                              ),

                              // Step 3 — First Import
                              FirstImportStep(
                                isLoading: isLoading,
                                errorMessage: errorMsg,
                                onChooseFromFiles: () =>
                                    _viewModel.importPdf(context),
                                onSampleText: () =>
                                    _viewModel.useSampleText(context),
                                onSkip: () =>
                                    _viewModel.completeOnboarding(context),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),

              // Step indicator dots (visible on steps 1 and 2; pinned top-center on step 3)
              if (step > 0)
                Positioned(
                  top: MediaQuery.of(context).padding.top + AppSpacing.lg,
                  left: 0,
                  right: 0,
                  child: _StepIndicator(currentStep: step, totalSteps: 3),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;
    final inactive = isDark
        ? AppColors.outlineVariant.withValues(alpha: 0.5)
        : AppColors.lightOutlineVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? primary : inactive,
            borderRadius: AppRadius.fullBorder,
          ),
        );
      }),
    );
  }
}
