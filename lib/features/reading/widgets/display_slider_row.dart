import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Labelled slider row used by display settings tab — shows the section
/// label on the left, an optional trailing accessory, the current value on
/// the right, and the slider beneath.
class DisplaySliderRow extends StatelessWidget {
  final String label;
  final String value;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Widget child;
  final Widget? trailing;

  const DisplaySliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.readingSheetLabel.copyWith(
                color: onSurfaceVariant,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.xs),
              trailing!,
            ],
            const Spacer(),
            Text(
              value,
              style: AppTypography.readingSliderValue.copyWith(
                color: onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 32, child: child),
      ],
    );
  }
}
