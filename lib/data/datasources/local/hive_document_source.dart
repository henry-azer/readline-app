import 'package:hive/hive.dart';
import 'package:readline_app/data/models/document_model.dart';

class HiveDocumentSource {
  static const _boxName = 'documents';

  Future<Box<dynamic>> _openBox() => Hive.openBox(_boxName);

  Future<List<DocumentModel>> getAll() async {
    try {
      final box = await _openBox();
      return box.values
          .map((e) => DocumentModel.fromMap(e as Map<dynamic, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<DocumentModel?> getById(String id) async {
    try {
      final box = await _openBox();
      final data = box.get(id);
      if (data == null) return null;
      return DocumentModel.fromMap(data as Map<dynamic, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(DocumentModel doc) async {
    try {
      final box = await _openBox();
      await box.put(doc.id, doc.toMap());
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
    } catch (_) {}
  }
}
