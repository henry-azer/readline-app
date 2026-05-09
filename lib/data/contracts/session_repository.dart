import 'package:readline_app/data/models/reading_session_model.dart';

abstract class SessionRepository {
  Future<void> save(ReadingSessionModel session);
  Future<List<ReadingSessionModel>> getAll();
  Future<List<ReadingSessionModel>> getByDocumentId(String documentId);
  Future<List<ReadingSessionModel>> getRecent(int limit);
  Future<List<ReadingSessionModel>> getByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<void> deleteByDocumentId(String documentId);
}
