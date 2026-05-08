import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:read_it/core/extensions/context_extensions.dart';
import 'package:read_it/core/theme/app_colors.dart';
import 'package:read_it/core/theme/app_radius.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.blur = 40,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final radius = borderRadius ?? AppRadius.lgBorder;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassBackground(isDark),
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder(isDark),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
