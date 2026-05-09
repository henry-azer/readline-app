import 'package:readline_app/data/models/document_model.dart';

/// Canonical "smart" ordering used wherever the app surfaces a document list
/// without an explicit sort: tri-tier composite, most-recent-first within
/// each tier.
///
///   1. In-progress   — by `lastReadAt` descending (continue what you started)
///   2. Unread        — by `importedAt` descending (newest additions)
///   3. Completed     — by `lastReadAt` descending (revisit recently finished)
///
/// Sorts [docs] in place. Direction is fixed; this isn't a configurable
/// comparator — see `LibraryViewModel` for user-driven sort options.
void sortDocumentsSmart(List<DocumentModel> docs) {
  int tier(DocumentModel d) {
    if (d.isInProgress) return 0;
    if (d.isUnread) return 1;
    return 2; // completed
  }

  final epoch = DateTime.fromMillisecondsSinceEpoch(0);

  docs.sort((a, b) {
    final tierCmp = tier(a).compareTo(tier(b));
    if (tierCmp != 0) return tierCmp;

    final aKey = switch (tier(a)) {
      1 => a.importedAt,
      _ => a.lastReadAt ?? epoch,
    };
    final bKey = switch (tier(b)) {
      1 => b.importedAt,
      _ => b.lastReadAt ?? epoch,
    };
    return bKey.compareTo(aKey);
  });
}
