import '../../data/models/pdf_document_model.dart';

class PdfDocument {
  final String id;
  final String title;
  final String filePath;
  final int pageCount;
  final int wordCount;
  final DateTime createdAt;
  final DateTime? lastRead;

  const PdfDocument({
    required this.id,
    required this.title,
    required this.filePath,
    required this.pageCount,
    required this.wordCount,
    required this.createdAt,
    this.lastRead,
  });

  // Factory constructor to create from model
  factory PdfDocument.fromModel(PdfDocumentModel model) {
    return PdfDocument(
      id: model.id,
      title: model.title,
      filePath: model.filePath,
      pageCount: model.pageCount,
      wordCount: model.wordCount,
      createdAt: model.createdAt,
      lastRead: model.lastRead,
    );
  }

  // Convert to model for data layer
  PdfDocumentModel toModel() {
    return PdfDocumentModel(
      id: id,
      title: title,
      filePath: filePath,
      pageCount: pageCount,
      wordCount: wordCount,
      createdAt: createdAt,
      lastRead: lastRead,
    );
  }

  // Getters for computed properties
  Duration get timeSinceCreated => DateTime.now().difference(createdAt);
  
  Duration? get timeSinceLastRead => 
      lastRead != null ? DateTime.now().difference(lastRead!) : null;
  
  bool get isRecentlyRead {
    if (lastRead == null) return false;
    return timeSinceLastRead!.inDays < 7;
  }

  String get formattedWordCount {
    if (wordCount < 1000) return wordCount.toString();
    if (wordCount < 1000000) return '${(wordCount / 1000).toStringAsFixed(1)}K';
    return '${(wordCount / 1000000).toStringAsFixed(1)}M';
  }

  String get formattedPageCount {
    return pageCount.toString();
  }

  // Estimated reading time based on average reading speed
  Duration estimatedReadingTime({double wordsPerMinute = 200}) {
    final minutes = wordCount / wordsPerMinute;
    return Duration(minutes: minutes.round());
  }

  // Document complexity based on word count and page count
  DocumentComplexity get complexity {
    final avgWordsPerPage = wordCount / pageCount;
    
    if (avgWordsPerPage < 100) return DocumentComplexity.simple;
    if (avgWordsPerPage < 300) return DocumentComplexity.moderate;
    if (avgWordsPerPage < 500) return DocumentComplexity.complex;
    return DocumentComplexity.veryComplex;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PdfDocument &&
        other.id == id &&
        other.title == title &&
        other.filePath == filePath &&
        other.pageCount == pageCount &&
        other.wordCount == wordCount &&
        other.createdAt == createdAt &&
        other.lastRead == lastRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        filePath.hashCode ^
        pageCount.hashCode ^
        wordCount.hashCode ^
        createdAt.hashCode ^
        lastRead.hashCode;
  }

  @override
  String toString() {
    return 'PdfDocument(id: $id, title: $title, pages: $pageCount, words: $wordCount)';
  }
}

enum DocumentComplexity {
  simple,
  moderate,
  complex,
  veryComplex,
}

extension DocumentComplexityExtension on DocumentComplexity {
  String get displayName {
    switch (this) {
      case DocumentComplexity.simple:
        return 'Simple';
      case DocumentComplexity.moderate:
        return 'Moderate';
      case DocumentComplexity.complex:
        return 'Complex';
      case DocumentComplexity.veryComplex:
        return 'Very Complex';
    }
  }

  String get description {
    switch (this) {
      case DocumentComplexity.simple:
        return 'Easy to read, basic content';
      case DocumentComplexity.moderate:
        return 'Standard reading difficulty';
      case DocumentComplexity.complex:
        return 'Challenging content';
      case DocumentComplexity.veryComplex:
        return 'Very difficult, technical content';
    }
  }
}
