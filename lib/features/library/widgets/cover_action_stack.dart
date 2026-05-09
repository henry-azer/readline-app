import 'package:flutter/material.dart';
import 'package:readline_app/features/library/utils/cover_palette.dart';
import 'package:readline_app/features/library/widgets/cover_icon_button.dart';

/// Edit / delete icon row rendered on the top-right of a document grid card
/// cover. Renders nothing when both callbacks are null.
class CoverActionStack extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CoverActionStack({
    super.key,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) return const SizedBox.shrink();

    // Match the cover title's contrast (light text on dark gradient,
    // near-black on light gradient) with a subtle alpha so the icons
    // read as muted controls rather than primary CTAs.
    final iconColor = CoverPalette.titleColor(
      isDark: isDark,
    ).withValues(alpha: 0.7);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          CoverIconButton(
            icon: Icons.edit_outlined,
            onTap: onEdit!,
            color: iconColor,
          ),
        if (onDelete != null)
          CoverIconButton(
            icon: Icons.delete_outline_rounded,
            onTap: onDelete!,
            color: iconColor,
          ),
      ],
    );
  }
}
