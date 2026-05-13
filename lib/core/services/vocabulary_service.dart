import 'package:uuid/uuid.dart';
import 'package:readline_app/data/contracts/vocabulary_repository.dart';
import 'package:readline_app/data/models/vocabulary_word_model.dart';
import 'package:readline_app/core/services/pdf_processing_service.dart';

class VocabularyService {
  final VocabularyRepository _repo;
  final PdfProcessingService _pdfService;
  static const _uuid = Uuid();

  /// In-memory cache of saved words for O(1) lookup.
  Set<String>? _savedWordsCache;

  VocabularyService(this._repo, this._pdfService);

  /// Populate the in-memory word cache from the repository.
  Future<void> _ensureCache() async {
    if (_savedWordsCache != null) return;
    final all = await _repo.getAll();
    _savedWordsCache = all.map((w) => w.word).toSet();
  }

  /// Check if a word is already saved in vocabulary.
  Future<bool> isWordSaved(String word) async {
    await _ensureCache();
    final normalized = word.toLowerCase().trim();
    return _savedWordsCache!.contains(normalized);
  }

  /// Remove a saved word from the vocabulary by its raw text. No-op if the
  /// word is not in the library. Keeps the in-memory cache in sync.
  Future<void> removeSavedWord(String word) async {
    await _ensureCache();
    final normalized = word.toLowerCase().trim();
    final all = await _repo.getAll();
    final matches = all.where((w) => w.word == normalized);
    if (matches.isEmpty) return;
    await _repo.delete(matches.first.id);
    _savedWordsCache?.remove(normalized);
  }

  Future<void> saveWord({
    required String word,
    String? definition,
    String? partOfSpeech,
    String? phonetic,
    String? exampleSentence,
    required String contextSentence,
    required String sourceDocumentId,
    required String sourceDocumentTitle,
    bool isAutoCollected = false,
  }) async {
    final normalized = word.toLowerCase().trim();
    final model = VocabularyWordModel(
      id: _uuid.v4(),
      word: normalized,
      definition: definition,
      partOfSpeech: partOfSpeech,
      phonetic: phonetic,
      exampleSentence: exampleSentence,
      contextSentence: contextSentence,
      sourceDocumentId: sourceDocumentId,
      sourceDocumentTitle: sourceDocumentTitle,
      addedAt: DateTime.now(),
      isAutoCollected: isAutoCollected,
      difficulty: _pdfService.classifyDifficulty(normalized),
    );
    await _repo.save(model);
    _savedWordsCache?.add(model.word);
  }

  Future<void> autoCollectFromText(
    String text, {
    required String sourceDocumentId,
    required String sourceDocumentTitle,
  }) async {
    final complexWords = _pdfService.detectComplexWords(text);
    final existing = await _repo.getAll();
    final existingWords = existing.map((w) => w.word).toSet();

    for (final word in complexWords) {
      if (existingWords.contains(word)) continue;
      // Extract context sentence containing the word
      final sentences = text.split(RegExp(r'[.!?]+'));
      final context = sentences.firstWhere(
        (s) => s.toLowerCase().contains(word),
        orElse: () => '',
      );
      if (context.isEmpty) continue;

      await saveWord(
        word: word,
        contextSentence: context.trim(),
        sourceDocumentId: sourceDocumentId,
        sourceDocumentTitle: sourceDocumentTitle,
        isAutoCollected: true,
      );
    }
  }
}
