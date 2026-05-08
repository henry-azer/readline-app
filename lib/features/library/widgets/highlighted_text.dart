import 'package:flutter/material.dart';

/// Highlights occurrences of [query] within [text] using a bold style and
/// a translucent background of [highlightColor].
class HighlightedText extends StatelessWidget {
  final String text;
  final String? query;
  final TextStyle style;
  final Color highlightColor;
  final int maxLines;

  const HighlightedText({
    super.key,
    required this.text,
    this.query,
    required this.style,
    required this.highlightColor,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final q = query?.trim().toLowerCase() ?? '';
    if (q.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = <TextSpan>[];
    final lower = text.toLowerCase();
    int start = 0;

    while (true) {
      final index = lower.indexOf(q, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + q.length),
          style: TextStyle(
            color: highlightColor,
            fontWeight: FontWeight.w700,
            backgroundColor: highlightColor.withValues(alpha: 0.12),
          ),
        ),
      );
      start = index + q.length;
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
