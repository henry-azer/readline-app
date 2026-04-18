import '../entities/pdf_document.dart';

abstract class PdfRepository {
  /// Process a PDF file and return the processed document
  Future<PdfDocument> processPdf(String filePath);
  
  /// Get all cached PDF documents
  Future<List<PdfDocument>> getCachedDocuments();
  
  /// Get a specific PDF document by ID
  Future<PdfDocument?> getDocumentById(String id);
  
  /// Extract full text content from a PDF file
  Future<String> extractFullText(String filePath);
  
  /// Extract individual pages from a PDF file
  Future<List<String>> extractPages(String filePath);
  
  /// Delete a PDF document from cache
  Future<void> deleteDocument(String id);
  
  /// Update the last read time for a document
  Future<void> updateDocumentLastRead(String id);
  
  /// Search documents by title or content
  Future<List<PdfDocument>> searchDocuments(String query);
  
  /// Get recently read documents
  Future<List<PdfDocument>> getRecentlyReadDocuments({int limit = 10});
  
  /// Check if a document is cached
  Future<bool> isDocumentCached(String id);
  
  /// Clear all cached documents
  Future<void> clearCache();
  
  /// Get document statistics
  Future<DocumentStats> getDocumentStats();
}

class DocumentStats {
  final int totalDocuments;
  final int totalWords;
  final int totalPages;
  final int recentlyReadCount;
  final DateTime? lastReadTime;

  const DocumentStats({
    required this.totalDocuments,
    required this.totalWords,
    required this.totalPages,
    required this.recentlyReadCount,
    this.lastReadTime,
  });

  @override
  String toString() {
    return 'DocumentStats(documents: $totalDocuments, words: $totalWords, pages: $totalPages)';
  }
}
