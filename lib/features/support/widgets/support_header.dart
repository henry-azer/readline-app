import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/extensions/context_extensions.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class SupportHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SupportHeader({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final iconColor = isDark
        ? AppColors.onSurface
        : AppColors.lightOnSurface;
    final titleColor = isDark
        ? AppColors.onSurface
        : AppColors.lightOnSurface;

    return AppBar(
      backgroundColor: bgColor,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: iconColor),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: Text(
        title.toUpperCase(),
        style: AppTypography.supportHeaderTitle.copyWith(color: titleColor),
      ),
    );
  }
}
