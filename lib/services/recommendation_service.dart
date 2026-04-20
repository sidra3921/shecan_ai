import '../models/project_model.dart';
import '../models/mentor_gig_model.dart';
import '../models/user_model.dart';
import 'supabase_database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectApplication {
  final String id;
  final String projectId;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String status;
  final String? coverNote;
  final DateTime createdAt;

  ProjectApplication({
    required this.id,
    required this.projectId,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.status,
    this.coverNote,
    required this.createdAt,
  });
}

class RecommendedGig {
  final ProjectModel project;
  final UserModel client;
  final double matchScore;
  final bool isSaved;
  final bool isApplied;
  final bool isViewed;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final int? daysUntilDeadline;
  final String? locationDisplay;
  final double? distance;

  RecommendedGig({
    required this.project,
    required this.client,
    required this.matchScore,
    this.isSaved = false,
    this.isApplied = false,
    this.isViewed = false,
    this.matchedSkills = const [],
    this.missingSkills = const [],
    this.daysUntilDeadline,
    this.locationDisplay,
    this.distance,
  });
}

class MentorGigRecommendation {
  final MentorGigModel gig;
  final UserModel mentor;
  final double matchScore;
  final List<String> matchedSkills;
  final List<String> missingSkills;

  MentorGigRecommendation({
    required this.gig,
    required this.mentor,
    required this.matchScore,
    this.matchedSkills = const [],
    this.missingSkills = const [],
  });
}

class MentorGigDraft {
  final String title;
  final String description;
  final List<String> suggestedSkills;

  MentorGigDraft({
    required this.title,
    required this.description,
    required this.suggestedSkills,
  });
}

class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final SupabaseDatabaseService _db = SupabaseDatabaseService();

  Future<String> createMentorGig(MentorGigModel gig) async {
    try {
      final response = await _db.insert('mentor_gigs', gig.toMap());
      return response['id'].toString();
    } on PostgrestException catch (e) {
      final missingTable = (e.code == 'PGRST205') ||
          e.message.toLowerCase().contains('could not find the table') ||
          e.message.toLowerCase().contains('mentor_gigs');

      if (missingTable) {
        throw Exception(
          'mentor_gigs table is missing in Supabase. Run SUPABASE_RLS_HARDENING.sql (section 10) or MENTOR_GIGS_SETUP.sql, then try again.',
        );
      }
      rethrow;
    }
  }

  MentorGigDraft generateMentorGigDraft({
    required String niche,
    required List<String> selectedSkills,
  }) {
    final cleanNiche = niche.trim();
    final titleNiche = cleanNiche.isEmpty ? 'Professional Services' : cleanNiche;
    final skills = selectedSkills.isEmpty
        ? _inferSkillsFromNiche(cleanNiche)
        : selectedSkills;

    final title = '${_capitalize(titleNiche)} Mentor for Quality Delivery';
    final description =
        'I help clients with ${titleNiche.toLowerCase()} projects from planning to execution. '
        'My focus is on clear communication, reliable delivery, and practical results. '
        'I can support projects requiring ${skills.take(4).join(', ')}.';

    return MentorGigDraft(
      title: title,
      description: description,
      suggestedSkills: skills,
    );
  }

  Future<List<MentorGigRecommendation>> getMentorGigRecommendationsForProject({
    required String projectId,
    int limit = 10,
  }) async {
    try {
      final project = await _db.getProject(projectId);
      if (project == null) return [];

      final rows = await _db.query(
        'mentor_gigs',
        filters: {'is_active': true},
        orderBy: 'created_at',
        ascending: false,
        limit: limit * 4,
      );

      final recommendations = <MentorGigRecommendation>[];

      for (final row in rows) {
        final gig = MentorGigModel.fromMap(row, row['id'].toString());
        final mentor = await _db.getUser(gig.mentorId);
        if (mentor == null) continue;

        final matchedSkills = _matchSkills(project.skills, gig.skills);
        final missingSkills = _missingProjectSkills(project.skills, gig.skills);
        final skillScore = _skillMatchScore(project.skills, gig.skills);
        final budgetScore = _budgetFitScore(project.budget, gig.hourlyRate);
        final totalScore = (skillScore * 0.8) + (budgetScore * 0.2);

        recommendations.add(
          MentorGigRecommendation(
            gig: gig,
            mentor: mentor,
            matchScore: totalScore.clamp(0, 100),
            matchedSkills: matchedSkills,
            missingSkills: missingSkills,
          ),
        );
      }

      recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      return recommendations.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<RecommendedGig>> getGigRecommendations({
    required String userId,
    int limit = 15,
  }) async {
    try {
      final user = await _db.getUser(userId);
      if (user == null) return [];

      final rawProjects = await _db.query(
        'projects',
        filters: {'status': 'pending'},
        orderBy: 'created_at',
        ascending: false,
        limit: limit * 3,
      );

      final recommendations = <RecommendedGig>[];
      for (final row in rawProjects) {
        final project = ProjectModel.fromMap(row, row['id'].toString());
        if (project.clientId == userId) continue;

        final client = await _db.getUser(project.clientId);
        if (client == null) continue;

        final score = _calculateSimpleMatch(user, project);
        final days = project.deadline.difference(DateTime.now()).inDays;
        final matched = _matchedSkills(user, project);
        final missing = _missingSkills(user, project);

        recommendations.add(
          RecommendedGig(
            project: project,
            client: client,
            matchScore: score,
            isSaved: false,
            isApplied: false,
            isViewed: false,
            matchedSkills: matched,
            missingSkills: missing,
            daysUntilDeadline: days,
            locationDisplay: _locationText(project),
            distance: user.distanceTo(
              project.latitude,
              project.longitude,
            ),
          ),
        );
      }

      recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      return recommendations.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveGig({
    required String userId,
    required ProjectModel project,
  }) async {
    await _db.insert('saved_gigs', {
      'user_id': userId,
      'project_id': project.id,
      'project_title': project.title,
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unsaveGig({
    required String userId,
    required String projectId,
  }) async {
    final rows = await _db.query(
      'saved_gigs',
      filters: {'user_id': userId, 'project_id': projectId},
      limit: 1,
    );
    if (rows.isNotEmpty) {
      await _db.delete('saved_gigs', rows.first['id'].toString());
    }
  }

  Future<void> trackProjectView({
    required String userId,
    required ProjectModel project,
    bool applied = false,
  }) async {
    await _db.insert('view_history', {
      'user_id': userId,
      'project_id': project.id,
      'project_title': project.title,
      'viewed_at': DateTime.now().toIso8601String(),
      'applied': applied,
    });
  }

  Future<bool> hasAppliedForProject({
    required String userId,
    required String projectId,
  }) async {
    try {
      final rows = await _db.query(
        'project_applications',
        filters: {'applicant_id': userId, 'project_id': projectId},
        limit: 1,
      );
      return rows.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> applyForProject({
    required String userId,
    required ProjectModel project,
    String? coverNote,
  }) async {
    final alreadyApplied = await hasAppliedForProject(
      userId: userId,
      projectId: project.id,
    );
    if (alreadyApplied) return;

    final applicant = await _db.getUser(userId);

    await _db.insert('project_applications', {
      'project_id': project.id,
      'client_id': project.clientId,
      'applicant_id': userId,
      'applicant_name': applicant?.displayName,
      'applicant_email': applicant?.email,
      'cover_note': coverNote,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<ProjectApplication>> getProjectApplications(String projectId) async {
    try {
      final rows = await _db.query(
        'project_applications',
        filters: {'project_id': projectId},
        orderBy: 'created_at',
        ascending: false,
      );

      return rows.map((row) {
        final applicantName = (row['applicant_name'] as String?)?.trim();
        final applicantEmail = (row['applicant_email'] as String?)?.trim();

        return ProjectApplication(
          id: row['id'].toString(),
          projectId: row['project_id']?.toString() ?? projectId,
          applicantId: row['applicant_id']?.toString() ?? '',
          applicantName: (applicantName == null || applicantName.isEmpty)
              ? 'Mentor'
              : applicantName,
          applicantEmail: applicantEmail ?? '',
          status: (row['status']?.toString() ?? 'pending').toLowerCase(),
          coverNote: row['cover_note']?.toString(),
          createdAt:
              DateTime.tryParse(row['created_at']?.toString() ?? '') ??
              DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> decideOnApplication({
    required String projectId,
    required String applicationId,
    required String applicantId,
    required bool accept,
  }) async {
    final status = accept ? 'accepted' : 'rejected';

    await _db.update('project_applications', applicationId, {
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    });

    if (!accept) return;

    await _db.updateProject(projectId, {
      'status': 'in-progress',
      'freelancer_id': applicantId,
      'progress': 5,
    });

    final pendingRows = await _db.query(
      'project_applications',
      filters: {'project_id': projectId, 'status': 'pending'},
    );

    for (final row in pendingRows) {
      final id = row['id']?.toString();
      if (id == null || id == applicationId) continue;
      await _db.update('project_applications', id, {
        'status': 'rejected',
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  String getDeadlineUrgency(int daysUntilDeadline) {
    if (daysUntilDeadline < 0) return 'Expired';
    if (daysUntilDeadline <= 2) return 'Urgent';
    if (daysUntilDeadline <= 7) return 'Soon';
    return 'Open';
  }

  double _calculateSimpleMatch(UserModel user, ProjectModel project) {
    if (project.skills.isEmpty || user.skills.isEmpty) return 50;
    final userSkills = user.skills.map((s) => s.toLowerCase()).toSet();
    final projectSkills = project.skills.map((s) => s.toLowerCase()).toSet();
    final overlap = userSkills.intersection(projectSkills).length;
    final ratio = overlap / projectSkills.length;
    return (50 + (ratio * 50)).clamp(0, 100).toDouble();
  }

  List<String> _matchedSkills(UserModel user, ProjectModel project) {
    final userSkills = user.skills.map((s) => s.toLowerCase()).toSet();
    return project.skills.where((s) => userSkills.contains(s.toLowerCase())).toList();
  }

  List<String> _missingSkills(UserModel user, ProjectModel project) {
    final userSkills = user.skills.map((s) => s.toLowerCase()).toSet();
    return project.skills.where((s) => !userSkills.contains(s.toLowerCase())).toList();
  }

  String _locationText(ProjectModel project) {
    final city = project.city?.trim();
    final country = project.country?.trim();
    if (city != null && city.isNotEmpty && country != null && country.isNotEmpty) {
      return '$city, $country';
    }
    if (city != null && city.isNotEmpty) return city;
    if (country != null && country.isNotEmpty) return country;
    return 'Remote';
  }

  List<String> _inferSkillsFromNiche(String niche) {
    final lower = niche.toLowerCase();
    if (lower.contains('design')) return ['Logo Design', 'UI/UX', 'Branding'];
    if (lower.contains('develop')) return ['Flutter', 'Web Development', 'API'];
    if (lower.contains('market')) return ['Digital Marketing', 'SEO', 'Social Media'];
    if (lower.contains('write')) return ['Content Writing', 'Copywriting', 'Editing'];
    return ['Communication', 'Project Planning', 'Client Support'];
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  List<String> _matchSkills(List<String> projectSkills, List<String> gigSkills) {
    final project = projectSkills.map((e) => e.toLowerCase()).toSet();
    return gigSkills.where((s) => project.contains(s.toLowerCase())).toList();
  }

  List<String> _missingProjectSkills(List<String> projectSkills, List<String> gigSkills) {
    final gig = gigSkills.map((e) => e.toLowerCase()).toSet();
    return projectSkills.where((s) => !gig.contains(s.toLowerCase())).toList();
  }

  double _skillMatchScore(List<String> projectSkills, List<String> gigSkills) {
    if (projectSkills.isEmpty) return 50;
    if (gigSkills.isEmpty) return 20;

    final overlap = _matchSkills(projectSkills, gigSkills).length;
    final ratio = overlap / projectSkills.length;
    return (ratio * 100).clamp(0, 100).toDouble();
  }

  double _budgetFitScore(double projectBudget, double gigHourlyRate) {
    if (projectBudget <= 0 || gigHourlyRate <= 0) return 50;
    final ratio = gigHourlyRate / projectBudget;
    if (ratio <= 0.15) return 100;
    if (ratio <= 0.25) return 85;
    if (ratio <= 0.35) return 70;
    if (ratio <= 0.50) return 55;
    return 35;
  }
}
