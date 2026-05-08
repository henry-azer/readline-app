class WordDefinitionModel {
  final String word;
  final String? phonetic;
  final String partOfSpeech;
  final String definition;
  final String? exampleSentence;

  const WordDefinitionModel({
    required this.word,
    this.phonetic,
    required this.partOfSpeech,
    required this.definition,
    this.exampleSentence,
  });

  Map<String, dynamic> toMap() => {
    'word': word,
    'phonetic': phonetic,
    'partOfSpeech': partOfSpeech,
    'definition': definition,
    'exampleSentence': exampleSentence,
  };

  factory WordDefinitionModel.fromMap(Map<dynamic, dynamic> map) {
    return WordDefinitionModel(
      word: map['word'] as String? ?? '',
      phonetic: map['phonetic'] as String?,
      partOfSpeech: map['partOfSpeech'] as String? ?? '',
      definition: map['definition'] as String? ?? '',
      exampleSentence: map['exampleSentence'] as String?,
    );
  }

  WordDefinitionModel copyWith({
    String? word,
    String? phonetic,
    String? partOfSpeech,
    String? definition,
    String? exampleSentence,
  }) {
    return WordDefinitionModel(
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      definition: definition ?? this.definition,
      exampleSentence: exampleSentence ?? this.exampleSentence,
    );
  }
}
