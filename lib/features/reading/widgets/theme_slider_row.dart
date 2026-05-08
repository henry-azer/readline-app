import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class ThemeSliderRow extends StatelessWidget {
  final String label;
  final String value;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Widget child;

  const ThemeSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.child,
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
