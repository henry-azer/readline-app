import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:readline_app/features/reading/widgets/word_definition_overlay.dart';

/// Shows a word definition popup as an OverlayEntry near the tapped position.
///
/// If [savedListener] / [onToggle] are provided, the popup defers the
/// saved-state lookup and the save/remove action to the parent (so the popup
/// stays in sync with the bottom vocab bar). Otherwise it falls back to
/// reading and writing through `VocabularyService` directly via the overlay's
/// own viewmodel.
///
/// The caller (screen) owns the `OverlayEntry`'s lifecycle and is responsible
/// for calling `entry.remove()` exactly once in [onDismiss]. The overlay
/// itself never removes the entry — this avoids "removed twice" assertions
/// when both the overlay self-dismisses and the screen also tries to clean up.
///
/// [onCloseStarted] fires *before* the overlay fade so any sibling UI (like
/// the bottom vocab bar) can animate out in parallel rather than waiting for
/// the fade to finish.
///
/// Returns the `OverlayEntry` so the caller can remove it on dismiss.
OverlayEntry showWordDefinitionPopup({
  required BuildContext context,
  required String word,
  required Offset tapPosition,
  required String sourceDocumentId,
  required String sourceDocumentTitle,
  required String contextSentence,
  required VoidCallback onDismiss,
  VoidCallback? onCloseStarted,
  VoidCallback? onSaved,
  ValueListenable<bool>? savedListener,
  VoidCallback? onToggle,
  double bottomReserve = 0,
}) {
  final entry = OverlayEntry(
    builder: (ctx) => WordDefinitionOverlay(
      word: word,
      tapPosition: tapPosition,
      sourceDocumentId: sourceDocumentId,
      sourceDocumentTitle: sourceDocumentTitle,
      contextSentence: contextSentence,
      onDismiss: onDismiss,
      onCloseStarted: onCloseStarted,
      onSaved: onSaved,
      savedListener: savedListener,
      onToggle: onToggle,
      bottomReserve: bottomReserve,
    ),
  );

  Overlay.of(context).insert(entry);
  return entry;
}
