import 'package:cloud_firestore/cloud_firestore.dart';

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
      'savedAt': Timestamp.fromDate(savedAt),
      'notes': notes,
    };
  }

  factory SavedGigModel.fromMap(Map<String, dynamic> map, String id) {
    return SavedGigModel(
      id: id,
      userId: map['userId'] ?? '',
      projectId: map['projectId'] ?? '',
      projectTitle: map['projectTitle'] ?? '',
      savedAt: (map['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
    );
  }
}
