import 'package:readline_app/data/contracts/session_repository.dart';
import 'package:readline_app/data/datasources/local/hive_session_source.dart';
import 'package:readline_app/data/models/reading_session_model.dart';

class SessionRepositoryImpl implements SessionRepository {
  final HiveSessionSource _source;

  SessionRepositoryImpl(this._source);

  @override
  Future<void> save(ReadingSessionModel session) => _source.save(session);

  @override
  Future<List<ReadingSessionModel>> getByDocumentId(String documentId) async {
    final all = await _source.getAll();
    return all.where((s) => s.documentId == documentId).toList();
  }

  @override
  Future<List<ReadingSessionModel>> getRecent(int limit) async {
    final all = await _source.getAll();
    all.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return all.take(limit).toList();
  }

  @override
  Future<List<ReadingSessionModel>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final all = await _source.getAll();
    return all
        .where((s) => !s.startedAt.isBefore(start) && s.startedAt.isBefore(end))
        .toList();
  }

  @override
  Future<void> deleteByDocumentId(String documentId) async {
    final sessions = await getByDocumentId(documentId);
    for (final session in sessions) {
      await _source.delete(session.id);
    }
  }
}
