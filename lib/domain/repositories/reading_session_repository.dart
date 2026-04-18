import '../entities/reading_session.dart';

abstract class ReadingSessionRepository {
  /// Create a new reading session
  Future<ReadingSession> createSession({
    required String pdfId,
    required DateTime startTime,
    Map<String, dynamic>? settingsSnapshot,
  });

  /// Update an existing reading session
  Future<void> updateSession(ReadingSession session);

  /// Complete a reading session
  Future<ReadingSession> completeSession({
    required int sessionId,
    required DateTime endTime,
    required int wordsRead,
    required double averageSpeed,
  });

  /// Get a specific reading session by ID
  Future<ReadingSession?> getSessionById(int id);

  /// Get all reading sessions for a specific PDF
  Future<List<ReadingSession>> getSessionsForPdf(String pdfId);

  /// Get all reading sessions within a date range
  Future<List<ReadingSession>> getSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get recent reading sessions
  Future<List<ReadingSession>> getRecentSessions({int limit = 20});

  /// Get active reading session (if any)
  Future<ReadingSession?> getActiveSession();

  /// Delete a reading session
  Future<void> deleteSession(int sessionId);

  /// Get reading statistics
  Future<ReadingStats> getReadingStats({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get reading progress over time
  Future<List<ReadingProgress>> getReadingProgress({
    required DateTime startDate,
    required DateTime endDate,
    ProgressInterval interval = ProgressInterval.daily,
  });

  /// Get reading streak information
  Future<ReadingStreak> getReadingStreak();

  /// Get reading goals progress
  Future<List<ReadingGoal>> getReadingGoals();

  /// Update reading goal
  Future<void> updateReadingGoal(ReadingGoal goal);
}

class ReadingStats {
  final int totalSessions;
  final int totalWordsRead;
  final double totalReadingTimeMinutes;
  final double averageWordsPerMinute;
  final double averageSessionDurationMinutes;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadingDate;
  final Map<String, int> sessionsByDayOfWeek;
  final Map<int, int> sessionsByHour;

  const ReadingStats({
    required this.totalSessions,
    required this.totalWordsRead,
    required this.totalReadingTimeMinutes,
    required this.averageWordsPerMinute,
    required this.averageSessionDurationMinutes,
    required this.currentStreak,
    required this.longestStreak,
    this.lastReadingDate,
    required this.sessionsByDayOfWeek,
    required this.sessionsByHour,
  });

  Duration get totalReadingTime => Duration(minutes: totalReadingTimeMinutes.round());
  Duration get averageSessionDuration => Duration(minutes: averageSessionDurationMinutes.round());

  @override
  String toString() {
    return 'ReadingStats(sessions: $totalSessions, words: $totalWordsRead, avgSpeed: $averageWordsPerMinute WPM)';
  }
}

class ReadingProgress {
  final DateTime date;
  final int wordsRead;
  final double readingTimeMinutes;
  final double averageSpeed;
  final int sessionCount;

  const ReadingProgress({
    required this.date,
    required this.wordsRead,
    required this.readingTimeMinutes,
    required this.averageSpeed,
    required this.sessionCount,
  });

  @override
  String toString() {
    return 'ReadingProgress(date: $date, words: $wordsRead, sessions: $sessionCount)';
  }
}

enum ProgressInterval {
  hourly,
  daily,
  weekly,
  monthly,
}

class ReadingStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<DateTime> recentReadingDays;

  const ReadingStreak({
    required this.currentStreak,
    required this.longestStreak,
    this.startDate,
    this.endDate,
    required this.recentReadingDays,
  });

  bool get isActive => currentStreak > 0;
  Duration? get streakDuration {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!);
  }

  @override
  String toString() {
    return 'ReadingStreak(current: $currentStreak, longest: $longestStreak)';
  }
}

class ReadingGoal {
  final String id;
  final String title;
  final String description;
  final ReadingGoalType type;
  final double target;
  final double current;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final DateTime? completedDate;

  const ReadingGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.current,
    required this.startDate,
    required this.endDate,
    required this.isCompleted,
    this.completedDate,
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
  bool get isExpired => DateTime.now().isAfter(endDate);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  @override
  String toString() {
    return 'ReadingGoal(id: $id, title: $title, progress: ${(progress * 100).toStringAsFixed(1)}%)';
  }
}

enum ReadingGoalType {
  wordsPerDay,
  minutesPerDay,
  wordsPerWeek,
  sessionsPerWeek,
  speedTarget,
  streakTarget,
}

extension ReadingGoalTypeExtension on ReadingGoalType {
  String get displayName {
    switch (this) {
      case ReadingGoalType.wordsPerDay:
        return 'Words per Day';
      case ReadingGoalType.minutesPerDay:
        return 'Minutes per Day';
      case ReadingGoalType.wordsPerWeek:
        return 'Words per Week';
      case ReadingGoalType.sessionsPerWeek:
        return 'Sessions per Week';
      case ReadingGoalType.speedTarget:
        return 'Speed Target';
      case ReadingGoalType.streakTarget:
        return 'Reading Streak';
    }
  }

  String get unit {
    switch (this) {
      case ReadingGoalType.wordsPerDay:
      case ReadingGoalType.wordsPerWeek:
        return 'words';
      case ReadingGoalType.minutesPerDay:
        return 'minutes';
      case ReadingGoalType.sessionsPerWeek:
        return 'sessions';
      case ReadingGoalType.speedTarget:
        return 'WPM';
      case ReadingGoalType.streakTarget:
        return 'days';
    }
  }
}
