import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_spacing.dart';

/// Single icon button shown over a document grid card cover.
class CoverIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const CoverIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: AppSpacing.micro,
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
