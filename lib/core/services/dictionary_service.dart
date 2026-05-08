import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:readline_app/data/datasources/local/hive_definition_cache_source.dart';
import 'package:readline_app/data/models/word_definition_model.dart';

/// Result type for dictionary lookups.
enum DictionaryError { notFound, noInternet, timeout }

class DictionaryResult {
  final WordDefinitionModel? definition;
  final DictionaryError? error;

  const DictionaryResult({this.definition, this.error});

  bool get isSuccess => definition != null;
}

class DictionaryService {
  static const _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';
  static const _timeout = Duration(seconds: 3);

  final HiveDefinitionCacheSource _cache;
  final http.Client _client;

  DictionaryService(this._cache, {http.Client? client})
    : _client = client ?? http.Client();

  /// Look up a word definition. Returns cached result if available.
  Future<DictionaryResult> lookupWord(String word) async {
    final normalized = word.toLowerCase().trim();
    if (normalized.isEmpty) {
      return const DictionaryResult(error: DictionaryError.notFound);
    }

    // Check cache first
    final cached = await _cache.get(normalized);
    if (cached != null) {
      return DictionaryResult(definition: cached);
    }

    // Fetch from API
    try {
      final uri = Uri.parse('$_baseUrl/$normalized');
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final definition = _parseResponse(response.body, normalized);
        if (definition != null) {
          await _cache.save(normalized, definition);
          return DictionaryResult(definition: definition);
        }
        return const DictionaryResult(error: DictionaryError.notFound);
      } else if (response.statusCode == 404) {
        return const DictionaryResult(error: DictionaryError.notFound);
      }
      return const DictionaryResult(error: DictionaryError.notFound);
    } on TimeoutException {
      return const DictionaryResult(error: DictionaryError.timeout);
    } on http.ClientException {
      return const DictionaryResult(error: DictionaryError.noInternet);
    } catch (_) {
      return const DictionaryResult(error: DictionaryError.noInternet);
    }
  }

  WordDefinitionModel? _parseResponse(String body, String word) {
    try {
      final List<dynamic> entries = json.decode(body);
      if (entries.isEmpty) return null;

      final entry = entries.first as Map<String, dynamic>;
      final phonetic = _extractPhonetic(entry);
      final meanings = entry['meanings'] as List<dynamic>?;
      if (meanings == null || meanings.isEmpty) return null;

      final firstMeaning = meanings.first as Map<String, dynamic>;
      final partOfSpeech = firstMeaning['partOfSpeech'] as String? ?? '';
      final definitions = firstMeaning['definitions'] as List<dynamic>?;
      if (definitions == null || definitions.isEmpty) return null;

      final firstDef = definitions.first as Map<String, dynamic>;
      final definition = firstDef['definition'] as String? ?? '';
      final example = firstDef['example'] as String?;

      return WordDefinitionModel(
        word: entry['word'] as String? ?? word,
        phonetic: phonetic,
        partOfSpeech: partOfSpeech,
        definition: definition,
        exampleSentence: example,
      );
    } catch (_) {
      return null;
    }
  }

  String? _extractPhonetic(Map<String, dynamic> entry) {
    // Try top-level phonetic first
    final topLevel = entry['phonetic'] as String?;
    if (topLevel != null && topLevel.isNotEmpty) return topLevel;

    // Try phonetics array
    final phonetics = entry['phonetics'] as List<dynamic>?;
    if (phonetics == null) return null;

    for (final p in phonetics) {
      final text = (p as Map<String, dynamic>)['text'] as String?;
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}
