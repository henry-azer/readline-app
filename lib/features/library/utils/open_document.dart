import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readline_app/core/router/app_router.dart';
import 'package:readline_app/data/models/document_model.dart';

/// Navigates to the reading screen for [doc]. Completed documents are
/// auto-restarted from the beginning by `ReadingViewModel.init()`, so no
/// confirmation prompt is shown — tapping a recent / completed doc takes
/// the user straight back into reading.
Future<void> openDocumentForReading(
  BuildContext context,
  DocumentModel doc,
) async {
  await context.push('${AppRoutes.reading}/${doc.id}');
}
