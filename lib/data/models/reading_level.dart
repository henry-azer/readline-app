import 'package:flutter/material.dart';

class ReadingLevel {
  final String id;
  final String label;
  final String levelTag;
  final String wpmRange;
  final String description;
  final IconData icon;
  final int levelNumber;

  const ReadingLevel({
    required this.id,
    required this.label,
    required this.levelTag,
    required this.wpmRange,
    required this.description,
    required this.icon,
    required this.levelNumber,
  });
}
