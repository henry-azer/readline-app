import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_typography.dart';

/// Uppercase eyebrow label used to title each section in the display settings
/// tab (font family, letter spacing, text alignment, etc.).
class DisplaySectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const DisplaySectionLabel({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.readingSheetLabel.copyWith(color: color),
    );
  }
}
