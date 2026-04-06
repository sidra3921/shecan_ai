import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final userId = authService.currentUserId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please sign in to view notifications')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () {
              // TODO: Mark all as read
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: firestoreService.streamUserNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'ll be notified about important updates here',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(
                context,
                notification,
                firestoreService,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
    FirestoreService firestoreService,
  ) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    final timeAgo = _getTimeAgo(notification.createdAt);

    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'project':
        icon = Icons.work;
        iconColor = AppColors.primary;
        break;
      case 'message':
        icon = Icons.message;
        iconColor = AppColors.info;
        break;
      case 'payment':
        icon = Icons.payment;
        iconColor = AppColors.success;
        break;
      case 'review':
        icon = Icons.star;
        iconColor = AppColors.warning;
        break;
      case 'dispute':
        icon = Icons.gavel;
        iconColor = AppColors.error;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NotificationCard(
            icon: Icons.person_add,
            iconColor: AppColors.info,
            title: 'A Mentor Joins',
            message:
                'Sarah Johnson just joined as a new mentor specializing in UI/UX Design.',
            time: '2 hours ago',
          ),
          _NotificationCard(
            icon: Icons.check_circle,
            iconColor: AppColors.success,
            title: 'Event/Action Completed',
            message:
                'Your project "Logo Design" has been successfully completed.',
            time: '5 hours ago',
          ),
          _NotificationCard(
            icon: Icons.edit,
            iconColor: AppColors.warning,
            title: 'Photo Editing',
            message:
                'New photo editing request from client requires your attention.',
            time: '1 day ago',
          ),
          _NotificationCard(
            icon: Icons.people,
            iconColor: Colors.purple,
            title: 'SEO Writing',
            message:
                'You have been invited to collaborate on an SEO writing project.',
            time: '2 days ago',
          ),
        ],
      ),
    );
  }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notification.read ? Colors.white : AppColors.pinkBackground.withOpacity(0.3),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: notification.read ? FontWeight.w500 : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: !notification.read
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () async {
          if (!notification.read) {
            await firestoreService.markNotificationAsRead(notification.id);
          }
          // TODO: Navigate based on notification type
        },
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(60, 32),
          ),
          child: const Text('View', style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
