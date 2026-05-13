import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';
import 'package:readline_app/core/theme/app_spacing.dart';

class LibraryLoadingSkeleton extends StatefulWidget {
  final bool isDark;

  const LibraryLoadingSkeleton({super.key, required this.isDark});

  @override
  State<LibraryLoadingSkeleton> createState() => _LibraryLoadingSkeletonState();
}

class _LibraryLoadingSkeletonState extends State<LibraryLoadingSkeleton>
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
              _shimmerBox(160, 28, baseColor, shimmerColor,
                  borderRadius: AppRadius.smBorder),
              const SizedBox(height: AppSpacing.xs),
              // Subtitle placeholder
              _shimmerBox(100, 14, baseColor, shimmerColor,
                  borderRadius: AppRadius.xsmBorder),
              const SizedBox(height: AppSpacing.md),
              // Search bar placeholder
              _shimmerBox(double.infinity, 44, baseColor, shimmerColor,
                  borderRadius: AppRadius.lgBorder),
              const SizedBox(height: AppSpacing.md),
              // Filter chips placeholder
              Row(
                children: [
                  _shimmerBox(56, 30, baseColor, shimmerColor,
                      borderRadius: AppRadius.fullBorder),
                  const SizedBox(width: AppSpacing.xs),
                  _shimmerBox(72, 30, baseColor, shimmerColor,
                      borderRadius: AppRadius.fullBorder),
                  const SizedBox(width: AppSpacing.xs),
                  _shimmerBox(80, 30, baseColor, shimmerColor,
                      borderRadius: AppRadius.fullBorder),
                  const SizedBox(width: AppSpacing.xs),
                  _shimmerBox(64, 30, baseColor, shimmerColor,
                      borderRadius: AppRadius.fullBorder),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Grid cards placeholder (2x2)
              Row(
                children: [
                  Expanded(
                    child: _shimmerBox(
                        double.infinity, 200, baseColor, shimmerColor,
                        borderRadius: AppRadius.lgBorder),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _shimmerBox(
                        double.infinity, 200, baseColor, shimmerColor,
                        borderRadius: AppRadius.lgBorder),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _shimmerBox(
                        double.infinity, 200, baseColor, shimmerColor,
                        borderRadius: AppRadius.lgBorder),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _shimmerBox(
                        double.infinity, 200, baseColor, shimmerColor,
                        borderRadius: AppRadius.lgBorder),
                  ),
                ],
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
