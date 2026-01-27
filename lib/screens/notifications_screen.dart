import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;

  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
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
