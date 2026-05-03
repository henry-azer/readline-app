import 'package:flutter/material.dart';
import 'package:read_it/core/theme/app_spacing.dart';
import 'package:read_it/data/models/document_model.dart';
import 'package:read_it/presentation/library/utils/open_document.dart';
import 'package:read_it/presentation/library/viewmodels/library_viewmodel.dart';
import 'package:read_it/presentation/library/widgets/document_list_tile.dart';

class LibraryListView extends StatelessWidget {
  final List<DocumentModel> docs;
  final LibraryViewModel viewModel;
  final Set<String> selectedIds;
  final bool isMultiSelect;
  final Future<void> Function(DocumentModel) onDeleteDocument;
  final ValueChanged<DocumentModel> onLongPress;
  final String searchQuery;

  const LibraryListView({
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
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: DocumentListTile(
              document: doc,
              isSelected: selectedIds.contains(doc.id),
              isMultiSelectMode: isMultiSelect,
              searchQuery: searchQuery,
              onTap: () => openDocumentForReading(context, doc),
              onDelete: () => onDeleteDocument(doc),
              onLongPress: () => onLongPress(doc),
              onToggleSelect: () => viewModel.toggleSelection(doc.id),
            ),
          );
        },
      ),
    );
  }
}
