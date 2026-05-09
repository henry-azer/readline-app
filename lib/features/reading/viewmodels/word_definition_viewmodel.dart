import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:readline_app/app.dart' show vocabChangeNotifier;
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/core/services/dictionary_service.dart';
import 'package:readline_app/core/services/tts_service.dart';
import 'package:readline_app/core/services/vocabulary_service.dart';
import 'package:readline_app/data/models/word_definition_model.dart';

/// Combined state for the word-definition popup.
typedef WordDefinitionUiState = ({
  bool isLoading,
  WordDefinitionModel? definition,
  DictionaryError? error,
});

/// Owns dictionary lookup, TTS playback, and vocabulary save/remove for the
/// floating word-definition popup. The widget consumes streams from this
/// viewmodel and dispatches user actions via its public methods.
class WordDefinitionViewModel {
  final DictionaryService _dictService;
  final TtsService _ttsService;
  final VocabularyService _vocabService;

  final String word;
  final String sourceDocumentId;
  final String sourceDocumentTitle;
  final String contextSentence;

  final BehaviorSubject<WordDefinitionUiState> uiState$ =
      BehaviorSubject.seeded(
    (isLoading: true, definition: null, error: null),
  );
  final BehaviorSubject<bool> isWordSaved$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> isTtsAvailable$ = BehaviorSubject.seeded(false);

  WordDefinitionViewModel({
    required this.word,
    required this.sourceDocumentId,
    required this.sourceDocumentTitle,
    required this.contextSentence,
    DictionaryService? dictService,
    TtsService? ttsService,
    VocabularyService? vocabService,
  }) : _dictService = dictService ?? getIt<DictionaryService>(),
       _ttsService = ttsService ?? getIt<TtsService>(),
       _vocabService = vocabService ?? getIt<VocabularyService>();

  /// TTS playback state stream — exposed so the speaker icon animates while
  /// playing.
  Stream<bool> get ttsPlaying$ => _ttsService.isPlaying$;

  Future<void> init() async {
    await Future.wait([_loadDefinition(), _checkTtsAvailability()]);
  }

  Future<void> loadInitialSavedState() async {
    final saved = await _vocabService.isWordSaved(word);
    if (!isWordSaved$.isClosed) isWordSaved$.add(saved);
  }

  void setSavedFromExternal(bool saved) {
    if (!isWordSaved$.isClosed) isWordSaved$.add(saved);
  }

  Future<void> _loadDefinition() async {
    final result = await _dictService.lookupWord(word);
    if (uiState$.isClosed) return;
    uiState$.add((
      isLoading: false,
      definition: result.definition,
      error: result.error,
    ));
  }

  Future<void> _checkTtsAvailability() async {
    final available = await _ttsService.isAvailable();
    if (!isTtsAvailable$.isClosed) isTtsAvailable$.add(available);
  }

  Future<void> speak() => _ttsService.speak(word);

  /// Toggles the word's saved state. Returns the new saved value.
  Future<bool> toggleSaved() async {
    final wasSaved = isWordSaved$.value;
    if (wasSaved) {
      await _vocabService.removeSavedWord(word);
      if (!isWordSaved$.isClosed) isWordSaved$.add(false);
      vocabChangeNotifier.value++;
      return false;
    }
    final def = uiState$.value.definition;
    final pos = def?.partOfSpeech;
    final phonetic = def?.phonetic;
    await _vocabService.saveWord(
      word: word,
      definition: def?.definition,
      partOfSpeech: (pos == null || pos.isEmpty) ? null : pos,
      phonetic: (phonetic == null || phonetic.isEmpty) ? null : phonetic,
      exampleSentence: def?.exampleSentence,
      contextSentence: contextSentence,
      sourceDocumentId: sourceDocumentId,
      sourceDocumentTitle: sourceDocumentTitle,
    );
    if (!isWordSaved$.isClosed) isWordSaved$.add(true);
    vocabChangeNotifier.value++;
    return true;
  }

  void dispose() {
    uiState$.close();
    isWordSaved$.close();
    isTtsAvailable$.close();
  }
}
