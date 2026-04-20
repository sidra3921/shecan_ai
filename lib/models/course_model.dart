class CourseModel {
  final String id;
  final String mentorId;
  final String title;
  final String description;
  final double price;
  final String category;
  final String duration;
  final String thumbnailUrl;
  final String videoUrl;
  final String level;
  final double rating;
  final int totalStudents;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModel({
    required this.id,
    required this.mentorId,
    required this.title,
    required this.description,
    required this.price,
    this.category = 'general',
    this.duration = '',
    this.thumbnailUrl = '',
    this.videoUrl = '',
    this.level = 'Beginner',
    this.rating = 0,
    this.totalStudents = 0,
    this.isPublished = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'mentor_id': mentorId,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'duration': duration,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'level': level,
      'rating': rating,
      'total_students': totalStudents,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseModel(
      id: id,
      mentorId: (map['mentor_id'] ?? map['mentorId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: ((map['price'] ?? 0) as num).toDouble(),
      category: (map['category'] ?? 'general').toString(),
      duration: (map['duration'] ?? '').toString(),
      thumbnailUrl: (map['thumbnail_url'] ?? map['thumbnailUrl'] ?? '').toString(),
      videoUrl: (map['video_url'] ?? map['videoUrl'] ?? '').toString(),
      level: (map['level'] ?? 'Beginner').toString(),
      rating: ((map['rating'] ?? 0) as num).toDouble(),
      totalStudents: (map['total_students'] ?? map['totalStudents'] ?? 0) as int,
      isPublished: map['is_published'] == null
          ? (map['isPublished'] == null ? true : map['isPublished'] == true)
          : map['is_published'] == true,
      createdAt:
          DateTime.tryParse((map['created_at'] ?? map['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((map['updated_at'] ?? map['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
