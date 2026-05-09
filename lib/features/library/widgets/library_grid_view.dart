import 'package:flutter/material.dart';
import 'package:readline_app/core/theme/app_spacing.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/features/library/utils/open_document.dart';
import 'package:readline_app/features/library/viewmodels/library_viewmodel.dart';
import 'package:readline_app/features/library/widgets/document_grid_card.dart';

class LibraryGridView extends StatelessWidget {
  final List<DocumentModel> docs;
  final LibraryViewModel viewModel;
  final Future<void> Function(DocumentModel) onDeleteDocument;
  final ValueChanged<DocumentModel> onEditDocument;
  final String searchQuery;

  const LibraryGridView({
    super.key,
    required this.docs,
    required this.viewModel,
    required this.onDeleteDocument,
    required this.onEditDocument,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.bottomNavClearance + AppSpacing.xxl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.58,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return DocumentGridCard(
          document: doc,
          searchQuery: searchQuery,
          onTap: () => openDocumentForReading(context, doc),
          onEdit: () => onEditDocument(doc),
          onDelete: () => onDeleteDocument(doc),
        );
      },
    );
  }
}
