import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../models/saved_gig_model.dart';
import '../models/view_history_model.dart';
import '../models/recommendation_filter_model.dart';
import 'firestore_service.dart';

class RecommendedGig {
  final ProjectModel project;
  final UserModel client;
  final double matchScore; // 0-100
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final double? distance; // Distance in km from user
  final String? locationDisplay; // Display location (city, country)
  final int? daysUntilDeadline; // Days until project deadline
  final bool isSaved; // Whether user saved this project
  final bool isViewed; // Whether user viewed this project
  final bool isApplied; // Whether user applied to this project

  RecommendedGig({
    required this.project,
    required this.client,
    required this.matchScore,
    required this.matchedSkills,
    required this.missingSkills,
    this.distance,
    this.locationDisplay,
    this.daysUntilDeadline,
    this.isSaved = false,
    this.isViewed = false,
    this.isApplied = false,
  });
}

class _MatchResult {
  final double score;
  final List<String> matchedSkills;
  final List<String> missingSkills;

  _MatchResult({
    required this.score,
    required this.matchedSkills,
    required this.missingSkills,
  });
}

class RecommendationService {
  final FirestoreService _firestore = FirestoreService();

  /// Calculate distance between two coordinates using Haversine formula (in km)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radius in km
    final double dLat = _toRad(lat2 - lat1);
    final double dLon = _toRad(lon2 - lon1);

    final double a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRad(double degree) {
    return degree * (3.14159265359 / 180.0);
  }

  /// Get location display string from user
  String _getLocationDisplay(UserModel user) {
    if (user.city != null && user.country != null) {
      return '${user.city}, ${user.country}';
    } else if (user.city != null) {
      return user.city!;
    } else if (user.country != null) {
      return user.country!;
    } else if (user.address != null) {
      return user.address!;
    }
    return 'Location not specified';
  }

  /// Get AI-powered gig recommendations for a user
  Future<List<RecommendedGig>> getGigRecommendations({
    required String userId,
    int limit = 15,
    RecommendationFilterModel? filters,
  }) async {
    try {
      final user = await _firestore.getUser(userId);
      if (user == null) return [];

      final userFilters = filters ?? await getUserPreferences(userId);
      final filter = userFilters ?? RecommendationFilterModel();

      final projects = await _firestore.streamAvailableProjects().first;

      final availableProjects = projects
          .where((p) => p.mentorId == null && p.clientId != userId)
          .toList();

      final savedGigs = await getSavedGigs(userId);
      final savedProjectIds = savedGigs.map((g) => g.projectId).toSet();
      final viewHistory = await getViewHistory(userId);
      final viewedProjectIds = viewHistory.map((v) => v.projectId).toSet();
      final appliedProjectIds = viewHistory
          .where((v) => v.applied)
          .map((v) => v.projectId)
          .toSet();

      final recommendations = <RecommendedGig>[];
      for (final project in availableProjects) {
        final client = await _firestore.getUser(project.clientId);
        if (client == null) continue;

        double? distance;
        if (user.latitude != null &&
            user.longitude != null &&
            client.latitude != null &&
            client.longitude != null) {
          distance = _calculateDistance(
            user.latitude!,
            user.longitude!,
            client.latitude!,
            client.longitude!,
          );
        }

        final matchResult = _calculateMatchScore(user.skills, project.skills);
        final daysUntilDeadline = calculateDaysUntilDeadline(project.deadline);
        final locationDisplay = _getLocationDisplay(client);

        final isSaved = savedProjectIds.contains(project.id);
        final isViewed = viewedProjectIds.contains(project.id);
        final isApplied = appliedProjectIds.contains(project.id);

        recommendations.add(
          RecommendedGig(
            project: project,
            client: client,
            matchScore: matchResult.score,
            matchedSkills: matchResult.matchedSkills,
            missingSkills: matchResult.missingSkills,
            distance: distance,
            locationDisplay: locationDisplay,
            daysUntilDeadline: daysUntilDeadline,
            isSaved: isSaved,
            isViewed: isViewed,
            isApplied: isApplied,
          ),
        );
      }

      recommendations.sort((a, b) {
        if (a.matchScore != b.matchScore) {
          return b.matchScore.compareTo(a.matchScore);
        }

        final aDistance = a.distance ?? double.infinity;
        final bDistance = b.distance ?? double.infinity;
        if (aDistance != bDistance) {
          return aDistance.compareTo(bDistance);
        }

        if (a.project.budget != b.project.budget) {
          return b.project.budget.compareTo(a.project.budget);
        }

        return b.client.rating.compareTo(a.client.rating);
      });

      final filtered = applyFilters(recommendations, filter);
      return filtered.take(limit).toList();
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }

  /// Apply filters to recommendations
  List<RecommendedGig> applyFilters(
    List<RecommendedGig> recommendations,
    RecommendationFilterModel filter,
  ) {
    return recommendations.where((gig) {
      if (gig.distance != null) {
        if (gig.distance! < filter.minDistance ||
            gig.distance! > filter.maxDistance) {
          return false;
        }
      } else if (filter.showOnlyNearby) {
        return false;
      }

      if (gig.project.budget < filter.minBudget ||
          gig.project.budget > filter.maxBudget) {
        return false;
      }

      if (gig.daysUntilDeadline != null) {
        if (gig.daysUntilDeadline! > filter.maxDaysUntilDeadline) {
          return false;
        }
      }

      if (filter.preferredSkills.isNotEmpty) {
        final hasSkill = filter.preferredSkills.any(
          (skill) => gig.matchedSkills.any(
            (s) => s.toLowerCase() == skill.toLowerCase(),
          ),
        );
        if (!hasSkill) return false;
      }

      if (filter.preferredCategories.isNotEmpty &&
          gig.project.category != null) {
        if (!filter.preferredCategories.contains(gig.project.category)) {
          return false;
        }
      }

      if (filter.experienceLevel != null &&
          gig.project.experienceLevel != null) {
        if (gig.project.experienceLevel != filter.experienceLevel) {
          return false;
        }
      }

      if (filter.showOnlyUrgent && !gig.project.isUrgent) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Save a project for later
  Future<void> saveGig({
    required String userId,
    required ProjectModel project,
    String? notes,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('savedGigs')
          .add(
            SavedGigModel(
              id: '',
              userId: userId,
              projectId: project.id,
              projectTitle: project.title,
              notes: notes,
            ).toMap(),
          );
    } catch (e) {
      print('Error saving gig: $e');
    }
  }

  /// Unsave a project
  Future<void> unsaveGig({
    required String userId,
    required String projectId,
  }) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('savedGigs')
          .where('projectId', isEqualTo: projectId)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error unsaving gig: $e');
    }
  }

  /// Get all saved gigs
  Future<List<SavedGigModel>> getSavedGigs(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('savedGigs')
          .orderBy('savedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SavedGigModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting saved gigs: $e');
      return [];
    }
  }

  /// Check if gig is saved
  Future<bool> isGigSaved({
    required String userId,
    required String projectId,
  }) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('savedGigs')
          .where('projectId', isEqualTo: projectId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Track project view or application
  Future<void> trackProjectView({
    required String userId,
    required ProjectModel project,
    bool applied = false,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('viewHistory')
          .add(
            ViewHistoryModel(
              id: '',
              userId: userId,
              projectId: project.id,
              projectTitle: project.title,
              applied: applied,
            ).toMap(),
          );
    } catch (e) {
      print('Error tracking view: $e');
    }
  }

  /// Get view history
  Future<List<ViewHistoryModel>> getViewHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('viewHistory')
          .orderBy('viewedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ViewHistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting view history: $e');
      return [];
    }
  }

  /// Save user preferences
  Future<void> savePreferences({
    required String userId,
    required RecommendationFilterModel preferences,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'recommendationPreferences': preferences.toMap(),
      });
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  /// Get user preferences
  Future<RecommendationFilterModel?> getUserPreferences(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final preferences = doc.data()?['recommendationPreferences'];
      if (preferences != null) {
        return RecommendationFilterModel.fromMap(
          preferences as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Calculate days until deadline
  int calculateDaysUntilDeadline(DateTime deadline) {
    return deadline.difference(DateTime.now()).inDays;
  }

  /// Get deadline urgency string
  String getDeadlineUrgency(int daysLeft) {
    if (daysLeft < 0) return 'Overdue';
    if (daysLeft == 0) return 'Today';
    if (daysLeft == 1) return 'Tomorrow';
    if (daysLeft <= 7) return 'This week';
    if (daysLeft <= 14) return 'Next week';
    if (daysLeft <= 30) return 'This month';
    return '$daysLeft days left';
  }

  /// Calculate match score
  _MatchResult _calculateMatchScore(
    List<String> userSkills,
    List<String> projectSkills,
  ) {
    if (projectSkills.isEmpty) {
      return _MatchResult(score: 50.0, matchedSkills: [], missingSkills: []);
    }

    final userSkillsLower = userSkills.map((s) => s.toLowerCase()).toSet();
    final projectSkillsLower = projectSkills
        .map((s) => s.toLowerCase())
        .toList();

    final matchedSkills = <String>[];
    final missingSkills = <String>[];

    for (final skill in projectSkillsLower) {
      if (userSkillsLower.contains(skill)) {
        matchedSkills.add(skill);
      } else {
        missingSkills.add(skill);
      }
    }

    final matchPercentage =
        (matchedSkills.length / projectSkillsLower.length) * 100;
    double score = matchPercentage;

    if (userSkills.length > projectSkillsLower.length) {
      score = (score + 10).clamp(0.0, 100.0);
    }

    return _MatchResult(
      score: score,
      matchedSkills: matchedSkills,
      missingSkills: missingSkills,
    );
  }

  /// Get mentor recommendations
  Future<List<RecommendedGig>> getMentorRecommendations({
    required String mentorId,
    int limit = 10,
    RecommendationFilterModel? filters,
  }) async {
    try {
      final mentor = await _firestore.getUser(mentorId);
      if (mentor == null || mentor.userType != 'mentor') return [];

      final userFilters = filters ?? await getUserPreferences(mentorId);
      final filter = userFilters ?? RecommendationFilterModel();

      final projects = await _firestore.streamAvailableProjects().first;
      final availableProjects = projects
          .where((p) => p.mentorId == null)
          .toList();

      final savedGigs = await getSavedGigs(mentorId);
      final savedProjectIds = savedGigs.map((g) => g.projectId).toSet();
      final viewHistory = await getViewHistory(mentorId);
      final viewedProjectIds = viewHistory.map((v) => v.projectId).toSet();
      final appliedProjectIds = viewHistory
          .where((v) => v.applied)
          .map((v) => v.projectId)
          .toSet();

      final recommendations = <RecommendedGig>[];
      for (final project in availableProjects) {
        final client = await _firestore.getUser(project.clientId);
        if (client == null) continue;

        double? distance;
        if (mentor.latitude != null &&
            mentor.longitude != null &&
            client.latitude != null &&
            client.longitude != null) {
          distance = _calculateDistance(
            mentor.latitude!,
            mentor.longitude!,
            client.latitude!,
            client.longitude!,
          );
        }

        final matchResult = _calculateMatchScore(mentor.skills, project.skills);
        final daysUntilDeadline = calculateDaysUntilDeadline(project.deadline);
        final locationDisplay = _getLocationDisplay(client);

        final isSaved = savedProjectIds.contains(project.id);
        final isViewed = viewedProjectIds.contains(project.id);
        final isApplied = appliedProjectIds.contains(project.id);

        recommendations.add(
          RecommendedGig(
            project: project,
            client: client,
            matchScore: matchResult.score,
            matchedSkills: matchResult.matchedSkills,
            missingSkills: matchResult.missingSkills,
            distance: distance,
            locationDisplay: locationDisplay,
            daysUntilDeadline: daysUntilDeadline,
            isSaved: isSaved,
            isViewed: isViewed,
            isApplied: isApplied,
          ),
        );
      }

      recommendations.sort((a, b) {
        if (a.matchScore != b.matchScore) {
          return b.matchScore.compareTo(a.matchScore);
        }
        final aDistance = a.distance ?? double.infinity;
        final bDistance = b.distance ?? double.infinity;
        if (aDistance != bDistance) {
          return aDistance.compareTo(bDistance);
        }
        if (a.project.budget != b.project.budget) {
          return b.project.budget.compareTo(a.project.budget);
        }
        return b.client.rating.compareTo(a.client.rating);
      });

      final filtered = applyFilters(recommendations, filter);
      return filtered.take(limit).toList();
    } catch (e) {
      print('Error getting mentor recommendations: $e');
      return [];
    }
  }

  /// Get similar project recommendations
  Future<List<RecommendedGig>> getSimilarProjectRecommendations({
    required String userId,
    required ProjectModel referenceProject,
    int limit = 5,
    RecommendationFilterModel? filters,
  }) async {
    try {
      final user = await _firestore.getUser(userId);
      if (user == null) return [];

      final userFilters = filters ?? await getUserPreferences(userId);
      final filter = userFilters ?? RecommendationFilterModel();

      final projects = await _firestore.streamAvailableProjects().first;
      final availableProjects = projects
          .where(
            (p) =>
                p.mentorId == null &&
                p.clientId != userId &&
                p.id != referenceProject.id,
          )
          .toList();

      final savedGigs = await getSavedGigs(userId);
      final savedProjectIds = savedGigs.map((g) => g.projectId).toSet();
      final viewHistory = await getViewHistory(userId);
      final viewedProjectIds = viewHistory.map((v) => v.projectId).toSet();
      final appliedProjectIds = viewHistory
          .where((v) => v.applied)
          .map((v) => v.projectId)
          .toSet();

      final recommendations = <RecommendedGig>[];
      for (final project in availableProjects) {
        final client = await _firestore.getUser(project.clientId);
        if (client == null) continue;

        double? distance;
        if (user.latitude != null &&
            user.longitude != null &&
            client.latitude != null &&
            client.longitude != null) {
          distance = _calculateDistance(
            user.latitude!,
            user.longitude!,
            client.latitude!,
            client.longitude!,
          );
        }

        final matchResult = _calculateMatchScore(user.skills, project.skills);

        double adjustedScore = matchResult.score;
        final similarSkills = referenceProject.skills.where(
          (s1) =>
              project.skills.any((s2) => s1.toLowerCase() == s2.toLowerCase()),
        );
        if (similarSkills.isNotEmpty) {
          adjustedScore = (matchResult.score + 15).clamp(0.0, 100.0);
        }

        final daysUntilDeadline = calculateDaysUntilDeadline(project.deadline);
        final locationDisplay = _getLocationDisplay(client);

        final isSaved = savedProjectIds.contains(project.id);
        final isViewed = viewedProjectIds.contains(project.id);
        final isApplied = appliedProjectIds.contains(project.id);

        recommendations.add(
          RecommendedGig(
            project: project,
            client: client,
            matchScore: adjustedScore,
            matchedSkills: matchResult.matchedSkills,
            missingSkills: matchResult.missingSkills,
            distance: distance,
            locationDisplay: locationDisplay,
            daysUntilDeadline: daysUntilDeadline,
            isSaved: isSaved,
            isViewed: isViewed,
            isApplied: isApplied,
          ),
        );
      }

      recommendations.sort((a, b) {
        if (a.matchScore != b.matchScore) {
          return b.matchScore.compareTo(a.matchScore);
        }
        final aDistance = a.distance ?? double.infinity;
        final bDistance = b.distance ?? double.infinity;
        return aDistance.compareTo(bDistance);
      });

      final filtered = applyFilters(recommendations, filter);
      return filtered.take(limit).toList();
    } catch (e) {
      print('Error getting similar projects: $e');
      return [];
    }
  }

  /// Get smart recommendations based on user behavior and activity
  Future<List<RecommendedGig>> getSmartRecommendations({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final user = await _firestore.getUser(userId);
      if (user == null) return [];

      // Get user's activity history
      final viewHistory = await getViewHistory(userId, limit: 100);

      // Analyze patterns - extract most clicked project categories/skills
      final categoryFrequency = <String, int>{};
      final skillFrequency = <String, int>{};

      for (final view in viewHistory) {
        // Get project details to extract category
        final projectQuery = await FirebaseFirestore.instance
            .collection('projects')
            .where(FieldPath.documentId, isEqualTo: view.projectId)
            .limit(1)
            .get();

        if (projectQuery.docs.isNotEmpty) {
          final projectData = projectQuery.docs.first.data();
          final category = projectData['category'] as String?;
          if (category != null) {
            categoryFrequency[category] =
                (categoryFrequency[category] ?? 0) + 1;
          }

          final skills = projectData['skills'] as List?;
          if (skills != null) {
            for (final skill in skills) {
              skillFrequency[skill] = (skillFrequency[skill] ?? 0) + 1;
            }
          }
        }
      }

      // Get projects in top categories
      final topCategories = categoryFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topSkills = skillFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Fetch recommendations matching user behavior
      final projects = await _firestore.streamAvailableProjects().first;
      final recommendations = <RecommendedGig>[];
      final savedGigs = await getSavedGigs(userId);
      final savedProjectIds = savedGigs.map((g) => g.projectId).toSet();

      for (final project in projects) {
        if (project.mentorId != null || project.clientId == userId) continue;

        // Score higher if in preferred categories or skills
        double behavioralScore = 0.0;

        if (topCategories.isNotEmpty) {
          for (int i = 0; i < topCategories.length && i < 3; i++) {
            if (project.category == topCategories[i].key) {
              behavioralScore += (10 - (i * 2)).toDouble();
            }
          }
        }

        if (topSkills.isNotEmpty) {
          for (int i = 0; i < topSkills.length && i < 3; i++) {
            if (project.skills.contains(topSkills[i].key)) {
              behavioralScore += (10 - (i * 2)).toDouble();
            }
          }
        }

        if (behavioralScore > 0) {
          final client = await _firestore.getUser(project.clientId);
          if (client == null) continue;

          double? distance;
          if (user.latitude != null &&
              user.longitude != null &&
              client.latitude != null &&
              client.longitude != null) {
            distance = _calculateDistance(
              user.latitude!,
              user.longitude!,
              client.latitude!,
              client.longitude!,
            );
          }

          final matchResult = _calculateMatchScore(user.skills, project.skills);
          final daysUntilDeadline = calculateDaysUntilDeadline(
            project.deadline,
          );
          final locationDisplay = _getLocationDisplay(client);

          // Combine skill match with behavioral score
          final finalScore = matchResult.score + behavioralScore;

          recommendations.add(
            RecommendedGig(
              project: project,
              client: client,
              matchScore: finalScore,
              matchedSkills: matchResult.matchedSkills,
              missingSkills: matchResult.missingSkills,
              distance: distance,
              locationDisplay: locationDisplay,
              daysUntilDeadline: daysUntilDeadline,
              isSaved: savedProjectIds.contains(project.id),
              isViewed: false,
              isApplied: false,
            ),
          );
        }
      }

      // Sort by score
      recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      return recommendations.take(limit).toList();
    } catch (e) {
      print('Error getting smart recommendations: $e');
      return [];
    }
  }

  /// Get trending projects (most viewed/applied by users like you)
  Future<List<RecommendedGig>> getTrendingProjects({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final user = await _firestore.getUser(userId);
      if (user == null) return [];

      // Get view history stats
      final viewCountMap = <String, int>{};
      final allViewHistory = await FirebaseFirestore.instance
          .collection('users')
          .get();

      for (final userDoc in allViewHistory.docs) {
        try {
          final userViewHistory = await FirebaseFirestore.instance
              .collection('users')
              .doc(userDoc.id)
              .collection('viewHistory')
              .get();

          for (final view in userViewHistory.docs) {
            final projectId = view.data()['projectId'] as String?;
            if (projectId != null) {
              viewCountMap[projectId] = (viewCountMap[projectId] ?? 0) + 1;
            }
          }
        } catch (e) {
          continue;
        }
      }

      // Get projects in order of popularity
      final trendingProjectIds = viewCountMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final recommendations = <RecommendedGig>[];
      final savedGigs = await getSavedGigs(userId);
      final savedProjectIds = savedGigs.map((g) => g.projectId).toSet();

      for (final entry in trendingProjectIds.take(50)) {
        try {
          final project = await FirebaseFirestore.instance
              .collection('projects')
              .doc(entry.key)
              .get();

          if (!project.exists) continue;

          final projectData = ProjectModel.fromMap(
            project.data() as Map<String, dynamic>,
            project.id,
          );

          if (projectData.mentorId != null || projectData.clientId == userId)
            continue;

          final client = await _firestore.getUser(projectData.clientId);
          if (client == null) continue;

          double? distance;
          if (user.latitude != null &&
              user.longitude != null &&
              client.latitude != null &&
              client.longitude != null) {
            distance = _calculateDistance(
              user.latitude!,
              user.longitude!,
              client.latitude!,
              client.longitude!,
            );
          }

          final matchResult = _calculateMatchScore(
            user.skills,
            projectData.skills,
          );
          final daysUntilDeadline = calculateDaysUntilDeadline(
            projectData.deadline,
          );
          final locationDisplay = _getLocationDisplay(client);

          recommendations.add(
            RecommendedGig(
              project: projectData,
              client: client,
              matchScore: matchResult.score,
              matchedSkills: matchResult.matchedSkills,
              missingSkills: matchResult.missingSkills,
              distance: distance,
              locationDisplay: locationDisplay,
              daysUntilDeadline: daysUntilDeadline,
              isSaved: savedProjectIds.contains(projectData.id),
              isViewed: false,
              isApplied: false,
            ),
          );

          if (recommendations.length >= limit) break;
        } catch (e) {
          continue;
        }
      }

      return recommendations;
    } catch (e) {
      print('Error getting trending projects: $e');
      return [];
    }
  }
}
