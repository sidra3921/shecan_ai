import 'package:cloud_firestore/cloud_firestore.dart';

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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
