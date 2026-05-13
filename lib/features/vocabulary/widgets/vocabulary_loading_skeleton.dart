import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';

class VocabularyLoadingSkeleton extends StatefulWidget {
  final bool isDark;

  const VocabularyLoadingSkeleton({super.key, required this.isDark});

  @override
  State<VocabularyLoadingSkeleton> createState() =>
      _VocabularyLoadingSkeletonState();
}

class _VocabularyLoadingSkeletonState extends State<VocabularyLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.skeleton,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDark
        ? AppColors.surfaceContainerLow
        : AppColors.lightSurfaceContainerLow;
    final shimmerColor = widget.isDark
        ? AppColors.surfaceContainerHigh
        : AppColors.lightSurfaceContainer;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.micro),
              // Title placeholder
              _shimmerBox(140, 28, baseColor, shimmerColor,
                  borderRadius: AppRadius.smBorder),
              const SizedBox(height: AppSpacing.xs),
              // Word count placeholder
              _shimmerBox(80, 14, baseColor, shimmerColor,
                  borderRadius: AppRadius.xsmBorder),
              const SizedBox(height: AppSpacing.md),
              // Search bar placeholder
              _shimmerBox(double.infinity, 44, baseColor, shimmerColor,
                  borderRadius: AppRadius.lgBorder),
              const SizedBox(height: AppSpacing.md),
              // Filter chips placeholder
              Row(
                children: [
                  _shimmerBox(48, 30, baseColor, shimmerColor,
                      borderRadius: AppRadius.fullBorder),
                  const SizedBox(width: AppSpacing.xs),
                  _shimmerBox(56, 30, baseColor, shimmerColor,
                      borderRadius: AppRadius.fullBorder),
                  const SizedBox(width: AppSpacing.xs),
                  _shimmerBox(68, 30, baseColor, shimmerColor,
                      borderRadius: AppRadius.fullBorder),
                  const SizedBox(width: AppSpacing.xs),
                  _shimmerBox(56, 30, baseColor, shimmerColor,
                      borderRadius: AppRadius.fullBorder),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Word card placeholders
              for (int i = 0; i < 5; i++) ...[
                _shimmerBox(double.infinity, 80, baseColor, shimmerColor,
                    borderRadius: AppRadius.lgBorder),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(
    double width,
    double height,
    Color base,
    Color shimmer, {
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              colors: [base, shimmer, base],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + 2 * _controller.value, 0),
              end: Alignment(1.0 + 2 * _controller.value, 0),
            ),
          ),
        );
      },
    );
  }
}
