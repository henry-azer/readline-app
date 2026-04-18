class PdfDocumentModel {
  final String id;
  final String title;
  final String filePath;
  final int pageCount;
  final int wordCount;
  final DateTime createdAt;
  final DateTime? lastRead;

  const PdfDocumentModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.pageCount,
    required this.wordCount,
    required this.createdAt,
    this.lastRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'page_count': pageCount,
      'word_count': wordCount,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_read': lastRead?.millisecondsSinceEpoch,
    };
  }

  factory PdfDocumentModel.fromMap(Map<String, dynamic> map) {
    return PdfDocumentModel(
      id: map['id'] as String,
      title: map['title'] as String,
      filePath: map['file_path'] as String,
      pageCount: map['page_count'] as int,
      wordCount: map['word_count'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      lastRead: map['last_read'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_read'] as int)
          : null,
    );
  }

  PdfDocumentModel copyWith({
    String? id,
    String? title,
    String? filePath,
    int? pageCount,
    int? wordCount,
    DateTime? createdAt,
    DateTime? lastRead,
  }) {
    return PdfDocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      lastRead: lastRead ?? this.lastRead,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PdfDocumentModel &&
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
}
