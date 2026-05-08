import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';

class HomeLoadingSkeleton extends StatefulWidget {
  final bool isDark;

  const HomeLoadingSkeleton({super.key, required this.isDark});

  @override
  State<HomeLoadingSkeleton> createState() => _HomeLoadingSkeletonState();
}

class _HomeLoadingSkeletonState extends State<HomeLoadingSkeleton>
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
              const SizedBox(height: AppSpacing.md),
              // Greeting placeholder
              _shimmerBox(
                200,
                16,
                baseColor,
                shimmerColor,
                borderRadius: AppRadius.smBorder,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Continue reading hero card
              _shimmerBox(
                double.infinity,
                200,
                baseColor,
                shimmerColor,
                borderRadius: AppRadius.xlgBorder,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Progress row
              Row(
                children: [
                  Expanded(
                    child: _shimmerBox(
                      double.infinity,
                      80,
                      baseColor,
                      shimmerColor,
                      borderRadius: AppRadius.lgBorder,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _shimmerBox(
                      double.infinity,
                      80,
                      baseColor,
                      shimmerColor,
                      borderRadius: AppRadius.lgBorder,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Document shelf
              _shimmerBox(
                double.infinity,
                120,
                baseColor,
                shimmerColor,
                borderRadius: AppRadius.mslBorder,
              ),
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
