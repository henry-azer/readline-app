import 'package:flutter/material.dart';

/// Short horizontal hairline used as a chapter-divider mark on either side
/// of the document title in the session summary dialog.
class TitleHairline extends StatelessWidget {
  final Color color;

  const TitleHairline({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 1,
      color: color.withValues(alpha: 0.5),
    );
  }
}
