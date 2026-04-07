import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/dispute_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== USER OPERATIONS ====================

  /// Create or update user profile
  Future<void> saveUser(UserModel user) async {
    await _db
        .collection('users')
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  /// Stream user data for real-time updates
  Stream<UserModel?> streamUser(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    });
  }

  /// Get all mentors with optional skill filter
  Future<List<UserModel>> getMentors({List<String>? skills}) async {
    Query query = _db
        .collection('users')
        .where('userType', isEqualTo: 'mentor');

    if (skills != null && skills.isNotEmpty) {
      query = query.where('skills', arrayContainsAny: skills);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  /// Update user rating
  Future<void> updateUserRating(
    String userId,
    double newRating,
    int completedProjects,
  ) async {
    await _db.collection('users').doc(userId).update({
      'rating': newRating,
      'completedProjects': completedProjects,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== PROJECT OPERATIONS ====================

  /// Create new project
  Future<String> createProject(ProjectModel project) async {
    final docRef = await _db.collection('projects').add(project.toMap());
    return docRef.id;
  }

  /// Get project by ID
  Future<ProjectModel?> getProject(String projectId) async {
    final doc = await _db.collection('projects').doc(projectId).get();
    if (!doc.exists) return null;
    return ProjectModel.fromMap(doc.data()!, doc.id);
  }

  /// Update project
  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> updates,
  ) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('projects').doc(projectId).update(updates);
  }

  /// Get projects by client
  Stream<List<ProjectModel>> streamClientProjects(
    String clientId, {
    String? status,
  }) {
    Query query = _db
        .collection('projects')
        .where('clientId', isEqualTo: clientId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProjectModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Get projects by mentor
  Stream<List<ProjectModel>> streamMentorProjects(
    String mentorId, {
    String? status,
  }) {
    Query query = _db
        .collection('projects')
        .where('mentorId', isEqualTo: mentorId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProjectModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Get available projects (no mentor assigned)
  Stream<List<ProjectModel>> streamAvailableProjects({List<String>? skills}) {
    Query query = _db
        .collection('projects')
        .where('status', isEqualTo: 'pending');

    if (skills != null && skills.isNotEmpty) {
      query = query.where('skills', arrayContainsAny: skills);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProjectModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Send message
  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    // Update chat metadata
    await _db.collection('chats').doc(chatId).set({
      'participants': [message.senderId, message.receiverId],
      'lastMessage': message.text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount_${message.receiverId}': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Stream messages for a chat
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final messages = await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {'read': true});
    }

    // Reset unread count
    batch.update(_db.collection('chats').doc(chatId), {
      'unreadCount_$userId': 0,
    });

    await batch.commit();
  }

  /// Get chat list for user
  Stream<List<Map<String, dynamic>>> streamUserChats(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['chatId'] = doc.id;
            return data;
          }).toList(),
        );
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  /// Create notification
  Future<void> createNotification(NotificationModel notification) async {
    await _db.collection('notifications').add(notification.toMap());
  }

  /// Get user notifications
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount(String userId) async {
    final snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // ==================== PAYMENT OPERATIONS ====================

  /// Create payment record
  Future<String> createPayment(PaymentModel payment) async {
    final docRef = await _db.collection('payments').add(payment.toMap());
    return docRef.id;
  }

  /// Get user payments
  Stream<List<PaymentModel>> streamUserPayments(String userId) {
    return _db
        .collection('payments')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Update payment status
  Future<void> updatePaymentStatus(String paymentId, String status) async {
    await _db.collection('payments').doc(paymentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Calculate total earnings
  Future<double> calculateTotalEarnings(String userId) async {
    final snapshot = await _db
        .collection('payments')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['amount'] as num).toDouble();
    }
    return total;
  }

  // ==================== DISPUTE OPERATIONS ====================

  /// Create dispute
  Future<String> createDispute(DisputeModel dispute) async {
    final docRef = await _db.collection('disputes').add(dispute.toMap());
    return docRef.id;
  }

  /// Get user disputes
  Stream<List<DisputeModel>> streamUserDisputes(String userId) {
    return _db
        .collection('disputes')
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DisputeModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Update dispute status
  Future<void> updateDisputeStatus(String disputeId, String status) async {
    final updates = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == 'resolved') {
      updates['resolvedAt'] = FieldValue.serverTimestamp();
    }

    await _db.collection('disputes').doc(disputeId).update(updates);
  }

  // ==================== REVIEW OPERATIONS ====================

  /// Create review
  Future<String> createReview(ReviewModel review) async {
    final docRef = await _db.collection('reviews').add(review.toMap());

    // Update user rating (this should be done via Cloud Function in production)
    await _updateUserRatingFromReviews(review.reviewedUserId);

    return docRef.id;
  }

  /// Get user reviews
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    final snapshot = await _db
        .collection('reviews')
        .where('reviewedUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Calculate and update user rating from all reviews
  Future<void> _updateUserRatingFromReviews(String userId) async {
    final reviews = await getUserReviews(userId);

    if (reviews.isEmpty) return;

    double totalRating = 0;
    for (var review in reviews) {
      totalRating += review.rating;
    }

    final avgRating = totalRating / reviews.length;

    await _db.collection('users').doc(userId).update({
      'rating': avgRating,
      'totalReviews': reviews.length,
    });
  }

  // ==================== ANALYTICS ====================

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final usersCount = await _db.collection('users').count().get();
    final projectsCount = await _db.collection('projects').count().get();

    final completedProjects = await _db
        .collection('projects')
        .where('status', isEqualTo: 'completed')
        .count()
        .get();

    return {
      'totalUsers': usersCount.count ?? 0,
      'totalProjects': projectsCount.count ?? 0,
      'completedProjects': completedProjects.count ?? 0,
    };
  }
}
