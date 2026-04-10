
class SavedGigModel {
  final String id;
  final String userId;
  final String projectId;
  final String projectTitle;
  final DateTime savedAt;
  final String? notes;

  SavedGigModel({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.projectTitle,
    DateTime? savedAt,
    this.notes,
  }) : savedAt = savedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'savedAt': savedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory SavedGigModel.fromMap(Map<String, dynamic> map, String id) {
    return SavedGigModel(
      id: id,
      userId: map['userId'] ?? '',
      projectId: map['projectId'] ?? '',
      projectTitle: map['projectTitle'] ?? '',
      savedAt: _parseDateTime(map['savedAt']) ?? DateTime.now(),
      notes: map['notes'],
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

