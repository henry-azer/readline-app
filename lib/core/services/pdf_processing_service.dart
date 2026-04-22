import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import 'package:read_it/core/constants/app_constants.dart';
import 'package:read_it/data/models/pdf_document_model.dart';

class PdfProcessingService {
  static const _uuid = Uuid();

  /// Common English words (top ~100) for complexity detection
  static const _commonWords = <String>{
    'the',
    'be',
    'to',
    'of',
    'and',
    'a',
    'in',
    'that',
    'have',
    'i',
    'it',
    'for',
    'not',
    'on',
    'with',
    'he',
    'as',
    'you',
    'do',
    'at',
    'this',
    'but',
    'his',
    'by',
    'from',
    'they',
    'we',
    'say',
    'her',
    'she',
    'or',
    'an',
    'will',
    'my',
    'one',
    'all',
    'would',
    'there',
    'their',
    'what',
    'so',
    'up',
    'out',
    'if',
    'about',
    'who',
    'get',
    'which',
    'go',
    'me',
    'when',
    'make',
    'can',
    'like',
    'time',
    'no',
    'just',
    'him',
    'know',
    'take',
    'people',
    'into',
    'year',
    'your',
    'good',
    'some',
    'could',
    'them',
    'see',
    'other',
    'than',
    'then',
    'now',
    'look',
    'only',
    'come',
    'its',
    'over',
    'think',
    'also',
    'back',
    'after',
    'use',
    'two',
    'how',
    'our',
    'work',
    'first',
    'well',
    'way',
    'even',
    'new',
    'want',
    'because',
    'any',
    'these',
    'give',
    'day',
    'most',
    'us',
    'was',
    'were',
    'been',
    'had',
    'are',
    'is',
  };

  Future<PdfDocumentModel> processFile(File file) async {
    final bytes = await file.readAsBytes();
    final result = await compute(_extractPdf, bytes);

    final fileName = file.path.split('/').last;
    final title = fileName.replaceAll('.pdf', '');

    return PdfDocumentModel(
      id: _uuid.v4(),
      title: title,
      filePath: file.path,
      fileName: fileName,
      totalPages: result.pageCount,
      totalWords: result.wordCount,
      complexityScore: result.complexity,
      complexityLevel: _complexityLevel(result.complexity),
      extractedText: result.text,
      importedAt: DateTime.now(),
    );
  }

  static _PdfExtractResult _extractPdf(List<int> bytes) {
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    final pageCount = document.pages.count;
    document.dispose();

    final words = text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    final avgLength =
        words.isEmpty ? 0.0 : words.fold<int>(0, (sum, w) => sum + w.length) / words.length;
    final uncommonRatio = words.isEmpty
        ? 0.0
        : words.where((w) => !_commonWords.contains(w.toLowerCase())).length /
            words.length;
    final complexity = (avgLength * 10 + uncommonRatio * 50).clamp(0.0, 100.0);

    return _PdfExtractResult(
      text: text,
      pageCount: pageCount,
      wordCount: words.length,
      complexity: complexity,
    );
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

  Future<PdfDocumentModel> processSampleText(String text) async {
    final words = text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final complexity = _calculateComplexity(words);

    return PdfDocumentModel(
      id: _uuid.v4(),
      title: 'Sample Text',
      filePath: '',
      fileName: 'sample_text.txt',
      totalPages: 1,
      totalWords: words.length,
      complexityScore: complexity,
      complexityLevel: _complexityLevel(complexity),
      extractedText: text,
      importedAt: DateTime.now(),
    );
  }
}

class _PdfExtractResult {
  final String text;
  final int pageCount;
  final int wordCount;
  final double complexity;

  const _PdfExtractResult({
    required this.text,
    required this.pageCount,
    required this.wordCount,
    required this.complexity,
  });
}
