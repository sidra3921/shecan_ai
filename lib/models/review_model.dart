class ReviewModel {
  final String id;
  final String projectId;
  final String reviewerId;
  final String reviewedUserId;
  final double rating;
  final String comment;
  final List<String> tags; // Tags like 'professional', 'reliable', 'responsive'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool verified; // Whether the reviewer actually worked with reviewee
  final int helpfulCount; // Number of people who found this review helpful
  final String
  fraudStatus; // 'none', 'flagged', 'verified_legitimate', 'verified_fake'
  final String? fraudReason; // Why it was flagged
  final List<String> attachmentUrls; // Screenshots, evidence

  ReviewModel({
    required this.id,
    required this.projectId,
    required this.reviewerId,
    required this.reviewedUserId,
    required this.rating,
    required this.comment,
    this.tags = const [],
    DateTime? createdAt,
    this.updatedAt,
    this.verified = false,
    this.helpfulCount = 0,
    this.fraudStatus = 'none',
    this.fraudReason,
    this.attachmentUrls = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'reviewer_id': reviewerId,
      'reviewed_user_id': reviewedUserId,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'verified': verified,
      'helpful_count': helpfulCount,
      'fraud_status': fraudStatus,
      'fraud_reason': fraudReason,
      'attachment_urls': attachmentUrls,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      projectId: map['project_id'] ?? map['projectId'] ?? '',
      reviewerId: map['reviewer_id'] ?? map['reviewerId'] ?? '',
      reviewedUserId: map['reviewed_user_id'] ?? map['reviewedUserId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: _parseDateTime(map['created_at'] ?? map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updated_at'] ?? map['updatedAt']),
      verified: map['verified'] ?? false,
      helpfulCount: map['helpful_count'] ?? map['helpfulCount'] ?? 0,
      fraudStatus: map['fraud_status'] ?? map['fraudStatus'] ?? 'none',
      fraudReason: map['fraud_reason'] ?? map['fraudReason'],
      attachmentUrls: List<String>.from(map['attachment_urls'] ?? map['attachmentUrls'] ?? []),
    );
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
