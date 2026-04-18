import 'package:sqflite/sqflite.dart';
import '../models/reading_session_model.dart';

abstract class AnalyticsLocalDataSource {
  Future<int> createSession(ReadingSessionModel session);
  Future<void> updateSession(ReadingSessionModel session);
  Future<ReadingSessionModel?> getSessionById(int id);
  Future<List<ReadingSessionModel>> getSessionsForPdf(String pdfId);
  Future<List<ReadingSessionModel>> getSessionsByDateRange(DateTime startDate, DateTime endDate);
  Future<List<ReadingSessionModel>> getRecentSessions({int limit = 20});
  Future<ReadingSessionModel?> getActiveSession();
  Future<void> deleteSession(int id);
  Future<void> clearAllSessions();
}

class AnalyticsLocalDataSourceImpl implements AnalyticsLocalDataSource {
  final Database database;

  AnalyticsLocalDataSourceImpl(this.database);

  @override
  Future<int> createSession(ReadingSessionModel session) async {
    try {
      final id = await database.insert(
        'reading_sessions',
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      throw Exception('Failed to create reading session: $e');
    }
  }

  @override
  Future<void> updateSession(ReadingSessionModel session) async {
    try {
      if (session.id == null) {
        throw Exception('Cannot update session without ID');
      }

      final count = await database.update(
        'reading_sessions',
        session.toMap(),
        where: 'id = ?',
        whereArgs: [session.id],
      );

      if (count == 0) {
        throw Exception('No session found with ID: ${session.id}');
      }
    } catch (e) {
      throw Exception('Failed to update reading session: $e');
    }
  }

  @override
  Future<ReadingSessionModel?> getSessionById(int id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'reading_sessions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return ReadingSessionModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get session by ID: $e');
    }
  }

  @override
  Future<List<ReadingSessionModel>> getSessionsForPdf(String pdfId) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'reading_sessions',
        where: 'pdf_id = ?',
        whereArgs: [pdfId],
        orderBy: 'start_time DESC',
      );

      return List.generate(maps.length, (i) {
        return ReadingSessionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get sessions for PDF: $e');
    }
  }

  @override
  Future<List<ReadingSessionModel>> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startMillis = startDate.millisecondsSinceEpoch;
      final endMillis = endDate.millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await database.query(
        'reading_sessions',
        where: 'start_time >= ? AND start_time <= ?',
        whereArgs: [startMillis, endMillis],
        orderBy: 'start_time DESC',
      );

      return List.generate(maps.length, (i) {
        return ReadingSessionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get sessions by date range: $e');
    }
  }

  @override
  Future<List<ReadingSessionModel>> getRecentSessions({int limit = 20}) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'reading_sessions',
        orderBy: 'start_time DESC',
        limit: limit,
      );

      return List.generate(maps.length, (i) {
        return ReadingSessionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get recent sessions: $e');
    }
  }

  @override
  Future<ReadingSessionModel?> getActiveSession() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'reading_sessions',
        where: 'end_time IS NULL',
        orderBy: 'start_time DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return ReadingSessionModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get active session: $e');
    }
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    try {
      final count = await database.delete(
        'reading_sessions',
        where: 'id = ?',
        whereArgs: [sessionId],
      );

      if (count == 0) {
        throw Exception('No session found with ID: $sessionId');
      }
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  @override
  Future<void> clearAllSessions() async {
    try {
      await database.delete('reading_sessions');
    } catch (e) {
      throw Exception('Failed to clear all sessions: $e');
    }
  }

  // Analytics-specific helper methods
  Future<Map<String, dynamic>> getReadingSummary() async {
    try {
      final totalSessions = await getTotalSessionsCount();
      final completedSessions = await getCompletedSessionsCount();
      final totalWords = await getTotalWordsRead();
      final avgSpeed = await getAverageReadingSpeed();
      final lastReadingDate = await getLastReadingDate();

      return {
        'totalSessions': totalSessions,
        'completedSessions': completedSessions,
        'totalWords': totalWords,
        'averageSpeed': avgSpeed,
        'lastReadingDate': lastReadingDate?.toIso8601String(),
        'completionRate': totalSessions > 0 ? completedSessions / totalSessions : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get reading summary: $e');
    }
  }

  Future<int> getTotalSessionsCount() async {
    try {
      final result = await database.rawQuery('SELECT COUNT(*) as count FROM reading_sessions');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get total sessions count: $e');
    }
  }

  Future<int> getCompletedSessionsCount() async {
    try {
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM reading_sessions WHERE end_time IS NOT NULL',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get completed sessions count: $e');
    }
  }

  Future<int> getTotalWordsRead() async {
    try {
      final result = await database.rawQuery(
        'SELECT SUM(words_read) as total FROM reading_sessions WHERE end_time IS NOT NULL',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get total words read: $e');
    }
  }

  Future<double> getAverageReadingSpeed() async {
    try {
      final result = await database.rawQuery(
        'SELECT AVG(average_speed) as avg_speed FROM reading_sessions WHERE end_time IS NOT NULL AND average_speed > 0',
      );
      final avgSpeed = result.first['avg_speed'];
      return avgSpeed != null ? (avgSpeed as num).toDouble() : 0.0;
    } catch (e) {
      throw Exception('Failed to get average reading speed: $e');
    }
  }

  Future<DateTime?> getLastReadingDate() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'reading_sessions',
        columns: ['end_time'],
        where: 'end_time IS NOT NULL',
        orderBy: 'end_time DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final endTimeMillis = maps.first['end_time'] as int;
        return DateTime.fromMillisecondsSinceEpoch(endTimeMillis);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get last reading date: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyStats({int months = 12}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: 30 * months));
      final startMillis = startDate.millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await database.rawQuery('''
        SELECT 
          strftime('%Y-%m', start_time) as month,
          COUNT(*) as sessions,
          SUM(words_read) as words,
          AVG(average_speed) as avg_speed,
          SUM(CASE WHEN end_time IS NOT NULL THEN 1 ELSE 0 END) as completed_sessions
        FROM reading_sessions 
        WHERE start_time >= ?
        GROUP BY strftime('%Y-%m', start_time)
        ORDER BY month DESC
      ''', [startMillis]);

      return maps;
    } catch (e) {
      throw Exception('Failed to get monthly stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats({int weeks = 8}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: 7 * weeks));
      final startMillis = startDate.millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await database.rawQuery('''
        SELECT 
          strftime('%Y-%W', start_time) as week,
          COUNT(*) as sessions,
          SUM(words_read) as words,
          AVG(average_speed) as avg_speed,
          SUM(CASE WHEN end_time IS NOT NULL THEN 1 ELSE 0 END) as completed_sessions
        FROM reading_sessions 
        WHERE start_time >= ?
        GROUP BY strftime('%Y-%W', start_time)
        ORDER BY week DESC
      ''', [startMillis]);

      return maps;
    } catch (e) {
      throw Exception('Failed to get weekly stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDailyStats({int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final startMillis = startDate.millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await database.rawQuery('''
        SELECT 
          strftime('%Y-%m-%d', start_time) as day,
          COUNT(*) as sessions,
          SUM(words_read) as words,
          AVG(average_speed) as avg_speed,
          SUM(CASE WHEN end_time IS NOT NULL THEN 1 ELSE 0 END) as completed_sessions
        FROM reading_sessions 
        WHERE start_time >= ?
        GROUP BY strftime('%Y-%m-%d', start_time)
        ORDER BY day DESC
      ''', [startMillis]);

      return maps;
    } catch (e) {
      throw Exception('Failed to get daily stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopPdfs({int limit = 10}) async {
    try {
      final List<Map<String, dynamic>> maps = await database.rawQuery('''
        SELECT 
          pdf_id,
          COUNT(*) as sessions,
          SUM(words_read) as total_words,
          AVG(average_speed) as avg_speed,
          MAX(start_time) as last_read
        FROM reading_sessions 
        WHERE end_time IS NOT NULL
        GROUP BY pdf_id
        ORDER BY sessions DESC
        LIMIT ?
      ''', [limit]);

      return maps;
    } catch (e) {
      throw Exception('Failed to get top PDFs: $e');
    }
  }

  Future<Map<String, dynamic>> getSpeedDistribution() async {
    try {
      final List<Map<String, dynamic>> maps = await database.rawQuery('''
        SELECT 
          CASE 
            WHEN average_speed < 100 THEN 'Very Slow (<100 WPM)'
            WHEN average_speed < 150 THEN 'Slow (100-150 WPM)'
            WHEN average_speed < 200 THEN 'Average (150-200 WPM)'
            WHEN average_speed < 250 THEN 'Good (200-250 WPM)'
            WHEN average_speed < 300 THEN 'Fast (250-300 WPM)'
            ELSE 'Very Fast (300+ WPM)'
          END as speed_category,
          COUNT(*) as sessions
        FROM reading_sessions 
        WHERE end_time IS NOT NULL AND average_speed > 0
        GROUP BY speed_category
        ORDER BY MIN(average_speed)
      ''');

      final distribution = <String, int>{};
      for (final map in maps) {
        distribution[map['speed_category'] as String] = map['sessions'] as int;
      }

      return distribution;
    } catch (e) {
      throw Exception('Failed to get speed distribution: $e');
    }
  }

  Future<Map<String, dynamic>> getSessionDurationDistribution() async {
    try {
      final List<Map<String, dynamic>> maps = await database.rawQuery('''
        SELECT 
          CASE 
            WHEN (end_time - start_time) < 300 THEN 'Very Short (<5 min)'
            WHEN (end_time - start_time) < 900 THEN 'Short (5-15 min)'
            WHEN (end_time - start_time) < 1800 THEN 'Medium (15-30 min)'
            WHEN (end_time - start_time) < 3600 THEN 'Long (30-60 min)'
            ELSE 'Very Long (>60 min)'
          END as duration_category,
          COUNT(*) as sessions
        FROM reading_sessions 
        WHERE end_time IS NOT NULL
        GROUP BY duration_category
        ORDER BY MIN(end_time - start_time)
      ''');

      final distribution = <String, int>{};
      for (final map in maps) {
        distribution[map['duration_category'] as String] = map['sessions'] as int;
      }

      return distribution;
    } catch (e) {
      throw Exception('Failed to get session duration distribution: $e');
    }
  }
}
