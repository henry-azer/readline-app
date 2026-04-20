import 'package:hive/hive.dart';
import 'package:read_it/data/models/pdf_document_model.dart';

class HiveDocumentSource {
  static const _boxName = 'documents';

  Future<Box<dynamic>> _openBox() => Hive.openBox(_boxName);

  Future<List<PdfDocumentModel>> getAll() async {
    try {
      final box = await _openBox();
      return box.values
          .map((e) => PdfDocumentModel.fromMap(e as Map<dynamic, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<PdfDocumentModel?> getById(String id) async {
    try {
      final box = await _openBox();
      final data = box.get(id);
      if (data == null) return null;
      return PdfDocumentModel.fromMap(data as Map<dynamic, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(PdfDocumentModel doc) async {
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
