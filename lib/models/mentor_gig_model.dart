class MentorGigModel {
  final String id;
  final String mentorId;
  final String title;
  final String description;
  final List<String> skills;
  final String? category;
  final String? experienceLevel;
  final double hourlyRate;
  final bool isActive;
  final String imageUrl;
  final List<Map<String, dynamic>> packages;
  final DateTime createdAt;
  final DateTime updatedAt;

  MentorGigModel({
    required this.id,
    required this.mentorId,
    required this.title,
    required this.description,
    this.skills = const [],
    this.category,
    this.experienceLevel,
    this.hourlyRate = 0,
    this.isActive = true,
    this.imageUrl = '',
    this.packages = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'mentor_id': mentorId,
      'title': title,
      'description': description,
      'skills': skills,
      'category': category,
      'experience_level': experienceLevel,
      'hourly_rate': hourlyRate,
      'is_active': isActive,
      'image_url': imageUrl,
      'packages': packages,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MentorGigModel.fromMap(Map<String, dynamic> map, String id) {
    return MentorGigModel(
      id: id,
      mentorId: map['mentor_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      skills: List<String>.from(map['skills'] ?? const []),
      category: map['category']?.toString(),
      experienceLevel: map['experience_level']?.toString(),
      hourlyRate: (map['hourly_rate'] ?? 0).toDouble(),
      isActive: map['is_active'] == null ? true : map['is_active'] == true,
        imageUrl: (map['image_url'] ?? map['imageUrl'] ?? '').toString(),
        packages: ((map['packages'] ?? map['package_tiers'] ?? const []) as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
