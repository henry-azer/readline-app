import 'package:flutter/material.dart';

/// Visual style descriptor for difficulty / mastery vocabulary pills.
class VocabChipStyle {
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final String label;

  const VocabChipStyle({
    required this.bgColor,
    required this.textColor,
    required this.label,
    this.borderColor,
  });
}
