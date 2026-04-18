import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../data/models/pdf_document_model.dart';

class PdfProcessingService {
  static const Uuid _uuid = Uuid();

  Future<PdfDocumentModel> processPdfFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('PDF file not found: $filePath');
      }

      final fileName = path.basenameWithoutExtension(filePath);
      final documentId = _uuid.v4();

      // Load PDF document
      final pdfDocument = PdfDocument(inputBytes: await file.readAsBytes());
      
      // Extract text content
      final textContent = await _extractTextFromPdf(pdfDocument);
      
      // Calculate metrics
      final pageCount = pdfDocument.pages.count;
      final wordCount = _calculateWordCount(textContent);
      
      // Dispose document
      pdfDocument.dispose();

      return PdfDocumentModel(
        id: documentId,
        title: fileName,
        filePath: filePath,
        pageCount: pageCount,
        wordCount: wordCount,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to process PDF: $e');
    }
  }

  Future<List<String>> extractPages(String filePath) async {
    try {
      final file = File(filePath);
      final pdfDocument = PdfDocument(inputBytes: await file.readAsBytes());
      
      final List<String> pages = [];
      
      for (int i = 0; i < pdfDocument.pages.count; i++) {
        final page = pdfDocument.pages[i];
        final textExtractor = PdfTextExtractor(page);
        final pageText = textExtractor.extractText();
        pages.add(pageText);
      }
      
      pdfDocument.dispose();
      return pages;
    } catch (e) {
      throw Exception('Failed to extract pages: $e');
    }
  }

  Future<String> extractFullText(String filePath) async {
    try {
      final pages = await extractPages(filePath);
      return pages.join('\n\n');
    } catch (e) {
      throw Exception('Failed to extract full text: $e');
    }
  }

  Future<List<String>> splitIntoReadableChunks(String content, {int maxWordsPerChunk = 100}) async {
    final words = content.split(RegExp(r'\s+'));
    final List<String> chunks = [];
    
    for (int i = 0; i < words.length; i += maxWordsPerChunk) {
      final end = (i + maxWordsPerChunk < words.length) 
          ? i + maxWordsPerChunk 
          : words.length;
      final chunk = words.sublist(i, end).join(' ');
      chunks.add(chunk);
    }
    
    return chunks;
  }

  Future<String> _extractTextFromPdf(PdfDocument document) async {
    final StringBuffer fullText = StringBuffer();
    
    for (int i = 0; i < document.pages.count; i++) {
      final page = document.pages[i];
      final textExtractor = PdfTextExtractor(page);
      final pageText = textExtractor.extractText();
      fullText.writeln(pageText);
    }
    
    return fullText.toString();
  }

  int _calculateWordCount(String text) {
    if (text.isEmpty) return 0;
    
    // Remove extra whitespace and split into words
    final words = text.trim().split(RegExp(r'\s+'));
    
    // Filter out empty strings and count actual words
    return words.where((word) => word.isNotEmpty).length;
  }

  Future<double> estimateReadingTime(String content, {double wordsPerMinute = 200}) async {
    final wordCount = _calculateWordCount(content);
    return wordCount / wordsPerMinute; // Returns time in minutes
  }

  Future<Map<String, dynamic>> analyzeTextComplexity(String content) async {
    final words = content.split(RegExp(r'\s+'));
    final sentences = content.split(RegExp(r'[.!?]+'));
    
    final averageWordsPerSentence = words.length / sentences.length;
    final averageWordLength = words
        .where((word) => word.isNotEmpty)
        .map((word) => word.length)
        .reduce((a, b) => a + b) / words.length;
    
    // Simple complexity score based on average word length and sentence length
    final complexityScore = (averageWordLength * 0.3 + averageWordsPerSentence * 0.7);
    
    return {
      'wordCount': words.length,
      'sentenceCount': sentences.length,
      'averageWordsPerSentence': averageWordsPerSentence,
      'averageWordLength': averageWordLength,
      'complexityScore': complexityScore,
      'difficultyLevel': _getDifficultyLevel(complexityScore),
    };
  }

  String _getDifficultyLevel(double score) {
    if (score < 10) return 'Beginner';
    if (score < 15) return 'Intermediate';
    if (score < 20) return 'Advanced';
    return 'Expert';
  }

  Future<bool> validatePdfFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      
      final bytes = await file.readAsBytes();
      if (bytes.length < 4) return false;
      
      // Check PDF header
      final header = String.fromCharCodes(bytes.take(4).toList());
      return header == '%PDF';
    } catch (e) {
      return false;
    }
  }
}
