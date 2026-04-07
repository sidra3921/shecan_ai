import 'package:cloud_firestore/cloud_firestore.dart';

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
      'viewedAt': Timestamp.fromDate(viewedAt),
      'applied': applied,
    };
  }

  factory ViewHistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return ViewHistoryModel(
      id: id,
      userId: map['userId'] ?? '',
      projectId: map['projectId'] ?? '',
      projectTitle: map['projectTitle'] ?? '',
      viewedAt: (map['viewedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      applied: map['applied'] ?? false,
    );
  }
}
