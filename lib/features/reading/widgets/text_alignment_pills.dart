import 'package:flutter/material.dart';
import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/theme/app_colors.dart';
import 'package:readline_app/core/theme/app_durations.dart';
import 'package:readline_app/core/theme/app_radius.dart';

/// Four-pill row for choosing text alignment (left / center / right / justify).
class TextAlignmentPills extends StatelessWidget {
  final String selected;
  final Color primary;
  final Color onSurfaceVariant;
  final Color trackColor;
  final ValueChanged<String> onChanged;

  static const _options = <({String id, IconData icon, String labelKey})>[
    (
      id: 'left',
      icon: Icons.format_align_left_rounded,
      labelKey: 'player.alignLeft',
    ),
    (
      id: 'center',
      icon: Icons.format_align_center_rounded,
      labelKey: 'player.alignCenter',
    ),
    (
      id: 'right',
      icon: Icons.format_align_right_rounded,
      labelKey: 'player.alignRight',
    ),
    (
      id: 'justified',
      icon: Icons.format_align_justify_rounded,
      labelKey: 'player.alignJustified',
    ),
  ];

  const TextAlignmentPills({
    super.key,
    required this.selected,
    required this.primary,
    required this.onSurfaceVariant,
    required this.trackColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((o) {
        final isActive = selected == o.id;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onChanged(o.id),
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
                  o.icon,
                  color: isActive ? AppColors.white : onSurfaceVariant,
                  size: 18,
                  semanticLabel: o.labelKey.tr,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
