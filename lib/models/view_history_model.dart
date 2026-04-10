
class ViewHistoryModel {
  final String id;
  final String userId;
  final String projectId;
  final String projectTitle;
  final DateTime viewedAt;
  final bool applied; // Whether user applied to this project

  ViewHistoryModel({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.projectTitle,
    DateTime? viewedAt,
    this.applied = false,
  }) : viewedAt = viewedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'viewedAt': viewedAt.toIso8601String(),
      'applied': applied,
    };
  }

  factory ViewHistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return ViewHistoryModel(
      id: id,
      userId: map['userId'] ?? '',
      projectId: map['projectId'] ?? '',
      projectTitle: map['projectTitle'] ?? '',
      viewedAt: _parseDateTime(map['viewedAt']) ?? DateTime.now(),
      applied: map['applied'] ?? false,
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

