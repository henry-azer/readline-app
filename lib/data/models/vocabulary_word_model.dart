class VocabularyWordModel {
  final String id;
  final String word;
  final String? definition;
  final String contextSentence;
  final String sourceDocumentId;
  final String sourceDocumentTitle;
  final String masteryLevel;
  final DateTime addedAt;
  final DateTime? lastReviewedAt;
  final int reviewCount;
  final DateTime? nextReviewAt;
  final bool isAutoCollected;
  final bool isBookmarked;
  final String? usageNote;
  final String difficulty;
  final String? phonetic;
  final String? partOfSpeech;
  final String? exampleSentence;

  const VocabularyWordModel({
    required this.id,
    required this.word,
    this.definition,
    required this.contextSentence,
    required this.sourceDocumentId,
    required this.sourceDocumentTitle,
    this.masteryLevel = 'fresh',
    required this.addedAt,
    this.lastReviewedAt,
    this.reviewCount = 0,
    this.nextReviewAt,
    this.isAutoCollected = false,
    this.isBookmarked = false,
    this.usageNote,
    this.difficulty = 'medium',
    this.phonetic,
    this.partOfSpeech,
    this.exampleSentence,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'word': word,
    'definition': definition,
    'contextSentence': contextSentence,
    'sourceDocumentId': sourceDocumentId,
    'sourceDocumentTitle': sourceDocumentTitle,
    'masteryLevel': masteryLevel,
    'addedAt': addedAt.millisecondsSinceEpoch,
    'lastReviewedAt': lastReviewedAt?.millisecondsSinceEpoch,
    'reviewCount': reviewCount,
    'nextReviewAt': nextReviewAt?.millisecondsSinceEpoch,
    'isAutoCollected': isAutoCollected,
    'isBookmarked': isBookmarked,
    'usageNote': usageNote,
    'difficulty': difficulty,
    'phonetic': phonetic,
    'partOfSpeech': partOfSpeech,
    'exampleSentence': exampleSentence,
  };

  factory VocabularyWordModel.fromMap(Map<dynamic, dynamic> map) {
    return VocabularyWordModel(
      id: map['id'] as String? ?? '',
      word: map['word'] as String? ?? '',
      definition: map['definition'] as String?,
      contextSentence: map['contextSentence'] as String? ?? '',
      sourceDocumentId: map['sourceDocumentId'] as String? ?? '',
      sourceDocumentTitle: map['sourceDocumentTitle'] as String? ?? '',
      masteryLevel: map['masteryLevel'] as String? ?? 'fresh',
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] as int? ?? 0),
      lastReviewedAt: map['lastReviewedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReviewedAt'] as int)
          : null,
      reviewCount: map['reviewCount'] as int? ?? 0,
      nextReviewAt: map['nextReviewAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['nextReviewAt'] as int)
          : null,
      isAutoCollected: map['isAutoCollected'] as bool? ?? false,
      isBookmarked: map['isBookmarked'] as bool? ?? false,
      usageNote: map['usageNote'] as String?,
      difficulty: map['difficulty'] as String? ?? 'medium',
      phonetic: map['phonetic'] as String?,
      partOfSpeech: map['partOfSpeech'] as String?,
      exampleSentence: map['exampleSentence'] as String?,
    );
  }

  static const _sentinel = Object();

  VocabularyWordModel copyWith({
    String? definition,
    String? masteryLevel,
    Object? sourceDocumentId = _sentinel,
    DateTime? lastReviewedAt,
    int? reviewCount,
    DateTime? nextReviewAt,
    bool? isBookmarked,
    String? usageNote,
    String? difficulty,
    String? phonetic,
    String? partOfSpeech,
    String? exampleSentence,
  }) {
    return VocabularyWordModel(
      id: id,
      word: word,
      definition: definition ?? this.definition,
      contextSentence: contextSentence,
      sourceDocumentId: sourceDocumentId == _sentinel
          ? this.sourceDocumentId
          : (sourceDocumentId as String?) ?? '',
      sourceDocumentTitle: sourceDocumentTitle,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      addedAt: addedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      isAutoCollected: isAutoCollected,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      usageNote: usageNote ?? this.usageNote,
      difficulty: difficulty ?? this.difficulty,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      exampleSentence: exampleSentence ?? this.exampleSentence,
    );
  }
}
