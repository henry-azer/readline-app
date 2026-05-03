import 'package:flutter/material.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/data/models/document_model.dart';
import 'package:read_it/presentation/library/utils/open_document.dart';
import 'package:read_it/presentation/library/viewmodels/library_viewmodel.dart';
import 'package:read_it/presentation/library/widgets/document_grid_card.dart';

class LibraryGridView extends StatelessWidget {
  final List<DocumentModel> docs;
  final LibraryViewModel viewModel;
  final Set<String> selectedIds;
  final bool isMultiSelect;
  final Future<void> Function(DocumentModel) onDeleteDocument;
  final ValueChanged<DocumentModel> onLongPress;
  final String searchQuery;

  const LibraryGridView({
    super.key,
    required this.docs,
    required this.viewModel,
    required this.selectedIds,
    required this.isMultiSelect,
    required this.onDeleteDocument,
    required this.onLongPress,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.bottomNavClearance,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
            isSelected: selectedIds.contains(doc.id),
            isMultiSelectMode: isMultiSelect,
            searchQuery: searchQuery,
            onTap: () => openDocumentForReading(context, doc),
            onDelete: () => onDeleteDocument(doc),
            onLongPress: () => onLongPress(doc),
            onToggleSelect: () => viewModel.toggleSelection(doc.id),
          );
        },
      ),
    );
  }
}
