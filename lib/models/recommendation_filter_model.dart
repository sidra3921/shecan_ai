class RecommendationFilterModel {
  final double minDistance; // km
  final double maxDistance; // km
  final double minBudget; // PKR
  final double maxBudget; // PKR
  final int maxDaysUntilDeadline; // Show projects with deadline within X days
  final List<String> preferredSkills; // Filter by specific skills
  final List<String> preferredCategories; // Filter by project category
  final String? experienceLevel; // 'beginner', 'intermediate', 'expert'
  final bool showOnlyNearby; // Only show projects within range
  final bool showOnlyUrgent; // Only show urgent projects

  RecommendationFilterModel({
    this.minDistance = 0,
    this.maxDistance = 500,
    this.minBudget = 0,
    this.maxBudget = 1000000,
    this.maxDaysUntilDeadline = 90,
    this.preferredSkills = const [],
    this.preferredCategories = const [],
    this.experienceLevel,
    this.showOnlyNearby = false,
    this.showOnlyUrgent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'minDistance': minDistance,
      'maxDistance': maxDistance,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'maxDaysUntilDeadline': maxDaysUntilDeadline,
      'preferredSkills': preferredSkills,
      'preferredCategories': preferredCategories,
      'experienceLevel': experienceLevel,
      'showOnlyNearby': showOnlyNearby,
      'showOnlyUrgent': showOnlyUrgent,
    };
  }

  factory RecommendationFilterModel.fromMap(Map<String, dynamic> map) {
    return RecommendationFilterModel(
      minDistance: (map['minDistance'] ?? 0).toDouble(),
      maxDistance: (map['maxDistance'] ?? 500).toDouble(),
      minBudget: (map['minBudget'] ?? 0).toDouble(),
      maxBudget: (map['maxBudget'] ?? 1000000).toDouble(),
      maxDaysUntilDeadline: map['maxDaysUntilDeadline'] ?? 90,
      preferredSkills: List<String>.from(map['preferredSkills'] ?? []),
      preferredCategories: List<String>.from(map['preferredCategories'] ?? []),
      experienceLevel: map['experienceLevel'],
      showOnlyNearby: map['showOnlyNearby'] ?? false,
      showOnlyUrgent: map['showOnlyUrgent'] ?? false,
    );
  }

  RecommendationFilterModel copyWith({
    double? minDistance,
    double? maxDistance,
    double? minBudget,
    double? maxBudget,
    int? maxDaysUntilDeadline,
    List<String>? preferredSkills,
    List<String>? preferredCategories,
    String? experienceLevel,
    bool? showOnlyNearby,
    bool? showOnlyUrgent,
  }) {
    return RecommendationFilterModel(
      minDistance: minDistance ?? this.minDistance,
      maxDistance: maxDistance ?? this.maxDistance,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      maxDaysUntilDeadline: maxDaysUntilDeadline ?? this.maxDaysUntilDeadline,
      preferredSkills: preferredSkills ?? this.preferredSkills,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      showOnlyNearby: showOnlyNearby ?? this.showOnlyNearby,
      showOnlyUrgent: showOnlyUrgent ?? this.showOnlyUrgent,
    );
  }
}
