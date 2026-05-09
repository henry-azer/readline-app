import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import 'package:readline_app/core/constants/app_constants.dart';
import 'package:readline_app/data/models/document_model.dart';

enum PdfProcessingErrorKind {
  /// PDF bytes could not be parsed at all.
  corrupt,

  /// PDF is password protected.
  encrypted,

  /// Parsed OK but contains no extractable text layer (scanned PDF, all
  /// images, or fonts without ToUnicode CMap entries that produce garbage
  /// glyph output).
  imageOnly,

  /// Catch-all when neither category fits.
  unknown,
}

class PdfProcessingException implements Exception {
  final PdfProcessingErrorKind kind;
  final String? detail;

  const PdfProcessingException(this.kind, {this.detail});

  @override
  String toString() =>
      'PdfProcessingException(${kind.name}${detail == null ? '' : ': $detail'})';
}

class PdfProcessingService {
  static const _uuid = Uuid();

  /// Common English words (top ~100) for complexity detection
  static const _commonWords = <String>{
    'the', 'be', 'to', 'of', 'and', 'a', 'in', 'that', 'have', 'i', 'it',
    'for', 'not', 'on', 'with', 'he', 'as', 'you', 'do', 'at', 'this', 'but',
    'his', 'by', 'from', 'they', 'we', 'say', 'her', 'she', 'or', 'an',
    'will', 'my', 'one', 'all', 'would', 'there', 'their', 'what', 'so', 'up',
    'out', 'if', 'about', 'who', 'get', 'which', 'go', 'me', 'when', 'make',
    'can', 'like', 'time', 'no', 'just', 'him', 'know', 'take', 'people',
    'into', 'year', 'your', 'good', 'some', 'could', 'them', 'see', 'other',
    'than', 'then', 'now', 'look', 'only', 'come', 'its', 'over', 'think',
    'also', 'back', 'after', 'use', 'two', 'how', 'our', 'work', 'first',
    'well', 'way', 'even', 'new', 'want', 'because', 'any', 'these', 'give',
    'day', 'most', 'us', 'was', 'were', 'been', 'had', 'are', 'is',
  };

  Future<DocumentModel> processFile(File file) async {
    final bytes = await file.readAsBytes();
    final result = await compute(_extractPdf, bytes);

    if (result.errorKind != null) {
      throw PdfProcessingException(
        result.errorKind!,
        detail: result.errorDetail,
      );
    }

    final cleaned = normalizeText(result.text);
    if (!isExtractionUsable(cleaned)) {
      throw const PdfProcessingException(PdfProcessingErrorKind.imageOnly);
    }

    final fileName = file.path.split('/').last;
    final title = fileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');

    final words = cleaned
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final complexity = _calculateComplexity(words);

    return DocumentModel(
      id: _uuid.v4(),
      title: title,
      filePath: file.path,
      fileName: fileName,
      totalPages: result.pageCount,
      totalWords: words.length,
      complexityScore: complexity,
      complexityLevel: _complexityLevel(complexity),
      extractedText: cleaned,
      sourceType: 'pdf',
      importedAt: DateTime.now(),
    );
  }

  /// Run on an isolate via [compute]. Catches Syncfusion errors and maps
  /// them to a [PdfProcessingErrorKind] so the caller can surface a useful
  /// message instead of a generic failure.
  static _PdfExtractResult _extractPdf(List<int> bytes) {
    PdfDocument? document;
    try {
      document = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(document).extractText();
      final pageCount = document.pages.count;
      return (
        text: text,
        pageCount: pageCount,
        errorKind: null,
        errorDetail: null,
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      PdfProcessingErrorKind kind;
      if (msg.contains('password') || msg.contains('encrypt')) {
        kind = PdfProcessingErrorKind.encrypted;
      } else if (msg.contains('invalid') ||
          msg.contains('corrupt') ||
          msg.contains('format')) {
        kind = PdfProcessingErrorKind.corrupt;
      } else {
        kind = PdfProcessingErrorKind.unknown;
      }
      return (
        text: '',
        pageCount: 0,
        errorKind: kind,
        errorDetail: e.toString(),
      );
    } finally {
      document?.dispose();
    }
  }

  double _calculateComplexity(List<String> words) {
    if (words.isEmpty) return 0;
    final avgLength =
        words.fold<int>(0, (sum, w) => sum + w.length) / words.length;
    final uncommonRatio =
        words.where((w) => !_commonWords.contains(w.toLowerCase())).length /
        words.length;
    return (avgLength * 10 + uncommonRatio * 50).clamp(0, 100);
  }

  String _complexityLevel(double score) {
    if (score < AppConstants.beginnerMax) return 'beginner';
    if (score < AppConstants.intermediateMax) return 'intermediate';
    if (score < AppConstants.advancedMax) return 'advanced';
    return 'expert';
  }

  /// Classify a single word into easy / medium / hard for the vocabulary
  /// difficulty pill. Heuristic: common-list membership and length only —
  /// no per-word frequency table is shipped, so this is intentionally
  /// approximate. The user can always cycle to override.
  String classifyDifficulty(String word) {
    final w = word.toLowerCase().trim();
    if (w.isEmpty) return 'medium';
    if (_commonWords.contains(w) || w.length <= 5) return 'easy';
    if (w.length >= 10) return 'hard';
    return 'medium';
  }

  /// Detect complex words for auto-vocabulary collection
  List<String> detectComplexWords(String text) {
    final words = text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase())
        .where((w) => w.length > 3)
        .toSet();
    return words
        .where((w) => !_commonWords.contains(w) && w.length >= 7)
        .toList();
  }

  Future<DocumentModel> processSampleText(String text) async {
    final cleaned = normalizeText(text);
    final words = cleaned
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final complexity = _calculateComplexity(words);

    return DocumentModel(
      id: _uuid.v4(),
      title: 'Sample Text',
      fileName: 'sample_text.txt',
      totalPages: 1,
      totalWords: words.length,
      complexityScore: complexity,
      complexityLevel: _complexityLevel(complexity),
      extractedText: cleaned,
      sourceType: 'text_input',
      importedAt: DateTime.now(),
    );
  }

  /// Cleans text from PDF or TXT extraction so it flows as readable prose:
  /// - Strips Unicode BOM and zero-width spaces.
  /// - Normalizes line endings (CRLF, CR → LF).
  /// - Converts form feeds (page breaks) into paragraph breaks.
  /// - Repairs hyphenated words split across line breaks (`differ-\nence`
  ///   → `difference`).
  /// - Reflows soft-wrapped lines: a line break in the middle of a sentence
  ///   becomes a single space; double line breaks remain as paragraph
  ///   separators.
  /// - Collapses runs of 3+ blank lines down to a single paragraph break,
  ///   and runs of internal whitespace down to a single space.
  static String normalizeText(String input) {
    if (input.isEmpty) return input;

    var text = input;

    // Strip BOM and zero-width / soft-hyphen characters.
    text = text.replaceAll('﻿', '');
    text = text.replaceAll('​', '');
    text = text.replaceAll('‌', '');
    text = text.replaceAll('‍', '');
    text = text.replaceAll('­', '');

    // Normalize line endings: CRLF / CR → LF.
    text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Form feeds (page breaks) → paragraph break.
    text = text.replaceAll('\f', '\n\n');

    // Repair words hyphenated across a line break: "abc-\nxyz" → "abcxyz".
    text = text.replaceAllMapped(
      RegExp(r'(\w)-\n(\w)'),
      (m) => '${m.group(1)}${m.group(2)}',
    );

    // Reflow soft line wraps. A single \n preceded by a letter and followed
    // by a lowercase letter or digit is almost certainly a soft wrap; turn
    // it into a single space. Two or more \n stays as a paragraph break.
    text = text.replaceAllMapped(
      RegExp(r'([a-zA-Z,;])\n(?!\n)([a-z0-9])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );

    // Collapse 3+ blank lines down to a single paragraph break.
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Collapse runs of horizontal whitespace inside a line down to one space.
    text = text.replaceAll(RegExp(r'[ \t]{2,}'), ' ');

    // Trim each line of leading/trailing whitespace.
    text = text
        .split('\n')
        .map((line) => line.trim())
        .join('\n')
        .trim();

    return text;
  }

  /// Returns false when the extracted text looks like glyph garbage rather
  /// than real prose — for example, when a PDF lacks proper font encoding
  /// and Syncfusion emits long runs of repeated single characters or
  /// "words" with no vowels. This is what protects users from saving a
  /// document that they'll only see as `AAAAA AAAA` in the reader.
  static bool isExtractionUsable(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final tokens = trimmed
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (tokens.length < 20) return false;

    // Among letter-only tokens of plausible length, what fraction look
    // like they could be English words (contain a vowel and aren't a
    // single character repeated)?
    final letterTokens = tokens
        .map((t) => t.replaceAll(RegExp(r'[^A-Za-z]'), ''))
        .where((t) => t.length >= 2 && t.length <= 20)
        .toList();
    if (letterTokens.length < 10) return false;

    final plausible = letterTokens.where(_looksLikeWord).length;
    final ratio = plausible / letterTokens.length;
    return ratio >= 0.5;
  }

  static bool _looksLikeWord(String token) {
    final lower = token.toLowerCase();
    // "AAAAA", "BBB" etc → all same letter.
    if (RegExp(r'^(.)\1+$').hasMatch(lower)) return false;
    // Three or more identical letters in a row anywhere ("AAEPINAO" has
    // none, but "AAAMAAAA" has three As — common glyph-garbage shape).
    if (RegExp(r'(.)\1\1').hasMatch(lower)) return false;

    final vowels = RegExp(r'[aeiouy]').allMatches(lower).length;
    final consonants =
        RegExp(r'[bcdfghjklmnpqrstvwxz]').allMatches(lower).length;
    if (vowels == 0 || consonants == 0) return false;

    // Real English words sit roughly in 20-70 % vowels. Tokens that are
    // overwhelmingly vowels (like "AGAIA") or overwhelmingly consonants
    // (like "BCDFG") are extraction artifacts.
    final letters = vowels + consonants;
    if (letters == 0) return false;
    final vowelRatio = vowels / letters;
    if (vowelRatio < 0.15 || vowelRatio > 0.75) return false;

    return true;
  }
}

typedef _PdfExtractResult = ({
  String text,
  int pageCount,
  PdfProcessingErrorKind? errorKind,
  String? errorDetail,
});
