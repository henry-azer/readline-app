import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_curves.dart';
import 'package:readline_app/features/onboarding/viewmodels/onboarding_viewmodel.dart'
    show OnboardingContentState, OnboardingViewModel;
import 'package:readline_app/widgets/brand_mark.dart';
import 'package:readline_app/features/onboarding/screens/assessment_screen.dart';
import 'package:readline_app/features/onboarding/screens/first_import_screen.dart';
import 'package:readline_app/features/onboarding/screens/welcome_screen.dart';
import 'package:readline_app/features/onboarding/widgets/step_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OnboardingViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _handleSwipe(DragEndDetails details) {
    _viewModel.handleSwipeVelocity(details.primaryVelocity ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        behavior: HitTestBehavior.translucent,
        child: StreamBuilder<OnboardingContentState>(
          stream: _viewModel.contentState$,
          builder: (context, snapshot) {
            final state = snapshot.data;
            final step = state?.step ?? 0;
            final selectedLevel = state?.selectedLevel ?? '';
            final isLoading = state?.isLoading ?? false;
            final errorMsg = state?.errorMsg;

            return Stack(
              children: [
                AnimatedSwitcher(
                  duration: AppDurations.calm,
                  switchInCurve: AppCurves.enter,
                  switchOutCurve: AppCurves.exit,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _buildStep(
                    step: step,
                    selectedLevel: selectedLevel,
                    isLoading: isLoading,
                    errorMsg: errorMsg,
                  ),
                ),

                Positioned(
                  top: MediaQuery.of(context).padding.top + AppSpacing.xl,
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const BrandMark(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: StepIndicator(currentStep: step, totalSteps: 3),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStep({
    required int step,
    required String selectedLevel,
    required bool isLoading,
    required String? errorMsg,
  }) {
    switch (step) {
      case 0:
        return WelcomeScreen(
          key: const ValueKey(0),
          onBegin: _viewModel.nextStep,
        );
      case 1:
        return AssessmentScreen(
          key: const ValueKey(1),
          levels: _viewModel.levels,
          selectedLevel: selectedLevel,
          onSelectLevel: _viewModel.selectLevel,
          onContinue: _viewModel.nextStep,
          onCustomizeLater: () {
            _viewModel.selectLevel('');
            _viewModel.nextStep();
          },
        );
      case 2:
        return FirstImportScreen(
          key: const ValueKey(2),
          isLoading: isLoading,
          errorMessage: errorMsg,
          onChooseFromFiles: () => _viewModel.importPdf(context),
          onSampleText: () => _viewModel.useSampleText(context),
          onSkip: () => _viewModel.completeOnboarding(context),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
