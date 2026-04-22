import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/localization/app_localization.dart';
import 'package:read_it/core/localization/app_strings.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_gradients.dart';
import 'package:read_it/core/theme/app_radius.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/core/theme/app_durations.dart';
import 'package:read_it/core/theme/app_curves.dart';
import 'package:read_it/core/theme/app_typography.dart';
import 'package:read_it/presentation/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:read_it/presentation/onboarding/screens/assessment_screen.dart';
import 'package:read_it/presentation/onboarding/screens/first_import_screen.dart';
import 'package:read_it/presentation/onboarding/screens/welcome_screen.dart';

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
        child: StreamBuilder<int>(
          stream: _viewModel.step$,
          initialData: 0,
          builder: (context, stepSnapshot) {
            final step = stepSnapshot.data ?? 0;

            return Stack(
              children: [
                // Content with cross-fade transition
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

                            return AnimatedSwitcher(
                              duration: AppDurations.calm,
                              switchInCurve: AppCurves.enter,
                              switchOutCurve: AppCurves.exit,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: _buildStep(
                                step: step,
                                selectedLevel: selectedLevel,
                                isLoading: isLoading,
                                errorMsg: errorMsg,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                // Brand mark + step indicator
                Positioned(
                  top: MediaQuery.of(context).padding.top + AppSpacing.xl,
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _BrandMark(isDark: isDark),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: _StepIndicator(currentStep: step, totalSteps: 3),
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
          duration: AppDurations.short,
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

class _BrandMark extends StatelessWidget {
  final bool isDark;

  const _BrandMark({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppGradients.primary(isDark).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: const Icon(Icons.auto_stories_rounded, size: 24),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          AppStrings.onboardingAssessmentLogo.tr,
          style: AppTypography.titleLarge.copyWith(
            color: primary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
