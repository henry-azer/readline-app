import 'package:hive_flutter/hive_flutter.dart';
import 'package:readline_app/data/models/milestone_model.dart';

class HiveMilestoneSource {
  static const String _boxName = 'milestones';

  Future<Box<dynamic>> _openBox() => Hive.openBox(_boxName);

  Future<void> save(MilestoneModel milestone) async {
    final box = await _openBox();
    await box.put(milestone.id, milestone.toMap());
  }

  Future<List<MilestoneModel>> getAll() async {
    final box = await _openBox();
    return box.values
        .map((e) => MilestoneModel.fromMap(e as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
  }
}
