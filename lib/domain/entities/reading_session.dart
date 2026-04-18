import '../../data/models/reading_session_model.dart';

class ReadingSession {
  final int? id;
  final String pdfId;
  final DateTime startTime;
  final DateTime? endTime;
  final int wordsRead;
  final double averageSpeed;
  final Map<String, dynamic> settingsSnapshot;

  const ReadingSession({
    this.id,
    required this.pdfId,
    required this.startTime,
    this.endTime,
    this.wordsRead = 0,
    this.averageSpeed = 0.0,
    this.settingsSnapshot = const {},
  });

  // Factory constructor to create from model
  factory ReadingSession.fromModel(ReadingSessionModel model) {
    return ReadingSession(
      id: model.id,
      pdfId: model.pdfId,
      startTime: model.startTime,
      endTime: model.endTime,
      wordsRead: model.wordsRead,
      averageSpeed: model.averageSpeed,
      settingsSnapshot: model.settingsSnapshot,
    );
  }

  // Convert to model for data layer
  ReadingSessionModel toModel() {
    return ReadingSessionModel(
      id: id,
      pdfId: pdfId,
      startTime: startTime,
      endTime: endTime,
      wordsRead: wordsRead,
      averageSpeed: averageSpeed,
      settingsSnapshot: settingsSnapshot,
    );
  }

  // Computed properties
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  bool get isActive => endTime == null;
  bool get isCompleted => endTime != null;

  double get progressPercentage {
    if (wordsRead == 0) return 0.0;
    // This would need total words from the PDF document
    // For now, return a placeholder calculation
    return (wordsRead / 1000).clamp(0.0, 1.0);
  }

  ReadingEfficiency get efficiency {
    if (duration == null || duration!.inMinutes == 0) {
      return ReadingEfficiency.unknown;
    }

    final actualSpeed = wordsRead / duration!.inMinutes;
    final efficiencyRatio = actualSpeed / averageSpeed;

    if (efficiencyRatio >= 1.2) return ReadingEfficiency.excellent;
    if (efficiencyRatio >= 1.0) return ReadingEfficiency.good;
    if (efficiencyRatio >= 0.8) return ReadingEfficiency.fair;
    return ReadingEfficiency.poor;
  }

  SessionQuality get quality {
    if (!isCompleted) return SessionQuality.inProgress;
    
    // Quality based on multiple factors
    double score = 0.0;
    
    // Speed consistency (40% weight)
    if (averageSpeed >= 150 && averageSpeed <= 350) {
      score += 0.4;
    } else if (averageSpeed >= 100 && averageSpeed <= 400) {
      score += 0.2;
    }
    
    // Duration (30% weight) - ideal is 15-60 minutes
    if (duration != null) {
      final minutes = duration!.inMinutes;
      if (minutes >= 15 && minutes <= 60) {
        score += 0.3;
      } else if (minutes >= 5 && minutes <= 120) {
        score += 0.15;
      }
    }
    
    // Words read (30% weight)
    if (wordsRead >= 500) {
      score += 0.3;
    } else if (wordsRead >= 200) {
      score += 0.15;
    }
    
    if (score >= 0.8) return SessionQuality.excellent;
    if (score >= 0.6) return SessionQuality.good;
    if (score >= 0.4) return SessionQuality.fair;
    return SessionQuality.poor;
  }

  String get formattedDuration {
    if (duration == null) return 'In progress';
    
    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get formattedSpeed {
    return '${averageSpeed.round()} WPM';
  }

  String get formattedWordsRead {
    if (wordsRead < 1000) return wordsRead.toString();
    if (wordsRead < 1000000) return '${(wordsRead / 1000).toStringAsFixed(1)}K';
    return '${(wordsRead / 1000000).toStringAsFixed(1)}M';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingSession &&
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

  @override
  String toString() {
    return 'ReadingSession(id: $id, pdfId: $pdfId, words: $wordsRead, speed: $averageSpeed WPM)';
  }
}

enum ReadingEfficiency {
  unknown,
  poor,
  fair,
  good,
  excellent,
}

extension ReadingEfficiencyExtension on ReadingEfficiency {
  String get displayName {
    switch (this) {
      case ReadingEfficiency.unknown:
        return 'Unknown';
      case ReadingEfficiency.poor:
        return 'Poor';
      case ReadingEfficiency.fair:
        return 'Fair';
      case ReadingEfficiency.good:
        return 'Good';
      case ReadingEfficiency.excellent:
        return 'Excellent';
    }
  }

  Color get color {
    switch (this) {
      case ReadingEfficiency.unknown:
        return Colors.grey;
      case ReadingEfficiency.poor:
        return Colors.red;
      case ReadingEfficiency.fair:
        return Colors.orange;
      case ReadingEfficiency.good:
        return Colors.lightBlue;
      case ReadingEfficiency.excellent:
        return Colors.green;
    }
  }
}

enum SessionQuality {
  inProgress,
  poor,
  fair,
  good,
  excellent,
}

extension SessionQualityExtension on SessionQuality {
  String get displayName {
    switch (this) {
      case SessionQuality.inProgress:
        return 'In Progress';
      case SessionQuality.poor:
        return 'Poor';
      case SessionQuality.fair:
        return 'Fair';
      case SessionQuality.good:
        return 'Good';
      case SessionQuality.excellent:
        return 'Excellent';
    }
  }

  Color get color {
    switch (this) {
      case SessionQuality.inProgress:
        return Colors.blue;
      case SessionQuality.poor:
        return Colors.red;
      case SessionQuality.fair:
        return Colors.orange;
      case SessionQuality.good:
        return Colors.lightBlue;
      case SessionQuality.excellent:
        return Colors.green;
    }
  }
}
