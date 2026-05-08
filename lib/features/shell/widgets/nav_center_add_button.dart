import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_gradients.dart';
import 'package:readline_app/widgets/tap_scale.dart';

const _centerButtonSize = 56.0;

class NavCenterAddButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const NavCenterAddButton({
    super.key,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    return TapScale(
      onTap: onTap,
      child: Container(
        width: _centerButtonSize,
        height: _centerButtonSize,
        decoration: BoxDecoration(
          gradient: AppGradients.primary(isDark),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 28,
          color: AppColors.white,
        ),
      ),
    );
  }
}
