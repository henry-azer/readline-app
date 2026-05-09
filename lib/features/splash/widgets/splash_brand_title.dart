import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class SplashBrandTitle extends StatelessWidget {
  const SplashBrandTitle({
    super.key,
    required this.fade,
    required this.color,
  });

  final Animation<double> fade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: Text(
        // Same wordmark used by every AppBar BrandMark — keeps the splash
        // hero visually consistent with the rest of the app instead of an
        // upper-case "READLINE" variant.
        AppStrings.generalAppName.tr,
        style: AppTypography.splashBrand.copyWith(color: color),
      ),
    );
  }
}
