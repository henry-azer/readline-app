import 'package:flutter/material.dart';

/// Returns the appropriate icon for a document source type.
IconData sourceTypeIcon(String sourceType) {
  return switch (sourceType) {
    'pdf' => Icons.picture_as_pdf_rounded,
    'txt' => Icons.description_rounded,
    'text_input' => Icons.keyboard_rounded,
    _ => Icons.insert_drive_file_rounded,
  };
}
