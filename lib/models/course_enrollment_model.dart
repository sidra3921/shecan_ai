class CourseEnrollmentModel {
  final String id;
  final String courseId;
  final String clientId;
  final String mentorId;
  final double progressPercent;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseEnrollmentModel({
    required this.id,
    required this.courseId,
    required this.clientId,
    required this.mentorId,
    this.progressPercent = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'client_id': clientId,
      'mentor_id': mentorId,
      'progress_percent': progressPercent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CourseEnrollmentModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseEnrollmentModel(
      id: id,
      courseId: (map['course_id'] ?? map['courseId'] ?? '').toString(),
      clientId: (map['client_id'] ?? map['clientId'] ?? '').toString(),
      mentorId: (map['mentor_id'] ?? map['mentorId'] ?? '').toString(),
      progressPercent: ((map['progress_percent'] ?? map['progressPercent'] ?? 0) as num)
          .toDouble(),
      createdAt:
          DateTime.tryParse((map['created_at'] ?? map['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((map['updated_at'] ?? map['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
