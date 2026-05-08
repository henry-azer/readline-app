import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';

class GreetingHeader extends StatelessWidget {
  final String? userName;

  const GreetingHeader({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final onSurface = isDark ? AppColors.onSurface : AppColors.lightOnSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Text(
        _greeting(),
        style: AppTypography.homeEyebrowLabel.copyWith(
          color: onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    final displayName = (userName != null && userName!.isNotEmpty)
        ? userName!
        : AppStrings.homeGreetingDefaultName.tr;

    if (hour >= 5 && hour < 12) {
      return AppStrings.homeGreetingMorningName.trParams({'name': displayName});
    }
    if (hour >= 12 && hour < 18) {
      return AppStrings.homeGreetingAfternoonName.trParams({
        'name': displayName,
      });
    }
    return AppStrings.homeGreetingEveningName.trParams({'name': displayName});
  }
}
