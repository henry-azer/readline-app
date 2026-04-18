import '../datasources/pdf_local_datasource.dart';
import '../datasources/pdf_remote_datasource.dart';
import '../../core/services/pdf_processing_service.dart';
import '../../domain/entities/pdf_document.dart';
import '../../domain/repositories/pdf_repository.dart';

class PdfRepositoryImpl implements PdfRepository {
  final PdfLocalDataSource localDataSource;
  final PdfRemoteDataSource remoteDataSource;
  final PdfProcessingService pdfProcessingService;

  PdfRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.pdfProcessingService,
  });

  @override
  Future<PdfDocument> processPdf(String filePath) async {
    try {
      // Process the PDF file
      final processedDocument = await pdfProcessingService.processPdfFile(filePath);
      
      // Cache the processed document locally
      await localDataSource.cachePdfDocument(processedDocument);
      
      // Convert to domain entity
      return PdfDocument.fromModel(processedDocument);
    } catch (e) {
      throw PdfProcessingException('Failed to process PDF: $e');
    }
  }

  @override
  Future<List<PdfDocument>> getCachedDocuments() async {
    try {
      final models = await localDataSource.getCachedDocuments();
      return models.map((model) => PdfDocument.fromModel(model)).toList();
    } catch (e) {
      throw PdfCacheException('Failed to retrieve cached documents: $e');
    }
  }

  @override
  Future<PdfDocument?> getDocumentById(String id) async {
    try {
      final model = await localDataSource.getPdfDocument(id);
      return model != null ? PdfDocument.fromModel(model) : null;
    } catch (e) {
      throw PdfCacheException('Failed to retrieve document: $e');
    }
  }

  @override
  Future<String> extractFullText(String filePath) async {
    try {
      return await pdfProcessingService.extractFullText(filePath);
    } catch (e) {
      throw PdfProcessingException('Failed to extract text: $e');
    }
  }

  @override
  Future<List<String>> extractPages(String filePath) async {
    try {
      return await pdfProcessingService.extractPages(filePath);
    } catch (e) {
      throw PdfProcessingException('Failed to extract pages: $e');
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    try {
      await localDataSource.deletePdfDocument(id);
    } catch (e) {
      throw PdfCacheException('Failed to delete document: $e');
    }
  }

  @override
  Future<void> updateDocumentLastRead(String id) async {
    try {
      await localDataSource.updateDocumentLastRead(id);
    } catch (e) {
      throw PdfCacheException('Failed to update last read: $e');
    }
  }

  @override
  Future<List<PdfDocument>> searchDocuments(String query) async {
    try {
      final models = await localDataSource.searchDocuments(query);
      return models.map((model) => PdfDocument.fromModel(model)).toList();
    } catch (e) {
      throw PdfCacheException('Failed to search documents: $e');
    }
  }
}

class PdfProcessingException implements Exception {
  final String message;
  PdfProcessingException(this.message);
  
  @override
  String toString() => 'PdfProcessingException: $message';
}

class PdfCacheException implements Exception {
  final String message;
  PdfCacheException(this.message);
  
  @override
  String toString() => 'PdfCacheException: $message';
}
