import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';

/// Three-pill row for toggling reading text style (bold / italic / underline).
class StyleTogglePills extends StatelessWidget {
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final Color primary;
  final Color onSurfaceVariant;
  final Color trackColor;
  final VoidCallback onBoldToggled;
  final VoidCallback onItalicToggled;
  final VoidCallback onUnderlineToggled;

  const StyleTogglePills({
    super.key,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.primary,
    required this.onSurfaceVariant,
    required this.trackColor,
    required this.onBoldToggled,
    required this.onItalicToggled,
    required this.onUnderlineToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill(
          isActive: isBold,
          icon: Icons.format_bold_rounded,
          onTap: onBoldToggled,
        ),
        _pill(
          isActive: isItalic,
          icon: Icons.format_italic_rounded,
          onTap: onItalicToggled,
        ),
        _pill(
          isActive: isUnderline,
          icon: Icons.format_underline_rounded,
          onTap: onUnderlineToggled,
        ),
      ],
    );
  }

  Widget _pill({
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? primary
                  : onSurfaceVariant.withValues(alpha: 0.12),
              borderRadius: AppRadius.smBorder,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.white : onSurfaceVariant,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
