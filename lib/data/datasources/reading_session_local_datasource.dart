import 'package:sqflite/sqflite.dart';
import '../models/reading_session_model.dart';

abstract class ReadingSessionLocalDataSource {
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

class ReadingSessionLocalDataSourceImpl implements ReadingSessionLocalDataSource {
  final Database database;

  ReadingSessionLocalDataSourceImpl(this.database);

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

  // Additional helper methods
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

  Future<List<ReadingSessionModel>> getSessionsByDayOfWeek(int dayOfWeek) async {
    try {
      // SQLite dayOfWeek: 0=Sunday, 1=Monday, ..., 6=Saturday
      final List<Map<String, dynamic>> maps = await database.rawQuery(
        'SELECT * FROM reading_sessions WHERE strftime("%w", start_time) = ? ORDER BY start_time DESC',
        [dayOfWeek.toString()],
      );

      return List.generate(maps.length, (i) {
        return ReadingSessionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get sessions by day of week: $e');
    }
  }

  Future<List<ReadingSessionModel>> getSessionsByHour(int hour) async {
    try {
      final List<Map<String, dynamic>> maps = await database.rawQuery(
        'SELECT * FROM reading_sessions WHERE strftime("%H", start_time) = ? ORDER BY start_time DESC',
        [hour.toString().padLeft(2, '0')],
      );

      return List.generate(maps.length, (i) {
        return ReadingSessionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get sessions by hour: $e');
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

  Future<List<ReadingSessionModel>> getLongestSessions({int limit = 10}) async {
    try {
      final List<Map<String, dynamic>> maps = await database.rawQuery(
        'SELECT *, (end_time - start_time) as duration FROM reading_sessions WHERE end_time IS NOT NULL ORDER BY duration DESC LIMIT ?',
        [limit],
      );

      return List.generate(maps.length, (i) {
        return ReadingSessionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get longest sessions: $e');
    }
  }

  Future<List<ReadingSessionModel>> getFastestSessions({int limit = 10}) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'reading_sessions',
        where: 'end_time IS NOT NULL AND average_speed > 0',
        orderBy: 'average_speed DESC',
        limit: limit,
      );

      return List.generate(maps.length, (i) {
        return ReadingSessionModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get fastest sessions: $e');
    }
  }
}
