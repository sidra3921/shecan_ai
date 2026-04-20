class OrderEventModel {
  final String id;
  final String projectId;
  final String eventType;
  final String actorId;
  final String? note;
  final DateTime createdAt;

  OrderEventModel({
    required this.id,
    required this.projectId,
    required this.eventType,
    required this.actorId,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory OrderEventModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderEventModel(
      id: id,
      projectId: map['project_id']?.toString() ?? map['projectId']?.toString() ?? '',
      eventType: map['event_type']?.toString() ?? map['eventType']?.toString() ?? '',
      actorId: map['actor_id']?.toString() ?? map['actorId']?.toString() ?? '',
      note: map['note']?.toString(),
      createdAt: _parseDateTime(map['created_at'] ?? map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'event_type': eventType,
      'actor_id': actorId,
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
      'created_at': createdAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}