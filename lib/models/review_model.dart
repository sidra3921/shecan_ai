import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String projectId;
  final String reviewerId;
  final String reviewedUserId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.projectId,
    required this.reviewerId,
    required this.reviewedUserId,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'reviewerId': reviewerId,
      'reviewedUserId': reviewedUserId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      projectId: map['projectId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      reviewedUserId: map['reviewedUserId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
