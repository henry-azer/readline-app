import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class SplashTagline extends StatelessWidget {
  const SplashTagline({super.key, required this.fade, required this.color});

  final Animation<double> fade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: Text(
        AppStrings.splashTagline.tr,
        style: AppTypography.splashTagline.copyWith(color: color),
      ),
    );
  }
}
