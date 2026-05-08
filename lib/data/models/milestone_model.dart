class MilestoneModel {
  final String id;
  final String type; // 'streak', 'daily_target', 'words'
  final int value;
  final DateTime date;
  final String description;

  const MilestoneModel({
    required this.id,
    required this.type,
    required this.value,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'value': value,
    'date': date.millisecondsSinceEpoch,
    'description': description,
  };

  factory MilestoneModel.fromMap(Map<dynamic, dynamic> map) {
    return MilestoneModel(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      value: map['value'] as int? ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int? ?? 0),
      description: map['description'] as String? ?? '',
    );
  }
}
