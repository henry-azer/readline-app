import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../models/pdf_document_model.dart';

abstract class PdfLocalDataSource {
  Future<void> cachePdfDocument(PdfDocumentModel document);
  Future<List<PdfDocumentModel>> getCachedDocuments();
  Future<PdfDocumentModel?> getPdfDocument(String id);
  Future<void> deletePdfDocument(String id);
  Future<void> updateDocumentLastRead(String id);
  Future<List<PdfDocumentModel>> searchDocuments(String query);
  Future<void> clearCache();
}

class PdfLocalDataSourceImpl implements PdfLocalDataSource {
  final Database database;

  PdfLocalDataSourceImpl(this.database);

  @override
  Future<void> cachePdfDocument(PdfDocumentModel document) async {
    try {
      await database.insert(
        'pdf_documents',
        document.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to cache PDF document: $e');
    }
  }

  @override
  Future<List<PdfDocumentModel>> getCachedDocuments() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'pdf_documents',
        orderBy: 'last_read DESC, created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return PdfDocumentModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to retrieve cached documents: $e');
    }
  }

  @override
  Future<PdfDocumentModel?> getPdfDocument(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'pdf_documents',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return PdfDocumentModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to retrieve PDF document: $e');
    }
  }

  @override
  Future<void> deletePdfDocument(String id) async {
    try {
      final count = await database.delete(
        'pdf_documents',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw Exception('No document found with id: $id');
      }
    } catch (e) {
      throw Exception('Failed to delete PDF document: $e');
    }
  }

  @override
  Future<void> updateDocumentLastRead(String id) async {
    try {
      final count = await database.update(
        'pdf_documents',
        {'last_read': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw Exception('No document found with id: $id');
      }
    } catch (e) {
      throw Exception('Failed to update last read time: $e');
    }
  }

  @override
  Future<List<PdfDocumentModel>> searchDocuments(String query) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'pdf_documents',
        where: 'title LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'last_read DESC, created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return PdfDocumentModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to search documents: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await database.delete('pdf_documents');
    } catch (e) {
      throw Exception('Failed to clear PDF cache: $e');
    }
  }

  Future<bool> isDocumentCached(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'pdf_documents',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if document is cached: $e');
    }
  }

  Future<int> getCachedDocumentsCount() async {
    try {
      final result = await database.rawQuery('SELECT COUNT(*) as count FROM pdf_documents');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get cached documents count: $e');
    }
  }

  Future<List<PdfDocumentModel>> getRecentlyReadDocuments({int limit = 10}) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'pdf_documents',
        where: 'last_read IS NOT NULL',
        orderBy: 'last_read DESC',
        limit: limit,
      );

      return List.generate(maps.length, (i) {
        return PdfDocumentModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to retrieve recently read documents: $e');
    }
  }
}
