import '../datasources/reading_session_local_datasource.dart';
import '../models/reading_session_model.dart';
import '../../domain/entities/reading_session.dart';
import '../../domain/repositories/reading_session_repository.dart';

class ReadingSessionRepositoryImpl implements ReadingSessionRepository {
  final ReadingSessionLocalDataSource localDataSource;

  ReadingSessionRepositoryImpl(this.localDataSource);

  @override
  Future<ReadingSession> createSession({
    required String pdfId,
    required DateTime startTime,
    Map<String, dynamic>? settingsSnapshot,
  }) async {
    try {
      final sessionModel = ReadingSessionModel(
        pdfId: pdfId,
        startTime: startTime,
        settingsSnapshot: settingsSnapshot ?? {},
      );

      final createdId = await localDataSource.createSession(sessionModel);
      final createdSession = sessionModel.copyWith(id: createdId);

      return ReadingSession.fromModel(createdSession);
    } catch (e) {
      throw SessionRepositoryException('Failed to create session: $e');
    }
  }

  @override
  Future<void> updateSession(ReadingSession session) async {
    try {
      final sessionModel = session.toModel();
      await localDataSource.updateSession(sessionModel);
    } catch (e) {
      throw SessionRepositoryException('Failed to update session: $e');
    }
  }

  @override
  Future<ReadingSession> completeSession({
    required int sessionId,
    required DateTime endTime,
    required int wordsRead,
    required double averageSpeed,
  }) async {
    try {
      final existingSession = await localDataSource.getSessionById(sessionId);
      if (existingSession == null) {
        throw SessionRepositoryException('Session not found: $sessionId');
      }

      final completedSession = existingSession.copyWith(
        endTime: endTime,
        wordsRead: wordsRead,
        averageSpeed: averageSpeed,
      );

      await localDataSource.updateSession(completedSession);
      return ReadingSession.fromModel(completedSession);
    } catch (e) {
      throw SessionRepositoryException('Failed to complete session: $e');
    }
  }

  @override
  Future<ReadingSession?> getSessionById(int id) async {
    try {
      final sessionModel = await localDataSource.getSessionById(id);
      return sessionModel != null ? ReadingSession.fromModel(sessionModel) : null;
    } catch (e) {
      throw SessionRepositoryException('Failed to get session: $e');
    }
  }

  @override
  Future<List<ReadingSession>> getSessionsForPdf(String pdfId) async {
    try {
      final sessionModels = await localDataSource.getSessionsForPdf(pdfId);
      return sessionModels.map((model) => ReadingSession.fromModel(model)).toList();
    } catch (e) {
      throw SessionRepositoryException('Failed to get sessions for PDF: $e');
    }
  }

  @override
  Future<List<ReadingSession>> getSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final sessionModels = await localDataSource.getSessionsByDateRange(
        startDate,
        endDate,
      );
      return sessionModels.map((model) => ReadingSession.fromModel(model)).toList();
    } catch (e) {
      throw SessionRepositoryException('Failed to get sessions by date range: $e');
    }
  }

  @override
  Future<List<ReadingSession>> getRecentSessions({int limit = 20}) async {
    try {
      final sessionModels = await localDataSource.getRecentSessions(limit: limit);
      return sessionModels.map((model) => ReadingSession.fromModel(model)).toList();
    } catch (e) {
      throw SessionRepositoryException('Failed to get recent sessions: $e');
    }
  }

  @override
  Future<ReadingSession?> getActiveSession() async {
    try {
      final sessionModel = await localDataSource.getActiveSession();
      return sessionModel != null ? ReadingSession.fromModel(sessionModel) : null;
    } catch (e) {
      throw SessionRepositoryException('Failed to get active session: $e');
    }
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    try {
      await localDataSource.deleteSession(sessionId);
    } catch (e) {
      throw SessionRepositoryException('Failed to delete session: $e');
    }
  }

  @override
  Future<ReadingStats> getReadingStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sessions = await localDataSource.getSessionsByDateRange(
        startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        endDate ?? DateTime.now(),
      );

      final completedSessions = sessions.where((s) => s.endTime != null).toList();

      if (completedSessions.isEmpty) {
        return const ReadingStats(
          totalSessions: 0,
          totalWordsRead: 0,
          totalReadingTimeMinutes: 0.0,
          averageWordsPerMinute: 0.0,
          averageSessionDurationMinutes: 0.0,
          currentStreak: 0,
          longestStreak: 0,
          sessionsByDayOfWeek: {},
          sessionsByHour: {},
        );
      }

      final totalWords = completedSessions.fold<int>(0, (sum, session) => sum + session.wordsRead);
      final totalTime = completedSessions.fold<double>(
        0.0,
        (sum, session) => sum + (session.endTime!.difference(session.startTime).inMinutes).toDouble(),
      );
      final avgSpeed = completedSessions.isEmpty
          ? 0.0
          : completedSessions.map((s) => s.averageSpeed).reduce((a, b) => a + b) / completedSessions.length;
      final avgDuration = completedSessions.isEmpty
          ? 0.0
          : totalTime / completedSessions.length;

      // Calculate streak
      final streak = await _calculateReadingStreak(completedSessions);

      // Sessions by day of week and hour
      final sessionsByDayOfWeek = <String, int>{};
      final sessionsByHour = <int, int>{};

      for (final session in completedSessions) {
        final dayOfWeek = session.startTime.weekday.toString();
        final hour = session.startTime.hour;

        sessionsByDayOfWeek[dayOfWeek] = (sessionsByDayOfWeek[dayOfWeek] ?? 0) + 1;
        sessionsByHour[hour] = (sessionsByHour[hour] ?? 0) + 1;
      }

      return ReadingStats(
        totalSessions: completedSessions.length,
        totalWordsRead: totalWords,
        totalReadingTimeMinutes: totalTime,
        averageWordsPerMinute: avgSpeed,
        averageSessionDurationMinutes: avgDuration,
        currentStreak: streak.current,
        longestStreak: streak.longest,
        lastReadingDate: completedSessions.isNotEmpty
            ? completedSessions.map((s) => s.endTime!).reduce((a, b) => a.isAfter(b) ? a : b)
            : null,
        sessionsByDayOfWeek: sessionsByDayOfWeek,
        sessionsByHour: sessionsByHour,
      );
    } catch (e) {
      throw SessionRepositoryException('Failed to get reading stats: $e');
    }
  }

  @override
  Future<List<ReadingProgress>> getReadingProgress({
    required DateTime startDate,
    required DateTime endDate,
    ProgressInterval interval = ProgressInterval.daily,
  }) async {
    try {
      final sessions = await localDataSource.getSessionsByDateRange(startDate, endDate);
      final completedSessions = sessions.where((s) => s.endTime != null).toList();

      return _groupSessionsByInterval(completedSessions, interval);
    } catch (e) {
      throw SessionRepositoryException('Failed to get reading progress: $e');
    }
  }

  @override
  Future<ReadingStreak> getReadingStreak() async {
    try {
      final sessions = await localDataSource.getRecentSessions(limit: 100);
      final completedSessions = sessions.where((s) => s.endTime != null).toList();

      return _calculateReadingStreak(completedSessions);
    } catch (e) {
      throw SessionRepositoryException('Failed to get reading streak: $e');
    }
  }

  @override
  Future<List<ReadingGoal>> getReadingGoals() async {
    try {
      // This would be implemented with a separate goals data source
      // For now, return empty list
      return [];
    } catch (e) {
      throw SessionRepositoryException('Failed to get reading goals: $e');
    }
  }

  @override
  Future<void> updateReadingGoal(ReadingGoal goal) async {
    try {
      // This would be implemented with a separate goals data source
      // For now, just log the action
      print('Updating goal: ${goal.id}');
    } catch (e) {
      throw SessionRepositoryException('Failed to update reading goal: $e');
    }
  }

  Future<ReadingStreak> _calculateReadingStreak(List<ReadingSessionModel> sessions) async {
    if (sessions.isEmpty) {
      return const ReadingStreak(
        currentStreak: 0,
        longestStreak: 0,
        recentReadingDays: [],
      );
    }

    // Group sessions by date
    final readingDays = <DateTime>{};
    for (final session in sessions) {
      if (session.endTime != null) {
        final date = DateTime(
          session.endTime!.year,
          session.endTime!.month,
          session.endTime!.day,
        );
        readingDays.add(date);
      }
    }

    final sortedDates = readingDays.toList()..sort();
    
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Calculate current streak
    for (int i = sortedDates.length - 1; i >= 0; i--) {
      final date = sortedDates[i];
      final daysDiff = todayDate.difference(date).inDays;

      if (daysDiff == currentStreak) {
        currentStreak++;
      } else {
        break;
      }
    }

    // Calculate longest streak
    for (int i = 0; i < sortedDates.length; i++) {
      if (i == 0) {
        tempStreak = 1;
      } else {
        final daysDiff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
        if (daysDiff == 1) {
          tempStreak++;
        } else {
          longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
          tempStreak = 1;
        }
      }
    }
    longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;

    return ReadingStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      startDate: sortedDates.isNotEmpty ? sortedDates.first : null,
      endDate: sortedDates.isNotEmpty ? sortedDates.last : null,
      recentReadingDays: sortedDates,
    );
  }

  List<ReadingProgress> _groupSessionsByInterval(
    List<ReadingSessionModel> sessions,
    ProgressInterval interval,
  ) {
    final groupedData = <DateTime, List<ReadingSessionModel>>{};

    for (final session in sessions) {
      DateTime key;
      switch (interval) {
        case ProgressInterval.hourly:
          key = DateTime(
            session.startTime.year,
            session.startTime.month,
            session.startTime.day,
            session.startTime.hour,
          );
          break;
        case ProgressInterval.daily:
          key = DateTime(
            session.startTime.year,
            session.startTime.month,
            session.startTime.day,
          );
          break;
        case ProgressInterval.weekly:
          // Get start of week (Monday)
          final startOfWeek = session.startTime.subtract(
            Duration(days: session.startTime.weekday - 1),
          );
          key = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          break;
        case ProgressInterval.monthly:
          key = DateTime(session.startTime.year, session.startTime.month, 1);
          break;
      }

      groupedData.putIfAbsent(key, () => []).add(session);
    }

    final progressList = <ReadingProgress>[];
    for (final entry in groupedData.entries) {
      final date = entry.key;
      final daySessions = entry.value;
      final completedSessions = daySessions.where((s) => s.endTime != null).toList();

      if (completedSessions.isNotEmpty) {
        final totalWords = completedSessions.fold<int>(0, (sum, s) => sum + s.wordsRead);
        final totalTime = completedSessions.fold<double>(
          0.0,
          (sum, s) => sum + (s.endTime!.difference(s.startTime).inMinutes).toDouble(),
        );
        final avgSpeed = completedSessions.isEmpty
            ? 0.0
            : completedSessions.map((s) => s.averageSpeed).reduce((a, b) => a + b) / completedSessions.length;

        progressList.add(ReadingProgress(
          date: date,
          wordsRead: totalWords,
          readingTimeMinutes: totalTime,
          averageSpeed: avgSpeed,
          sessionCount: completedSessions.length,
        ));
      }
    }

    progressList.sort((a, b) => a.date.compareTo(b.date));
    return progressList;
  }
}

class SessionRepositoryException implements Exception {
  final String message;
  SessionRepositoryException(this.message);
  
  @override
  String toString() => 'SessionRepositoryException: $message';
}
