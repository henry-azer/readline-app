import 'package:read_it/data/models/reading_session_model.dart';

abstract class SessionRepository {
  Future<void> save(ReadingSessionModel session);
  Future<List<ReadingSessionModel>> getByDocumentId(String documentId);
  Future<List<ReadingSessionModel>> getRecent(int limit);
  Future<List<ReadingSessionModel>> getByDateRange(
    DateTime start,
    DateTime end,
  );
}
