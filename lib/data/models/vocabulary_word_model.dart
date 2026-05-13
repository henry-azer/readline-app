class VocabularyWordModel {
  final String id;
  final String word;
  final String? definition;
  final String contextSentence;
  final String sourceDocumentId;
  final String sourceDocumentTitle;
  final DateTime addedAt;
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
    required this.addedAt,
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
    'addedAt': addedAt.millisecondsSinceEpoch,
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
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] as int? ?? 0),
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
    Object? sourceDocumentId = _sentinel,
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
      addedAt: addedAt,
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
