import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/dispute_model.dart';
import '../models/review_model.dart';
import '../models/mentor_gig_model.dart';
import '../models/order_event_model.dart';
import '../models/course_model.dart';
import '../models/course_enrollment_model.dart';
import '../models/enrolled_course_item_model.dart';

class SupabaseDatabaseService {
  static final SupabaseDatabaseService _instance =
      SupabaseDatabaseService._internal();
  factory SupabaseDatabaseService() => _instance;
  SupabaseDatabaseService._internal();

  final _supabase = Supabase.instance.client;

  List<ProjectModel> _mapProjects(List<dynamic> rows) {
    return rows
        .map(
          (item) =>
              ProjectModel.fromMap(item as Map<String, dynamic>, item['id']),
        )
        .toList();
  }

  Future<List<ProjectModel>> _fetchClientProjects(String clientId) async {
    final rows = await _supabase
        .from('projects')
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);

    return _mapProjects(rows as List<dynamic>);
  }

  Future<List<ProjectModel>> _fetchFreelancerProjects(
    String freelancerId,
  ) async {
    final rows = await _supabase
        .from('projects')
        .select()
        .eq('freelancer_id', freelancerId)
        .order('created_at', ascending: false);

    return _mapProjects(rows as List<dynamic>);
  }

  Future<List<CourseModel>> _fetchMentorCourses(String mentorId) async {
    try {
      final rows = await _supabase
          .from('courses')
          .select()
          .eq('mentor_id', mentorId)
          .order('created_at', ascending: false);

      return (rows as List)
          .map(
            (item) =>
                CourseModel.fromMap(item as Map<String, dynamic>, item['id']),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching mentor courses: $e');
      return [];
    }
  }

  Future<List<CourseModel>> _fetchPublicCourses() async {
    try {
      final rows = await _supabase
          .from('courses')
          .select()
          .order('created_at', ascending: false);

      return (rows as List)
          .map(
            (item) =>
                CourseModel.fromMap(item as Map<String, dynamic>, item['id']),
          )
          .where((course) => course.isPublished)
          .toList();
    } catch (e) {
      debugPrint('Error fetching public courses: $e');
      return [];
    }
  }

  Future<List<CourseEnrollmentModel>> _fetchClientEnrollments(
    String clientId,
  ) async {
    try {
      final rows = await _supabase
          .from('enrollments')
          .select()
          .eq('client_id', clientId)
          .order('created_at', ascending: false);

      return (rows as List)
          .map(
            (item) => CourseEnrollmentModel.fromMap(
              item as Map<String, dynamic>,
              item['id'],
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching client enrollments: $e');
      return [];
    }
  }

  Future<List<EnrolledCourseItemModel>> _fetchClientEnrolledCourses(
    String clientId,
  ) async {
    final enrollments = await _fetchClientEnrollments(clientId);
    if (enrollments.isEmpty) return const [];

    final courseIds = enrollments.map((e) => e.courseId).toSet().toList();
    final rows = await _supabase
        .from('courses')
        .select()
        .inFilter('id', courseIds);

    final byId = <String, CourseModel>{
      for (final row in (rows as List))
        row['id'].toString(): CourseModel.fromMap(
          row as Map<String, dynamic>,
          row['id'].toString(),
        ),
    };

    return enrollments
        .where((enrollment) => byId.containsKey(enrollment.courseId))
        .map(
          (enrollment) => EnrolledCourseItemModel(
            course: byId[enrollment.courseId]!,
            enrollment: enrollment,
          ),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> _fetchMentorCourseStudents(
    String mentorId,
  ) async {
    final courses = await _fetchMentorCourses(mentorId);
    if (courses.isEmpty) return const [];

    final courseIds = courses.map((course) => course.id).toList();
    final courseById = <String, CourseModel>{
      for (final course in courses) course.id: course,
    };

    final enrollmentRows = await _supabase
        .from('enrollments')
        .select()
        .inFilter('course_id', courseIds)
        .order('created_at', ascending: false);

    final enrollments = (enrollmentRows as List)
        .map(
          (row) => CourseEnrollmentModel.fromMap(
            row as Map<String, dynamic>,
            row['id'],
          ),
        )
        .toList();

    if (enrollments.isEmpty) return const [];

    final studentIds = enrollments
        .map((enrollment) => enrollment.clientId)
        .toSet()
        .toList();
    final userRows = await _supabase
        .from('users')
        .select('id,display_name,email,photo_url')
        .inFilter('id', studentIds);

    final userById = <String, Map<String, dynamic>>{
      for (final row in (userRows as List))
        row['id'].toString(): row as Map<String, dynamic>,
    };

    return enrollments.map((enrollment) {
      final user = userById[enrollment.clientId] ?? const <String, dynamic>{};
      final course = courseById[enrollment.courseId];
      return {
        'enrollment_id': enrollment.id,
        'course_id': enrollment.courseId,
        'course_title': course?.title ?? 'Course',
        'client_id': enrollment.clientId,
        'student_name': (user['display_name'] ?? '').toString().isNotEmpty
            ? user['display_name']
            : (user['email'] ?? 'Student'),
        'student_email': (user['email'] ?? '').toString(),
        'student_photo_url': (user['photo_url'] ?? '').toString(),
        'progress_percent': enrollment.progressPercent,
        'enrolled_at': enrollment.createdAt.toIso8601String(),
      };
    }).toList();
  }

  // ==================== USER OPERATIONS ====================

  String? _extractMissingColumn(String message) {
    final match = RegExp(
      r"Could not find the '([^']+)' column",
    ).firstMatch(message);
    return match?.group(1);
  }

  Future<void> _upsertUserWithPrunedColumns(
    Map<String, dynamic> payload,
  ) async {
    final working = Map<String, dynamic>.from(payload);

    for (var i = 0; i < 12; i++) {
      try {
        await _supabase.from('users').upsert(working, onConflict: 'id');
        return;
      } on PostgrestException catch (e) {
        final missingColumn = _extractMissingColumn(e.message);
        if (missingColumn == null || !working.containsKey(missingColumn)) {
          rethrow;
        }
        working.remove(missingColumn);
      }
    }

    throw Exception('Failed to save user after removing unsupported columns');
  }

  Future<void> _updateUserWithPrunedColumns(
    String userId,
    Map<String, dynamic> payload,
  ) async {
    final working = Map<String, dynamic>.from(payload);

    for (var i = 0; i < 12; i++) {
      try {
        await _supabase.from('users').update(working).eq('id', userId);
        return;
      } on PostgrestException catch (e) {
        final missingColumn = _extractMissingColumn(e.message);
        if (missingColumn == null || !working.containsKey(missingColumn)) {
          rethrow;
        }
        working.remove(missingColumn);
      }
    }

    throw Exception('Failed to update user after removing unsupported columns');
  }

  Future<Map<String, dynamic>> _insertProjectWithPrunedColumns(
    Map<String, dynamic> payload,
  ) async {
    return _insertWithPrunedColumns('projects', payload);
  }

  Future<void> _updateProjectWithPrunedColumns(
    String projectId,
    Map<String, dynamic> payload,
  ) async {
    await _updateWithPrunedColumns('projects', projectId, payload);
  }

  Future<Map<String, dynamic>> _insertWithPrunedColumns(
    String table,
    Map<String, dynamic> payload,
  ) async {
    final working = Map<String, dynamic>.from(payload);

    for (var i = 0; i < 16; i++) {
      try {
        return await _supabase.from(table).insert(working).select().single();
      } on PostgrestException catch (e) {
        final missingColumn = _extractMissingColumn(e.message);
        if (missingColumn == null || !working.containsKey(missingColumn)) {
          rethrow;
        }
        debugPrint(
          'Pruned unsupported column "$missingColumn" from $table payload',
        );
        working.remove(missingColumn);
      }
    }

    throw Exception(
      'Failed to insert into $table after removing unsupported columns',
    );
  }

  Future<void> _updateWithPrunedColumns(
    String table,
    String id,
    Map<String, dynamic> payload,
  ) async {
    final working = Map<String, dynamic>.from(payload);

    for (var i = 0; i < 16; i++) {
      try {
        await _supabase.from(table).update(working).eq('id', id);
        return;
      } on PostgrestException catch (e) {
        final missingColumn = _extractMissingColumn(e.message);
        if (missingColumn == null || !working.containsKey(missingColumn)) {
          rethrow;
        }
        debugPrint(
          'Pruned unsupported column "$missingColumn" from $table payload',
        );
        working.remove(missingColumn);
      }
    }

    throw Exception(
      'Failed to update $table after removing unsupported columns',
    );
  }

  Map<String, dynamic> _toLegacyUserKeys(Map<String, dynamic> input) {
    final mapped = <String, dynamic>{};
    const keyMap = {
      'display_name': 'displayName',
      'photo_url': 'photoURL',
      'user_type': 'userType',
      'hourly_rate': 'hourlyRate',
      'completed_projects': 'completedProjects',
      'total_earnings': 'totalEarnings',
      'total_reviews': 'totalReviews',
      'created_at': 'createdAt',
      'updated_at': 'updatedAt',
    };

    for (final entry in input.entries) {
      final key = keyMap[entry.key] ?? entry.key;
      mapped[key] = entry.value;
    }
    return mapped;
  }

  /// Create or update user profile
  Future<void> saveUser(UserModel user) async {
    final payload = user.toMap();
    try {
      await _upsertUserWithPrunedColumns(payload);
    } on PostgrestException catch (e) {
      // Fallback for projects still using camelCase columns.
      if (e.message.contains("Could not find") &&
          e.message.contains("column")) {
        final legacyPayload = _toLegacyUserKeys(payload);
        await _upsertUserWithPrunedColumns(legacyPayload);
      } else {
        rethrow;
      }
    }
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return UserModel.fromMap(data, userId);
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('email', email.trim().toLowerCase())
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      return UserModel.fromMap(data, data['id'] as String);
    } catch (e) {
      debugPrint('Error fetching user by email: $e');
      return null;
    }
  }

  /// Stream user data for real-time updates
  Stream<UserModel?> streamUser(String userId) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) {
          if (data.isEmpty) return null;
          return UserModel.fromMap(data.first, userId);
        });
  }

  /// Get all mentors with optional skill filter
  Future<List<UserModel>> getMentors({List<String>? skills}) async {
    try {
      var query = _supabase.from('users').select().eq('user_type', 'mentor');

      final data = await query;
      return (data as List)
          .map((item) => UserModel.fromMap(item, item['id']))
          .toList();
    } catch (e) {
      debugPrint('Error fetching mentors: $e');
      return [];
    }
  }

  // ==================== MENTOR GIG OPERATIONS ====================

  Future<String> createMentorGig(MentorGigModel gig) async {
    final response = await _insertWithPrunedColumns('mentor_gigs', gig.toMap());
    return response['id'] as String;
  }

  Future<void> updateMentorGig(
    String gigId,
    Map<String, dynamic> updates,
  ) async {
    final payload = <String, dynamic>{
      ...updates,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await _updateWithPrunedColumns('mentor_gigs', gigId, payload);
  }

  Future<void> deleteMentorGig(String gigId) async {
    await _supabase.from('mentor_gigs').delete().eq('id', gigId);
  }

  Stream<List<MentorGigModel>> streamMentorGigs(String mentorId) {
    return (() async* {
      yield await _fetchMentorGigs(mentorId);

      try {
        yield* _supabase
            .from('mentor_gigs')
            .stream(primaryKey: ['id'])
            .eq('mentor_id', mentorId)
            .order('created_at', ascending: false)
            .map((rows) {
              return (rows as List)
                  .map((item) => MentorGigModel.fromMap(item, item['id']))
                  .toList();
            });
      } catch (e) {
        debugPrint(
          'Mentor gigs realtime stream failed, using polling fallback: $e',
        );
        yield* Stream.periodic(
          const Duration(seconds: 12),
        ).asyncMap((_) => _fetchMentorGigs(mentorId));
      }
    })();
  }

  Stream<List<MentorGigModel>> streamPublicMentorGigs() {
    return (() async* {
      yield await _fetchPublicMentorGigs();

      try {
        yield* _supabase.from('mentor_gigs').stream(primaryKey: ['id']).map((
          rows,
        ) {
          final list = (rows as List)
              .map((item) => MentorGigModel.fromMap(item, item['id']))
              .where((gig) => gig.isActive)
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
      } catch (e) {
        debugPrint(
          'Public mentor gigs realtime stream failed, using polling fallback: $e',
        );
        yield* Stream.periodic(
          const Duration(seconds: 12),
        ).asyncMap((_) => _fetchPublicMentorGigs());
      }
    })();
  }

  Future<List<MentorGigModel>> _fetchPublicMentorGigs() async {
    try {
      final rows = await _supabase
          .from('mentor_gigs')
          .select()
          .order('created_at', ascending: false);

      return (rows as List)
          .map((item) => MentorGigModel.fromMap(item, item['id']))
          .where((gig) => gig.isActive)
          .toList();
    } catch (e) {
      debugPrint('Error fetching public mentor gigs: $e');
      return [];
    }
  }

  Future<List<MentorGigModel>> _fetchMentorGigs(String mentorId) async {
    try {
      final rows = await _supabase
          .from('mentor_gigs')
          .select()
          .eq('mentor_id', mentorId)
          .order('created_at', ascending: false);

      return (rows as List)
          .map((item) => MentorGigModel.fromMap(item, item['id']))
          .toList();
    } catch (e) {
      debugPrint('Error fetching mentor gigs: $e');
      return [];
    }
  }

  Stream<Set<String>> streamSavedGigIds(String userId) {
    return (() async* {
      yield await _fetchSavedGigIds(userId);

      try {
        yield* _supabase
            .from('saved_gigs')
            .stream(primaryKey: ['id'])
            .eq('user_id', userId)
            .map((rows) => _mapSavedGigIds(rows as List));
      } catch (e) {
        debugPrint(
          'Saved gigs realtime stream failed, using polling fallback: $e',
        );
        yield* Stream.periodic(
          const Duration(seconds: 8),
        ).asyncMap((_) => _fetchSavedGigIds(userId));
      }
    })();
  }

  Set<String> _mapSavedGigIds(List rows) {
    final ids = <String>{};
    for (final item in rows) {
      final row = item as Map<String, dynamic>;
      final id =
          (row['gig_id'] ??
                  row['project_id'] ??
                  row['item_id'] ??
                  row['projectId'])
              ?.toString();
      if (id != null && id.trim().isNotEmpty) {
        ids.add(id.trim());
      }
    }
    return ids;
  }

  Future<Set<String>> _fetchSavedGigIds(String userId) async {
    try {
      final rows = await _supabase
          .from('saved_gigs')
          .select()
          .eq('user_id', userId)
          .order('saved_at', ascending: false);
      return _mapSavedGigIds(rows as List);
    } on PostgrestException {
      try {
        final rows = await _supabase
            .from('saved_gigs')
            .select()
            .eq('userId', userId)
            .order('savedAt', ascending: false);
        return _mapSavedGigIds(rows as List);
      } catch (e) {
        debugPrint('Error fetching saved gigs: $e');
        return <String>{};
      }
    } catch (e) {
      debugPrint('Error fetching saved gigs: $e');
      return <String>{};
    }
  }

  Future<bool> isGigSaved({
    required String userId,
    required String gigId,
  }) async {
    final ids = await _fetchSavedGigIds(userId);
    return ids.contains(gigId);
  }

  Future<bool> toggleSavedGig({
    required String userId,
    required String gigId,
    required String gigTitle,
  }) async {
    final isSaved = await isGigSaved(userId: userId, gigId: gigId);
    if (isSaved) {
      await removeSavedGig(userId: userId, gigId: gigId);
      return false;
    }

    final payload = <String, dynamic>{
      'user_id': userId,
      'project_id': gigId,
      'project_title': gigTitle,
      'saved_at': DateTime.now().toIso8601String(),
    };

    try {
      await _insertWithPrunedColumns('saved_gigs', payload);
    } on PostgrestException {
      final legacyPayload = <String, dynamic>{
        'userId': userId,
        'projectId': gigId,
        'projectTitle': gigTitle,
        'savedAt': DateTime.now().toIso8601String(),
      };
      await _insertWithPrunedColumns('saved_gigs', legacyPayload);
    }

    return true;
  }

  Future<void> removeSavedGig({
    required String userId,
    required String gigId,
  }) async {
    try {
      await _supabase
          .from('saved_gigs')
          .delete()
          .eq('user_id', userId)
          .eq('project_id', gigId);
      return;
    } on PostgrestException {
      try {
        await _supabase
            .from('saved_gigs')
            .delete()
            .eq('user_id', userId)
            .eq('gig_id', gigId);
        return;
      } on PostgrestException {
        await _supabase
            .from('saved_gigs')
            .delete()
            .eq('userId', userId)
            .eq('projectId', gigId);
      }
    }
  }

  /// Get users by role with optional exclusion.
  Future<List<UserModel>> getUsersByType(
    String userType, {
    String? excludeUserId,
  }) async {
    try {
      dynamic query = _supabase
          .from('users')
          .select()
          .eq('user_type', userType);

      if (excludeUserId != null && excludeUserId.isNotEmpty) {
        query = query.neq('id', excludeUserId);
      }

      final data = await query;
      return (data as List)
          .map((item) => UserModel.fromMap(item, item['id']))
          .toList();
    } catch (e) {
      debugPrint('Error fetching users by type: $e');
      return [];
    }
  }

  /// Update user rating
  Future<void> updateUserRating(
    String userId,
    double newRating,
    int completedProjects,
  ) async {
    await _supabase
        .from('users')
        .update({
          'rating': newRating,
          'completed_projects': completedProjects,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  /// Update user profile
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    final payload = <String, dynamic>{
      ...updates,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await _updateUserWithPrunedColumns(userId, payload);
    } on PostgrestException catch (e) {
      // Fallback for projects still using camelCase columns.
      if (e.message.contains("Could not find") &&
          e.message.contains("column")) {
        final legacyPayload = _toLegacyUserKeys(payload);
        await _updateUserWithPrunedColumns(userId, legacyPayload);
      } else {
        rethrow;
      }
    }
  }

  // ==================== PROJECT OPERATIONS ====================

  /// Create new project
  Future<String> createProject(ProjectModel project) async {
    final response = await _insertProjectWithPrunedColumns(project.toMap());
    return response['id'] as String;
  }

  /// Get project by ID
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final data = await _supabase
          .from('projects')
          .select()
          .eq('id', projectId)
          .maybeSingle();

      if (data == null) return null;
      return ProjectModel.fromMap(data, projectId);
    } catch (e) {
      debugPrint('Error fetching project: $e');
      return null;
    }
  }

  /// Update project
  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> updates,
  ) async {
    final payload = <String, dynamic>{
      ...updates,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await _updateProjectWithPrunedColumns(projectId, payload);
  }

  /// Stream a single project in realtime.
  Stream<ProjectModel?> streamProject(String projectId) {
    return _supabase
        .from('projects')
        .stream(primaryKey: ['id'])
        .eq('id', projectId)
        .map((rows) {
          if (rows.isEmpty) return null;
          final row = rows.first;
          return ProjectModel.fromMap(row, projectId);
        });
  }

  /// Mentor submits delivery for client review.
  Future<void> submitOrderDelivery({
    required String projectId,
    required String mentorId,
    String? deliveryNote,
  }) async {
    final project = await getProject(projectId);
    if (project == null) throw Exception('Project not found');

    await updateProject(projectId, {
      'status': 'delivered',
      'progress': 100,
      'delivered_at': DateTime.now().toIso8601String(),
      if (deliveryNote != null && deliveryNote.trim().isNotEmpty)
        'delivery_note': deliveryNote.trim(),
    });

    await createNotification(
      NotificationModel(
        id: '',
        userId: project.clientId,
        type: 'order_delivery',
        title: 'Delivery Submitted',
        message:
            'Your order "${project.title}" was delivered and is ready for review.',
        data: {
          'project_id': projectId,
          'action': 'open_order',
          'status': 'delivered',
          'from_user_id': mentorId,
        },
      ),
    );

    await createOrderEvent(
      projectId: projectId,
      eventType: 'delivery_submitted',
      actorId: mentorId,
      note: deliveryNote,
    );
  }

  /// Client approves delivery and completes the order.
  Future<void> approveOrderDelivery({
    required String projectId,
    required String clientId,
  }) async {
    final project = await getProject(projectId);
    if (project == null) throw Exception('Project not found');

    await updateProject(projectId, {
      'status': 'completed',
      'progress': 100,
      'completed_at': DateTime.now().toIso8601String(),
    });

    final mentorId = project.mentorId;
    if (mentorId != null && mentorId.isNotEmpty) {
      await createNotification(
        NotificationModel(
          id: '',
          userId: mentorId,
          type: 'order_completed',
          title: 'Order Approved',
          message: 'Client approved "${project.title}". Order completed.',
          data: {
            'project_id': projectId,
            'action': 'open_order',
            'status': 'completed',
            'from_user_id': clientId,
          },
        ),
      );

      await createOrderEvent(
        projectId: projectId,
        eventType: 'delivery_approved',
        actorId: clientId,
      );
    }
  }

  /// Client requests revision and re-opens progress.
  Future<void> requestOrderRevision({
    required String projectId,
    required String clientId,
    String? revisionNote,
  }) async {
    final project = await getProject(projectId);
    if (project == null) throw Exception('Project not found');

    await updateProject(projectId, {
      'status': 'in-progress',
      'progress': project.progress > 90 ? 90 : project.progress,
      'revision_requested_at': DateTime.now().toIso8601String(),
      if (revisionNote != null && revisionNote.trim().isNotEmpty)
        'revision_note': revisionNote.trim(),
    });

    final mentorId = project.mentorId;
    if (mentorId != null && mentorId.isNotEmpty) {
      await createNotification(
        NotificationModel(
          id: '',
          userId: mentorId,
          type: 'order_revision',
          title: 'Revision Requested',
          message: 'Client requested changes for "${project.title}".',
          data: {
            'project_id': projectId,
            'action': 'open_order',
            'status': 'in-progress',
            'from_user_id': clientId,
            if (revisionNote != null && revisionNote.trim().isNotEmpty)
              'revision_note': revisionNote.trim(),
          },
        ),
      );

      await createOrderEvent(
        projectId: projectId,
        eventType: 'revision_requested',
        actorId: clientId,
        note: revisionNote,
      );
    }
  }

  /// Stream order events as timeline entries.
  Stream<List<OrderEventModel>> streamOrderEvents(String projectId) {
    return _supabase
        .from('order_events')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('created_at', ascending: false)
        .map((rows) {
          return rows
              .map((row) => OrderEventModel.fromMap(row, row['id'].toString()))
              .toList();
        });
  }

  /// Create a timeline event for project lifecycle transitions.
  Future<void> createOrderEvent({
    required String projectId,
    required String eventType,
    required String actorId,
    String? note,
  }) async {
    final payload = OrderEventModel(
      id: '',
      projectId: projectId,
      eventType: eventType,
      actorId: actorId,
      note: note,
    ).toMap();

    await _insertWithPrunedColumns('order_events', payload);
  }

  /// Get projects by client
  Stream<List<ProjectModel>> streamClientProjects(String clientId) {
    return (() async* {
      // Always provide initial data, even if realtime subscription times out.
      yield await _fetchClientProjects(clientId);

      try {
        yield* _supabase
            .from('projects')
            .stream(primaryKey: ['id'])
            .eq('client_id', clientId)
            .order('created_at', ascending: false)
            .map((data) => _mapProjects(data as List<dynamic>));
      } catch (e) {
        debugPrint(
          'Client project realtime stream failed, using polling fallback: $e',
        );
        yield* Stream.periodic(
          const Duration(seconds: 12),
        ).asyncMap((_) => _fetchClientProjects(clientId));
      }
    })();
  }

  /// Get projects by freelancer
  Stream<List<ProjectModel>> streamFreelancerProjects(String freelancerId) {
    return (() async* {
      // Always provide initial data, even if realtime subscription times out.
      yield await _fetchFreelancerProjects(freelancerId);

      try {
        yield* _supabase
            .from('projects')
            .stream(primaryKey: ['id'])
            .eq('freelancer_id', freelancerId)
            .order('created_at', ascending: false)
            .map((data) => _mapProjects(data as List<dynamic>));
      } catch (e) {
        debugPrint(
          'Freelancer project realtime stream failed, using polling fallback: $e',
        );
        yield* Stream.periodic(
          const Duration(seconds: 12),
        ).asyncMap((_) => _fetchFreelancerProjects(freelancerId));
      }
    })();
  }

  // ==================== COURSE OPERATIONS ====================

  Future<String> createCourse(CourseModel course) async {
    final response = await _insertWithPrunedColumns('courses', course.toMap());
    return response['id'] as String;
  }

  Future<void> updateCourse(
    String courseId,
    Map<String, dynamic> updates,
  ) async {
    final payload = <String, dynamic>{
      ...updates,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await _updateWithPrunedColumns('courses', courseId, payload);
  }

  Future<void> deleteCourse(String courseId) async {
    await _supabase.from('courses').delete().eq('id', courseId);
  }

  Future<CourseModel?> getCourse(String courseId) async {
    try {
      final data = await _supabase
          .from('courses')
          .select()
          .eq('id', courseId)
          .maybeSingle();
      if (data == null) return null;
      return CourseModel.fromMap(data, courseId);
    } catch (e) {
      debugPrint('Error fetching course: $e');
      return null;
    }
  }

  Stream<List<CourseModel>> streamMentorCourses(String mentorId) {
    return (() async* {
      yield await _fetchMentorCourses(mentorId);

      try {
        yield* _supabase
            .from('courses')
            .stream(primaryKey: ['id'])
            .eq('mentor_id', mentorId)
            .order('created_at', ascending: false)
            .map((rows) {
              return rows
                  .map((row) => CourseModel.fromMap(row, row['id'].toString()))
                  .toList();
            });
      } catch (e) {
        debugPrint(
          'Mentor courses realtime stream failed, using polling fallback: $e',
        );
        yield* Stream.periodic(
          const Duration(seconds: 12),
        ).asyncMap((_) => _fetchMentorCourses(mentorId));
      }
    })();
  }

  Stream<List<CourseModel>> streamPublicCourses() {
    return (() async* {
      yield await _fetchPublicCourses();

      try {
        yield* _supabase.from('courses').stream(primaryKey: ['id']).map((rows) {
          final list = rows
              .map((row) => CourseModel.fromMap(row, row['id'].toString()))
              .where((course) => course.isPublished)
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
      } catch (e) {
        debugPrint(
          'Public courses realtime stream failed, using polling fallback: $e',
        );
        yield* Stream.periodic(
          const Duration(seconds: 12),
        ).asyncMap((_) => _fetchPublicCourses());
      }
    })();
  }

  Future<bool> isClientEnrolled({
    required String courseId,
    required String clientId,
  }) async {
    try {
      final data = await _supabase
          .from('enrollments')
          .select('id')
          .eq('course_id', courseId)
          .eq('client_id', clientId)
          .maybeSingle();
      return data != null;
    } catch (_) {
      return false;
    }
  }

  Future<String> enrollInCourse({
    required String courseId,
    required String clientId,
    required String mentorId,
  }) async {
    final payload = CourseEnrollmentModel(
      id: '',
      courseId: courseId,
      clientId: clientId,
      mentorId: mentorId,
      progressPercent: 0,
    ).toMap();

    final response = await _insertWithPrunedColumns('enrollments', payload);
    return response['id'] as String;
  }

  Stream<List<CourseEnrollmentModel>> streamClientEnrollments(String clientId) {
    return (() async* {
      yield await _fetchClientEnrollments(clientId);

      try {
        yield* _supabase
            .from('enrollments')
            .stream(primaryKey: ['id'])
            .eq('client_id', clientId)
            .order('created_at', ascending: false)
            .map((rows) {
              return rows
                  .map(
                    (row) => CourseEnrollmentModel.fromMap(
                      row,
                      row['id'].toString(),
                    ),
                  )
                  .toList();
            });
      } catch (e) {
        debugPrint(
          'Client enrollments realtime stream failed, using polling fallback: $e',
        );
        yield* Stream.periodic(
          const Duration(seconds: 12),
        ).asyncMap((_) => _fetchClientEnrollments(clientId));
      }
    })();
  }

  Stream<List<EnrolledCourseItemModel>> streamClientEnrolledCourses(
    String clientId,
  ) {
    return (() async* {
      yield await _fetchClientEnrolledCourses(clientId);

      try {
        yield* _supabase
            .from('enrollments')
            .stream(primaryKey: ['id'])
            .eq('client_id', clientId)
            .map((_) => _fetchClientEnrolledCourses(clientId))
            .asyncMap((future) => future);
      } catch (e) {
        debugPrint(
          'Client enrolled courses stream failed, using polling fallback: $e',
        );
        yield* Stream.periodic(
          const Duration(seconds: 12),
        ).asyncMap((_) => _fetchClientEnrolledCourses(clientId));
      }
    })();
  }

  Stream<List<Map<String, dynamic>>> streamMentorCourseStudents(
    String mentorId,
  ) {
    return (() async* {
      yield await _fetchMentorCourseStudents(mentorId);

      // Uses periodic fallback because this view aggregates courses + enrollments + users.
      yield* Stream.periodic(
        const Duration(seconds: 12),
      ).asyncMap((_) => _fetchMentorCourseStudents(mentorId));
    })();
  }

  Future<void> updateEnrollmentProgress({
    required String enrollmentId,
    required double progressPercent,
  }) async {
    final clamped = progressPercent.clamp(0, 100);
    await _updateWithPrunedColumns('enrollments', enrollmentId, {
      'progress_percent': clamped,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Send message
  Future<String> sendMessage(MessageModel message) async {
    final response = await _insertWithPrunedColumns(
      'messages',
      message.toMap(),
    );
    return response['id'] as String;
  }

  /// Get chat messages
  Stream<List<MessageModel>> streamChatMessages(
    String conversationId, {
    int limit = 50,
  }) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .limit(limit)
        .map((data) {
          return (data as List)
              .map((item) => MessageModel.fromMap(item, item['id']))
              .toList();
        });
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  /// Create notification
  Future<void> createNotification(NotificationModel notification) async {
    await _insertWithPrunedColumns('notifications', notification.toMap());
  }

  /// Get user notifications
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _supabase.from('notifications').stream(primaryKey: ['id']).map((
      data,
    ) {
      final filtered =
          (data as List).where((item) {
            final row = item as Map<String, dynamic>;
            final rowUserId = row['user_id'] ?? row['userId'];
            return rowUserId == userId;
          }).toList()..sort((a, b) {
            final aRaw =
                (a as Map<String, dynamic>)['created_at'] ?? (a)['createdAt'];
            final bRaw =
                (b as Map<String, dynamic>)['created_at'] ?? (b)['createdAt'];
            final aTime =
                DateTime.tryParse(aRaw?.toString() ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final bTime =
                DateTime.tryParse(bRaw?.toString() ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });

      return filtered
          .map((item) => NotificationModel.fromMap(item, item['id']))
          .toList();
    });
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } on PostgrestException {
      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
    }
  }

  /// Mark all notifications as read for a user.
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } on PostgrestException {
      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('user_id', userId)
          .eq('read', false);
    }
  }

  // ==================== PAYMENT OPERATIONS ====================

  /// Create payment
  Future<String> createPayment(PaymentModel payment) async {
    final response = await _insertWithPrunedColumns(
      'payments',
      payment.toMap(),
    );
    return response['id'] as String;
  }

  /// Get payment by ID
  Future<PaymentModel?> getPayment(String paymentId) async {
    try {
      final data = await _supabase
          .from('payments')
          .select()
          .eq('id', paymentId)
          .maybeSingle();

      if (data == null) return null;
      return PaymentModel.fromMap(data, paymentId);
    } catch (e) {
      debugPrint('Error fetching payment: $e');
      return null;
    }
  }

  /// Get user payments
  Stream<List<PaymentModel>> streamUserPayments(String userId) {
    return _supabase.from('payments').stream(primaryKey: ['id']).map((data) {
      final filtered = (data as List).where((item) {
        final row = item as Map<String, dynamic>;
        final rowUserId = row['user_id'] ?? row['userId'];
        final fromUserId = row['from_user_id'] ?? row['fromUserId'];
        final toUserId = row['to_user_id'] ?? row['toUserId'];
        return rowUserId == userId ||
            fromUserId == userId ||
            toUserId == userId;
      }).toList();

      return filtered
          .map((item) => PaymentModel.fromMap(item, item['id']))
          .toList();
    });
  }

  // ==================== DISPUTE OPERATIONS ====================

  /// Create dispute
  Future<String> createDispute(DisputeModel dispute) async {
    final response = await _insertWithPrunedColumns(
      'disputes',
      dispute.toMap(),
    );
    return response['id'] as String;
  }

  /// Get dispute by ID
  Future<DisputeModel?> getDispute(String disputeId) async {
    try {
      final data = await _supabase
          .from('disputes')
          .select()
          .eq('id', disputeId)
          .maybeSingle();

      if (data == null) return null;
      return DisputeModel.fromMap(data, disputeId);
    } catch (e) {
      debugPrint('Error fetching dispute: $e');
      return null;
    }
  }

  // ==================== REVIEW OPERATIONS ====================

  /// Create review
  Future<String> createReview(ReviewModel review) async {
    final response = await _insertWithPrunedColumns('reviews', review.toMap());
    return response['id'] as String;
  }

  /// Get reviews for user
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      final data = await _supabase
          .from('reviews')
          .select()
          .eq('reviewed_user_id', userId);

      return (data as List)
          .map((item) => ReviewModel.fromMap(item, item['id']))
          .toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  Stream<List<ReviewModel>> streamProjectReviews(String projectId) {
    return _supabase.from('reviews').stream(primaryKey: ['id']).map((rows) {
      return (rows as List)
          .where((row) {
            final map = row as Map<String, dynamic>;
            final pid = (map['project_id'] ?? map['projectId'])?.toString();
            return pid == projectId;
          })
          .map(
            (item) =>
                ReviewModel.fromMap(item as Map<String, dynamic>, item['id']),
          )
          .toList();
    });
  }

  Stream<List<DisputeModel>> streamProjectDisputes(String projectId) {
    return _supabase.from('disputes').stream(primaryKey: ['id']).map((rows) {
      return (rows as List)
          .where((row) {
            final map = row as Map<String, dynamic>;
            final pid = (map['project_id'] ?? map['projectId'])?.toString();
            return pid == projectId;
          })
          .map(
            (item) =>
                DisputeModel.fromMap(item as Map<String, dynamic>, item['id']),
          )
          .toList();
    });
  }

  /// Get average user rating
  Future<double> getUserAverageRating(String userId) async {
    try {
      final data = await _supabase.rpc(
        'get_user_average_rating',
        params: {'user_id': userId},
      );

      return (data as num).toDouble();
    } catch (e) {
      debugPrint('Error fetching average rating: $e');
      return 0.0;
    }
  }

  // ==================== GENERIC OPERATIONS ====================

  /// Generic query - SELECT
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    dynamic query = _supabase.from(table).select(select?.join(',') ?? '*');

    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return await query;
  }

  /// Generic insertion
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    return _insertWithPrunedColumns(table, data);
  }

  /// Generic update
  Future<void> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _updateWithPrunedColumns(table, id, data);
  }

  /// Generic delete
  Future<void> delete(String table, String id) async {
    await _supabase.from(table).delete().eq('id', id);
  }
}
