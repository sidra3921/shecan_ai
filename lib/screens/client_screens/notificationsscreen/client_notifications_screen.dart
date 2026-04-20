import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_service.dart';
import '../orderscreen/client_order_detail_screen.dart';

class ClientNotificationsScreen extends StatelessWidget {
  const ClientNotificationsScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final service = NotificationService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: service.streamUserNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load notifications',
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          final notifications = snapshot.data ?? const <NotificationModel>[];
          final unreadCount = notifications.where((n) => !n.read).length;
          final grouped = _groupByDay(notifications);

          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet'),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Live updates',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: unreadCount > 0
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$unreadCount unread',
                        style: TextStyle(
                          color: unreadCount > 0
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (unreadCount > 0)
                      TextButton(
                        onPressed: () async {
                          await service.markAllAsRead(userId);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All notifications marked as read.')),
                          );
                        },
                        child: const Text('Mark all read'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped[index];
                    final header = entry.$1;
                    final items = entry.$2;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 4),
                          child: Text(
                            header,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        ...items.map((item) {
                          final isUnread = !item.read;

                          return InkWell(
                            onTap: () => _handlePrimaryTap(context, service, item),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isUnread
                                      ? AppColors.primary.withValues(alpha: 0.3)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isUnread
                                          ? AppColors.primary
                                          : AppColors.textHint,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.message,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          children: _buildActionChips(
                                            context: context,
                                            service: service,
                                            item: item,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _relativeTime(item.createdAt),
                                          style: const TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<(String, List<NotificationModel>)> _groupByDay(List<NotificationModel> items) {
    final now = DateTime.now();
    final sorted = [...items]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final buckets = <String, List<NotificationModel>>{};

    for (final item in sorted) {
      final t = item.createdAt;
      final header = _dayHeader(now, t);
      buckets.putIfAbsent(header, () => <NotificationModel>[]).add(item);
    }

    return buckets.entries.map((e) => (e.key, e.value)).toList();
  }

  String _dayHeader(DateTime now, DateTime timestamp) {
    final n = DateTime(now.year, now.month, now.day);
    final t = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final diff = n.difference(t).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${t.day}/${t.month}/${t.year}';
  }

  List<Widget> _buildActionChips({
    required BuildContext context,
    required NotificationService service,
    required NotificationModel item,
  }) {
    final chips = <Widget>[];
    final type = item.type.toLowerCase();
    final data = item.data ?? const <String, dynamic>{};
    final projectId = data['project_id']?.toString() ?? data['projectId']?.toString();
    final isOrderNotification =
        type == 'order_delivery' || type == 'order_completed' || type == 'order_revision';

    if (!item.read) {
      chips.add(
        ActionChip(
          label: const Text('Mark Read'),
          onPressed: () async {
            await service.markAsRead(item.id);
          },
        ),
      );
    }

    if (isOrderNotification && projectId != null && projectId.isNotEmpty) {
      chips.add(
        ActionChip(
          label: const Text('Open Order'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClientOrderDetailScreen(
                  userId: userId,
                  projectId: projectId,
                ),
              ),
            );
          },
        ),
      );
    }

    return chips;
  }

  Future<void> _handlePrimaryTap(
    BuildContext context,
    NotificationService service,
    NotificationModel item,
  ) async {
    if (!item.read) {
      await service.markAsRead(item.id);
    }

    final type = item.type.toLowerCase();
    final data = item.data ?? const <String, dynamic>{};
    final projectId = data['project_id']?.toString() ?? data['projectId']?.toString();

    final isOrderNotification =
        type == 'order_delivery' || type == 'order_completed' || type == 'order_revision';

    if (isOrderNotification && projectId != null && projectId.isNotEmpty && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClientOrderDetailScreen(
            userId: userId,
            projectId: projectId,
          ),
        ),
      );
    }
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
