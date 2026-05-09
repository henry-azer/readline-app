// Probe-only test: runs real PDFs through PdfProcessingService and prints
// extraction diagnostics. Skipped on CI (filename starts with `_`). Run
// locally with:
//   flutter test test/services/_pdf_probe_test.dart -r expanded
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:readline_app/core/services/pdf_processing_service.dart';

void main() {
  final pdfs = <String>[
    '/Users/henryazer/Downloads/namecheap-order-198753334.pdf',
    '/Users/henryazer/Downloads/Paid_Applications_v126.pdf',
    '/Users/henryazer/Downloads/YELLOW BOOK_STEP INTO THE RIDE.pdf',
  ];

  for (final path in pdfs) {
    test('probe: ${path.split('/').last}', () async {
      final file = File(path);
      if (!await file.exists()) {
        // ignore: avoid_print
        print('SKIP — not present: $path');
        return;
      }
      final svc = PdfProcessingService();
      try {
        final stopwatch = Stopwatch()..start();
        final doc = await svc.processFile(file);
        stopwatch.stop();
        // ignore: avoid_print
        print('USABLE: ${PdfProcessingService.isExtractionUsable(doc.extractedText)}');

        final text = doc.extractedText;
        final hasFormFeed = text.contains('\f');
        final hasBom = text.contains('﻿');
        final hyphenBreaks =
            RegExp(r'\w-\s*\n\s*\w').allMatches(text).length;
        final crlfCount = RegExp(r'\r\n').allMatches(text).length;
        final consecutiveBlanks =
            RegExp(r'\n\s*\n\s*\n').allMatches(text).length;
        final repeatedWhitespace = RegExp(r'  +').allMatches(text).length;

        // ignore: avoid_print
        print('''
=== ${file.path.split('/').last} ===
size:           ${(await file.length()) ~/ 1024} KB
processing:     ${stopwatch.elapsedMilliseconds} ms
pages:          ${doc.totalPages}
words:          ${doc.totalWords}
complexity:     ${doc.complexityScore.toStringAsFixed(1)} (${doc.complexityLevel})
char count:     ${text.length}
form-feed (\\f): $hasFormFeed
BOM:            $hasBom
hyphen-breaks:  $hyphenBreaks
CRLF count:     $crlfCount
3+ blanks:      $consecutiveBlanks
double-spaces:  $repeatedWhitespace

--- first 400 chars ---
${text.length > 400 ? text.substring(0, 400) : text}

--- last 300 chars ---
${text.length > 300 ? text.substring(text.length - 300) : text}
''');
      } on PdfProcessingException catch (e) {
        // ignore: avoid_print
        print('REJECTED ${file.path.split('/').last}: ${e.kind.name}');
      } catch (e, st) {
        // ignore: avoid_print
        print('FAILED for ${file.path.split('/').last}: $e\n$st');
        rethrow;
      }
    });
  }
}
