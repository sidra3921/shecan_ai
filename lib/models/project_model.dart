class ProjectModel {
  final String id;
  final String title;
  final String description;
  final double budget;
  final DateTime deadline;
  final String status; // 'pending', 'in-progress', 'completed', 'cancelled'
  final String clientId;
  final String? mentorId;
  final List<String> skills;
  final int progress; // 0-100

  // Location fields
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String? address;

  // Additional fields
  final String?
  category; // 'design', 'development', 'writing', 'marketing', etc.
  final String? experienceLevel; // 'beginner', 'intermediate', 'expert'
  final bool isUrgent; // Whether project is urgent

  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.deadline,
    this.status = 'pending',
    required this.clientId,
    this.mentorId,
    this.skills = const [],
    this.progress = 0,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.address,
    this.category,
    this.experienceLevel,
    this.isUrgent = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'budget': budget,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'client_id': clientId,
      'freelancer_id': mentorId,
      'skills': skills,
      'progress': progress,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'address': address,
      'category': category,
      'experience_level': experienceLevel,
      'is_urgent': isUrgent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    return ProjectModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      deadline: _parseDateTime(map['deadline']) ?? DateTime.now(),
      status: map['status'] ?? 'pending',
      clientId: map['client_id'] ?? map['clientId'] ?? '',
      mentorId: map['freelancer_id'] ?? map['mentorId'],
      skills: List<String>.from(map['skills'] ?? []),
      progress: map['progress'] ?? 0,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      city: map['city'],
      country: map['country'],
      address: map['address'],
      category: map['category'],
      experienceLevel: map['experience_level'] ?? map['experienceLevel'],
      isUrgent: map['is_urgent'] ?? map['isUrgent'] ?? false,
      createdAt:
          _parseDateTime(map['created_at'] ?? map['createdAt']) ??
          DateTime.now(),
      updatedAt:
          _parseDateTime(map['updated_at'] ?? map['updatedAt']) ??
          DateTime.now(),
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

  ProjectModel copyWith({
    String? title,
    String? description,
    double? budget,
    DateTime? deadline,
    String? status,
    String? mentorId,
    List<String>? skills,
    int? progress,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? address,
    String? category,
    String? experienceLevel,
    bool? isUrgent,
  }) {
    return ProjectModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      clientId: clientId,
      mentorId: mentorId ?? this.mentorId,
      skills: skills ?? this.skills,
      progress: progress ?? this.progress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      address: address ?? this.address,
      category: category ?? this.category,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      isUrgent: isUrgent ?? this.isUrgent,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
