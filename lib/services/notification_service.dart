import '../models/notification_model.dart';
import 'supabase_database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _db = SupabaseDatabaseService();

  Future<void> initialize() async {}

  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _db.streamUserNotifications(userId);
  }

  Stream<int> streamUnreadCount(String userId) {
    return streamUserNotifications(userId)
        .map((items) => items.where((n) => !n.read).length);
  }

  Future<void> markAsRead(String notificationId) {
    return _db.markNotificationAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) {
    return _db.markAllNotificationsAsRead(userId);
  }

  Future<void> createNotification(NotificationModel notification) {
    return _db.createNotification(notification);
  }
}
