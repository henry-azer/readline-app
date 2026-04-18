class ReadingSessionModel {
  final int? id;
  final String pdfId;
  final DateTime startTime;
  final DateTime? endTime;
  final int wordsRead;
  final double averageSpeed;
  final Map<String, dynamic> settingsSnapshot;

  const ReadingSessionModel({
    this.id,
    required this.pdfId,
    required this.startTime,
    this.endTime,
    this.wordsRead = 0,
    this.averageSpeed = 0.0,
    this.settingsSnapshot = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pdf_id': pdfId,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'words_read': wordsRead,
      'average_speed': averageSpeed,
      'settings_snapshot': settingsSnapshot.toString(),
    };
  }

  factory ReadingSessionModel.fromMap(Map<String, dynamic> map) {
    return ReadingSessionModel(
      id: map['id'] as int?,
      pdfId: map['pdf_id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: map['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int)
          : null,
      wordsRead: map['words_read'] as int,
      averageSpeed: (map['average_speed'] as num).toDouble(),
      settingsSnapshot: map['settings_snapshot'] != null
          ? Map<String, dynamic>.from(map['settings_snapshot'])
          : {},
    );
  }

  ReadingSessionModel copyWith({
    int? id,
    String? pdfId,
    DateTime? startTime,
    DateTime? endTime,
    int? wordsRead,
    double? averageSpeed,
    Map<String, dynamic>? settingsSnapshot,
  }) {
    return ReadingSessionModel(
      id: id ?? this.id,
      pdfId: pdfId ?? this.pdfId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      wordsRead: wordsRead ?? this.wordsRead,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      settingsSnapshot: settingsSnapshot ?? this.settingsSnapshot,
    );
  }

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  bool get isActive => endTime == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingSessionModel &&
        other.id == id &&
        other.pdfId == pdfId &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.wordsRead == wordsRead &&
        other.averageSpeed == averageSpeed;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        pdfId.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        wordsRead.hashCode ^
        averageSpeed.hashCode;
  }
}
