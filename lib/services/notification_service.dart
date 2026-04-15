// Firebase Messaging removed - use Supabase push notifications instead
import '../models/notification_model.dart';
import 'firestore_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Firebase Messaging instance removed
  final FirestoreService _firestore = FirestoreService();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // ==================== INITIALIZATION ====================

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    } else {
      print('User declined or has not accepted notification permission');
    }

    // Get FCM token
    _fcmToken = await _messaging.getToken();
    print('FCM Token: $_fcmToken');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('FCM Token refreshed: $newToken');
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  // ==================== MESSAGE HANDLERS ====================

  /// Handle foreground messages (app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }

  /// Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message clicked!');
    print('Message data: ${message.data}');
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  /// Send notification to user
  Future<void> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      type: type,
      title: title,
      message: message,
      data: data,
    );

    await _firestore.createNotification(notification);
  }

  /// Send project notification
  Future<void> sendProjectNotification({
    required String userId,
    required String projectId,
    required String title,
    required String message,
  }) async {
    await sendNotification(
      userId: userId,
      type: 'project',
      title: title,
      message: message,
      data: {'projectId': projectId},
    );
  }

  /// Send message notification
  Future<void> sendMessageNotification({
    required String userId,
    required String chatId,
    required String senderName,
    required String messageText,
  }) async {
    await sendNotification(
      userId: userId,
      type: 'message',
      title: 'New message from $senderName',
      message: messageText,
      data: {'chatId': chatId},
    );
  }

  /// Send payment notification
  Future<void> sendPaymentNotification({
    required String userId,
    required String paymentId,
    required String title,
    required String message,
  }) async {
    await sendNotification(
      userId: userId,
      type: 'payment',
      title: title,
      message: message,
      data: {'paymentId': paymentId},
    );
  }

  /// Send review notification
  Future<void> sendReviewNotification({
    required String userId,
    required String projectId,
    required String reviewerName,
    required double rating,
  }) async {
    await sendNotification(
      userId: userId,
      type: 'review',
      title: 'New review from $reviewerName',
      message: 'You received a ${rating.toStringAsFixed(1)} star rating',
      data: {'projectId': projectId},
    );
  }

  /// Send dispute notification
  Future<void> sendDisputeNotification({
    required String userId,
    required String disputeId,
    required String title,
    required String message,
  }) async {
    await sendNotification(
      userId: userId,
      type: 'dispute',
      title: title,
      message: message,
      data: {'disputeId': disputeId},
    );
  }

  // ==================== NOTIFICATION PREFERENCES ====================

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  /// Update user notification preferences
  Future<void> updateNotificationPreferences({
    required String userId,
    bool? projectNotifications,
    bool? messageNotifications,
    bool? paymentNotifications,
  }) async {
    if (projectNotifications != null) {
      if (projectNotifications) {
        await subscribeToTopic('user_${userId}_projects');
      } else {
        await unsubscribeFromTopic('user_${userId}_projects');
      }
    }

    if (messageNotifications != null) {
      if (messageNotifications) {
        await subscribeToTopic('user_${userId}_messages');
      } else {
        await unsubscribeFromTopic('user_${userId}_messages');
      }
    }

    if (paymentNotifications != null) {
      if (paymentNotifications) {
        await subscribeToTopic('user_${userId}_payments');
      } else {
        await unsubscribeFromTopic('user_${userId}_payments');
      }
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
