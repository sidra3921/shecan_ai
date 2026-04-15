import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/dispute_model.dart';
import '../models/review_model.dart';

class SupabaseDatabaseService {
  static final SupabaseDatabaseService _instance =
      SupabaseDatabaseService._internal();
  factory SupabaseDatabaseService() => _instance;
  SupabaseDatabaseService._internal();

  final _supabase = Supabase.instance.client;

  List<ProjectModel> _mapProjects(List<dynamic> rows) {
    return rows
        .map((item) => ProjectModel.fromMap(item as Map<String, dynamic>, item['id']))
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

  Future<List<ProjectModel>> _fetchFreelancerProjects(String freelancerId) async {
    final rows = await _supabase
        .from('projects')
        .select()
        .eq('freelancer_id', freelancerId)
        .order('created_at', ascending: false);

    return _mapProjects(rows as List<dynamic>);
  }

  // ==================== USER OPERATIONS ====================

  String? _extractMissingColumn(String message) {
    final match = RegExp(r"Could not find the '([^']+)' column")
        .firstMatch(message);
    return match?.group(1);
  }

  Future<void> _upsertUserWithPrunedColumns(Map<String, dynamic> payload) async {
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
        print('Pruned unsupported column "$missingColumn" from $table payload');
        working.remove(missingColumn);
      }
    }

    throw Exception('Failed to insert into $table after removing unsupported columns');
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
        print('Pruned unsupported column "$missingColumn" from $table payload');
        working.remove(missingColumn);
      }
    }

    throw Exception('Failed to update $table after removing unsupported columns');
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
      if (e.message.contains("Could not find") && e.message.contains("column")) {
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
      print('Error fetching user: $e');
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
      print('Error fetching user by email: $e');
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
      var query = _supabase
          .from('users')
          .select()
          .eq('user_type', 'mentor');

      final data = await query;
      return (data as List)
          .map((item) => UserModel.fromMap(item, item['id']))
          .toList();
    } catch (e) {
      print('Error fetching mentors: $e');
      return [];
    }
  }

  /// Update user rating
  Future<void> updateUserRating(
    String userId,
    double newRating,
    int completedProjects,
  ) async {
    await _supabase.from('users').update({
      'rating': newRating,
      'completed_projects': completedProjects,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
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
      if (e.message.contains("Could not find") && e.message.contains("column")) {
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
      print('Error fetching project: $e');
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
        print('Client project realtime stream failed, using polling fallback: $e');
        yield* Stream.periodic(const Duration(seconds: 12))
            .asyncMap((_) => _fetchClientProjects(clientId));
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
        print('Freelancer project realtime stream failed, using polling fallback: $e');
        yield* Stream.periodic(const Duration(seconds: 12))
            .asyncMap((_) => _fetchFreelancerProjects(freelancerId));
      }
    })();
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Send message
  Future<String> sendMessage(MessageModel message) async {
    final response = await _insertWithPrunedColumns('messages', message.toMap());
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
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) {
          return (data as List)
              .map((item) => NotificationModel.fromMap(item, item['id']))
              .toList();
        });
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  // ==================== PAYMENT OPERATIONS ====================

  /// Create payment
  Future<String> createPayment(PaymentModel payment) async {
    final response = await _insertWithPrunedColumns('payments', payment.toMap());
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
      print('Error fetching payment: $e');
      return null;
    }
  }

  /// Get user payments
  Stream<List<PaymentModel>> streamUserPayments(String userId) {
    return _supabase
        .from('payments')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
          return (data as List)
              .map((item) => PaymentModel.fromMap(item, item['id']))
              .toList();
        });
  }

  // ==================== DISPUTE OPERATIONS ====================

  /// Create dispute
  Future<String> createDispute(DisputeModel dispute) async {
    final response = await _insertWithPrunedColumns('disputes', dispute.toMap());
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
      print('Error fetching dispute: $e');
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
      print('Error fetching reviews: $e');
      return [];
    }
  }

  /// Get average user rating
  Future<double> getUserAverageRating(String userId) async {
    try {
      final data = await _supabase.rpc('get_user_average_rating',
          params: {'user_id': userId});
      
      return (data as num).toDouble();
    } catch (e) {
      print('Error fetching average rating: $e');
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
