import 'package:flutter_test/flutter_test.dart';
import 'package:readline_app/core/services/pdf_processing_service.dart';

void main() {
  group('PdfProcessingService.normalizeText', () {
    test('normalizes CRLF and CR line endings to LF', () {
      const input = 'line one\r\nline two\rline three';
      final out = PdfProcessingService.normalizeText(input);
      expect(out.contains('\r'), false);
      expect(out, contains('line one'));
      expect(out, contains('line three'));
    });

    test('strips UTF-8 BOM and zero-width characters', () {
      const input = '﻿Hello​ world‌';
      final out = PdfProcessingService.normalizeText(input);
      expect(out.startsWith('﻿'), false);
      expect(out.contains('​'), false);
      expect(out, 'Hello world');
    });

    test('repairs hyphenated words split across line breaks', () {
      const input = 'differ-\nence is impor-\ntant for read-\ners';
      final out = PdfProcessingService.normalizeText(input);
      expect(out, 'difference is important for readers');
    });

    test('reflows soft-wrapped lines into flowing prose', () {
      const input = 'The morning was\ncold and bright,\nand the gulls cried.';
      final out = PdfProcessingService.normalizeText(input);
      expect(out, 'The morning was cold and bright, and the gulls cried.');
    });

    test('preserves paragraph breaks (double newlines)', () {
      const input = 'First paragraph here.\n\nSecond paragraph here.';
      final out = PdfProcessingService.normalizeText(input);
      expect(out, contains('\n\n'));
      expect(out.split('\n\n').length, 2);
    });

    test('collapses 3+ consecutive blank lines to a single paragraph break', () {
      const input = 'Paragraph one.\n\n\n\n\nParagraph two.';
      final out = PdfProcessingService.normalizeText(input);
      expect(out, 'Paragraph one.\n\nParagraph two.');
    });

    test('converts form feed (page break) into a paragraph break', () {
      const input = 'page one body.\fpage two body.';
      final out = PdfProcessingService.normalizeText(input);
      expect(out.contains('\f'), false);
      expect(out, contains('\n\n'));
    });

    test('collapses runs of horizontal whitespace inside a line', () {
      const input = 'Word     with     huge      gaps';
      final out = PdfProcessingService.normalizeText(input);
      expect(out, 'Word with huge gaps');
    });

    test('handles realistic PDF-extracted snippet end-to-end', () {
      const input =
          '﻿The morn-\r\ning fog\r\n drift-\r\ned over the\r\nharbor.\f'
          'Distant gulls\r\ncalled out.';
      final out = PdfProcessingService.normalizeText(input);
      expect(out, contains('morning fog'));
      expect(out, contains('drifted'));
      expect(out, contains('\n\n'));
      expect(out.contains('\r'), false);
      expect(out.contains('\f'), false);
    });
  });

  group('PdfProcessingService.isExtractionUsable', () {
    test('rejects empty text', () {
      expect(PdfProcessingService.isExtractionUsable(''), false);
      expect(PdfProcessingService.isExtractionUsable('   \n\n  '), false);
    });

    test('rejects too-few words', () {
      expect(
        PdfProcessingService.isExtractionUsable('only a few short words here'),
        false,
      );
    });

    test('rejects glyph-garbage extraction (mostly mono-character tokens)', () {
      // The pattern observed in YELLOW BOOK_STEP INTO THE RIDE.pdf:
      // most tokens are repeated single uppercase letters, which is what
      // happens when a font lacks ToUnicode CMap entries.
      const garbage =
          'AAEPINAO AGAIA IAAIAAAAAA AAAAAAAAAA AAMA AAAAAMAAAAAIAM '
          'AABAAAIAMAAAAAMAMAAIAAAM AAMAA AAIAAAAAAAAIAAA AAAMAAA '
          'AAAMAAAAAAAAI AABAAIAAAA AAAAIA HAAAAMAAMAAAIA '
          'IAIAIAAAMAAIAIAAABAAI AAMAIAAAAAA AAAAMAAAAAAA IAA AAA '
          'AAAAAABAABAAAAAA AAAABAAMAAIAAAAAA IAAAMABAAAAAAAAAMAIA '
          'AAAAAMABI AAABAAAA AAIAA AAAMBAA IBAAG AA A';
      expect(PdfProcessingService.isExtractionUsable(garbage), false);
    });

    test('accepts plausible English prose', () {
      const prose =
          'The morning fog drifted slowly over the harbor as the fishermen '
          'hauled in their nets. A handful of gulls cried out above the bay '
          'while sailors rolled barrels along the pier. Despite the chill, '
          'children gathered to watch the boats arrive with their daily catch.';
      expect(PdfProcessingService.isExtractionUsable(prose), true);
    });

    test('accepts prose with some short tokens and numbers', () {
      const mixed =
          'In 2023, the global average temperature rose by 1.3 degrees Celsius '
          'above pre-industrial levels. Scientists warned that further warming '
          'could trigger more extreme weather events. The impact on coastal '
          'communities and food systems was already becoming evident.';
      expect(PdfProcessingService.isExtractionUsable(mixed), true);
    });
  });
}
