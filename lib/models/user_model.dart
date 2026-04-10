

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String photoURL;
  final String userType; // 'mentor' or 'client'
  final String phone;
  final String bio;
  final List<String> skills;
  final double hourlyRate;
  final double rating;
  final int completedProjects;
  final double totalEarnings;
  final int totalReviews;

  // Location fields for GIS
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String? address;

  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL = '',
    required this.userType,
    this.phone = '',
    this.bio = '',
    this.skills = const [],
    this.hourlyRate = 0.0,
    this.rating = 0.0,
    this.completedProjects = 0,
    this.totalEarnings = 0.0,
    this.totalReviews = 0,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'userType': userType,
      'phone': phone,
      'bio': bio,
      'skills': skills,
      'hourlyRate': hourlyRate,
      'rating': rating,
      'completedProjects': completedProjects,
      'totalEarnings': totalEarnings,
      'totalReviews': totalReviews,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'] ?? '',
      userType: map['userType'] ?? 'client',
      phone: map['phone'] ?? '',
      bio: map['bio'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      completedProjects: map['completedProjects'] ?? 0,
      totalEarnings: (map['totalEarnings'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      city: map['city'],
      country: map['country'],
      address: map['address'],
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    String? photoURL,
    String? userType,
    String? phone,
    String? bio,
    List<String>? skills,
    double? hourlyRate,
    double? rating,
    int? completedProjects,
    double? totalEarnings,
    int? totalReviews,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? address,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      completedProjects: completedProjects ?? this.completedProjects,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalReviews: totalReviews ?? this.totalReviews,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      address: address ?? this.address,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate distance to another user in kilometers using Haversine formula
  double? distanceToUser(UserModel other) {
    if (latitude == null ||
        longitude == null ||
        other.latitude == null ||
        other.longitude == null) {
      return null;
    }
    return _calculateDistance(
      latitude!,
      longitude!,
      other.latitude!,
      other.longitude!,
    );
  }

  /// Haversine formula for calculating distance between two coordinates
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * 3.141592653589793 / 180;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing DateTime: $e');
        return null;
      }
    }
    return null;
  }
}
