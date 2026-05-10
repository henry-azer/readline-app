import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_typography.dart';

class MagicSectionLabel extends StatelessWidget {
  final String text;
  final Color color;

  const MagicSectionLabel({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.settingsEyebrow.copyWith(color: color),
    );
  }
}
