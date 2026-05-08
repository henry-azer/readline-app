import 'package:flutter/material.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_radius.dart';

class SettingsSectionCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsSectionCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardColor = isDark
        ? AppColors.surfaceContainer
        : AppColors.lightSurfaceContainerLowest;
    final border =
        (isDark ? AppColors.outlineVariant : AppColors.lightOutlineVariant)
            .withValues(alpha: 0.4);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: border),
      ),
      child: Column(children: children),
    );
  }
}
