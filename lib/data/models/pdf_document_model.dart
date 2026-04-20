class PdfDocumentModel {
  final String id;
  final String title;
  final String filePath;
  final String fileName;
  final int totalPages;
  final int currentPage;
  final int totalWords;
  final int wordsRead;
  final double complexityScore;
  final String complexityLevel;
  final String extractedText;
  final String readingStatus;
  final DateTime importedAt;
  final DateTime? lastReadAt;
  final String? thumbnailPath;

  const PdfDocumentModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileName,
    this.totalPages = 0,
    this.currentPage = 0,
    this.totalWords = 0,
    this.wordsRead = 0,
    this.complexityScore = 0.0,
    this.complexityLevel = 'beginner',
    this.extractedText = '',
    this.readingStatus = 'unread',
    required this.importedAt,
    this.lastReadAt,
    this.thumbnailPath,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'filePath': filePath,
    'fileName': fileName,
    'totalPages': totalPages,
    'currentPage': currentPage,
    'totalWords': totalWords,
    'wordsRead': wordsRead,
    'complexityScore': complexityScore,
    'complexityLevel': complexityLevel,
    'extractedText': extractedText,
    'readingStatus': readingStatus,
    'importedAt': importedAt.millisecondsSinceEpoch,
    'lastReadAt': lastReadAt?.millisecondsSinceEpoch,
    'thumbnailPath': thumbnailPath,
  };

  factory PdfDocumentModel.fromMap(Map<dynamic, dynamic> map) {
    return PdfDocumentModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      filePath: map['filePath'] as String? ?? '',
      fileName: map['fileName'] as String? ?? '',
      totalPages: map['totalPages'] as int? ?? 0,
      currentPage: map['currentPage'] as int? ?? 0,
      totalWords: map['totalWords'] as int? ?? 0,
      wordsRead: map['wordsRead'] as int? ?? 0,
      complexityScore: (map['complexityScore'] as num?)?.toDouble() ?? 0.0,
      complexityLevel: map['complexityLevel'] as String? ?? 'beginner',
      extractedText: map['extractedText'] as String? ?? '',
      readingStatus: map['readingStatus'] as String? ?? 'unread',
      importedAt: DateTime.fromMillisecondsSinceEpoch(
        map['importedAt'] as int? ?? 0,
      ),
      lastReadAt: map['lastReadAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReadAt'] as int)
          : null,
      thumbnailPath: map['thumbnailPath'] as String?,
    );
  }

  PdfDocumentModel copyWith({
    String? title,
    int? currentPage,
    int? wordsRead,
    String? readingStatus,
    DateTime? lastReadAt,
    String? extractedText,
    int? totalPages,
    int? totalWords,
    double? complexityScore,
    String? complexityLevel,
    String? thumbnailPath,
  }) {
    return PdfDocumentModel(
      id: id,
      title: title ?? this.title,
      filePath: filePath,
      fileName: fileName,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      totalWords: totalWords ?? this.totalWords,
      wordsRead: wordsRead ?? this.wordsRead,
      complexityScore: complexityScore ?? this.complexityScore,
      complexityLevel: complexityLevel ?? this.complexityLevel,
      extractedText: extractedText ?? this.extractedText,
      readingStatus: readingStatus ?? this.readingStatus,
      importedAt: importedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
