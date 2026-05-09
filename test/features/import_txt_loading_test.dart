import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:readline_app/core/services/pdf_processing_service.dart';
import 'package:readline_app/data/contracts/document_repository.dart';
import 'package:readline_app/data/datasources/local/hive_document_source.dart';
import 'package:readline_app/data/models/document_model.dart';
import 'package:readline_app/data/repositories/document_repository_impl.dart';
import 'package:readline_app/features/home/viewmodels/import_content_viewmodel.dart';

void main() {
  late Directory tempDir;
  late ImportContentViewModel vm;
  late DocumentRepository repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('txt_load_test');
    Hive.init(tempDir.path);
    repo = DocumentRepositoryImpl(HiveDocumentSource());
    vm = ImportContentViewModel(
      docRepo: repo,
      pdfService: PdfProcessingService(),
    );
  });

  tearDown(() async {
    vm.dispose();
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  Future<File> writeTempFile(String name, List<int> bytes) async {
    final file = File('${tempDir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<DocumentModel?> saveTxtFromFile(File file) async {
    vm.pickedFilePath$.add(file.path);
    vm.pickedFileName$.add(file.path.split('/').last);
    vm.pickedFileType$.add('txt');
    return vm.save(title: 'My Doc', text: '');
  }

  test('plain ASCII .txt loads successfully', () async {
    const text =
        'The morning fog drifted slowly over the harbor as the fishermen '
        'hauled in their nets and the gulls cried out above the bay.';
    final file = await writeTempFile('plain.txt', text.codeUnits);
    final doc = await saveTxtFromFile(file);
    expect(doc, isNotNull);
    expect(doc!.extractedText, contains('morning fog'));
    expect(doc.extractedText, contains('gulls'));
  });

  test('UTF-8 BOM is stripped from extracted text', () async {
    const text = 'Hello world. This is a passage with proper words to read.';
    final bytes = <int>[
      0xEF, 0xBB, 0xBF,
      ...text.codeUnits,
    ];
    final file = await writeTempFile('utf8bom.txt', bytes);
    final doc = await saveTxtFromFile(file);
    expect(doc, isNotNull);
    expect(doc!.extractedText.startsWith('Hello'), true);
    expect(doc.extractedText.contains('﻿'), false);
  });

  test('UTF-16 LE BOM .txt is decoded correctly', () async {
    const text =
        'Greetings from the lighthouse. The keeper rose before dawn '
        'to trim the wicks and prepare for another long night at sea.';
    final bytes = <int>[0xFF, 0xFE];
    for (final code in text.codeUnits) {
      bytes.add(code & 0xFF);
      bytes.add((code >> 8) & 0xFF);
    }
    final file = await writeTempFile('utf16le.txt', bytes);
    final doc = await saveTxtFromFile(file);
    expect(doc, isNotNull);
    expect(doc!.extractedText, contains('Greetings'));
    expect(doc.extractedText, contains('lighthouse'));
  });

  test('UTF-16 BE BOM .txt is decoded correctly', () async {
    const text = 'Big endian text encoding works for reading practice files.';
    final bytes = <int>[0xFE, 0xFF];
    for (final code in text.codeUnits) {
      bytes.add((code >> 8) & 0xFF);
      bytes.add(code & 0xFF);
    }
    final file = await writeTempFile('utf16be.txt', bytes);
    final doc = await saveTxtFromFile(file);
    expect(doc, isNotNull);
    expect(doc!.extractedText, contains('Big endian'));
    expect(doc.extractedText, contains('reading practice'));
  });

  test(
    'CRLF line endings get normalized so reading content flows as prose',
    () async {
      const text =
          'Line one is here.\r\nAnd line two follows it.\r\nThird line keeps going.';
      final file = await writeTempFile('crlf.txt', text.codeUnits);
      final doc = await saveTxtFromFile(file);
      expect(doc, isNotNull);
      expect(doc!.extractedText.contains('\r'), false);
      expect(doc.extractedText, contains('Line one is here'));
    },
  );

  test('empty / nearly empty .txt surfaces a processing error', () async {
    final emptyFile = await writeTempFile('empty.txt', Uint8List(0));
    final errorFuture = vm.processingError$.first;
    final doc = await saveTxtFromFile(emptyFile);
    expect(doc, isNull);
    final error = await errorFuture.timeout(const Duration(seconds: 2));
    expect(error, ImportProcessingError.txtUnreadable);
  });

  test(r'isProcessing$ resets to false after a successful save', () async {
    const text = 'A short readable passage with several common english words.';
    final file = await writeTempFile('reset.txt', text.codeUnits);
    final doc = await saveTxtFromFile(file);
    expect(doc, isNotNull);
    expect(vm.isProcessing$.value, false);
  });

  test(
    'isProcessing\$ resets to false after a save failure (typed error path)',
    () async {
      final emptyFile = await writeTempFile('also_empty.txt', Uint8List(0));
      await saveTxtFromFile(emptyFile);
      expect(vm.isProcessing$.value, false);
    },
  );
}
