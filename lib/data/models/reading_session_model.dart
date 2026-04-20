class ReadingSessionModel {
  final String id;
  final String documentId;
  final String documentTitle;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double durationMinutes;
  final int wordsRead;
  final int averageWpm;
  final int startPage;
  final int endPage;
  final double focusScore;
  final int wordsCollected;
  final String performanceLabel;

  const ReadingSessionModel({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes = 0,
    this.wordsRead = 0,
    this.averageWpm = 0,
    this.startPage = 0,
    this.endPage = 0,
    this.focusScore = 0,
    this.wordsCollected = 0,
    this.performanceLabel = 'warming up',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'documentId': documentId,
    'documentTitle': documentTitle,
    'startedAt': startedAt.millisecondsSinceEpoch,
    'endedAt': endedAt?.millisecondsSinceEpoch,
    'durationMinutes': durationMinutes,
    'wordsRead': wordsRead,
    'averageWpm': averageWpm,
    'startPage': startPage,
    'endPage': endPage,
    'focusScore': focusScore,
    'wordsCollected': wordsCollected,
    'performanceLabel': performanceLabel,
  };

  factory ReadingSessionModel.fromMap(Map<dynamic, dynamic> map) {
    return ReadingSessionModel(
      id: map['id'] as String? ?? '',
      documentId: map['documentId'] as String? ?? '',
      documentTitle: map['documentTitle'] as String? ?? '',
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        map['startedAt'] as int? ?? 0,
      ),
      endedAt: map['endedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endedAt'] as int)
          : null,
      durationMinutes: (map['durationMinutes'] as num?)?.toDouble() ?? 0,
      wordsRead: map['wordsRead'] as int? ?? 0,
      averageWpm: map['averageWpm'] as int? ?? 0,
      startPage: map['startPage'] as int? ?? 0,
      endPage: map['endPage'] as int? ?? 0,
      focusScore: (map['focusScore'] as num?)?.toDouble() ?? 0,
      wordsCollected: map['wordsCollected'] as int? ?? 0,
      performanceLabel: map['performanceLabel'] as String? ?? 'warming up',
    );
  }

  ReadingSessionModel copyWith({
    DateTime? endedAt,
    double? durationMinutes,
    int? wordsRead,
    int? averageWpm,
    int? endPage,
    double? focusScore,
    int? wordsCollected,
    String? performanceLabel,
  }) {
    return ReadingSessionModel(
      id: id,
      documentId: documentId,
      documentTitle: documentTitle,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      wordsRead: wordsRead ?? this.wordsRead,
      averageWpm: averageWpm ?? this.averageWpm,
      startPage: startPage,
      endPage: endPage ?? this.endPage,
      focusScore: focusScore ?? this.focusScore,
      wordsCollected: wordsCollected ?? this.wordsCollected,
      performanceLabel: performanceLabel ?? this.performanceLabel,
    );
  }
}
