import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Messages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MessageCard(
            name: 'Ayesha Khan',
            message: 'Hi! I wanted to discuss the logo design project.',
            time: '2 min ago',
            unread: true,
          ),
          _MessageCard(
            name: 'Fatima Ali',
            message: 'Thank you for the great work!',
            time: '1 hour ago',
            unread: false,
          ),
          _MessageCard(
            name: 'Sara Ahmed',
            message: 'When can we start the new project?',
            time: '3 hours ago',
            unread: true,
          ),
          _MessageCard(
            name: 'Zainab Malik',
            message: 'The payment has been processed.',
            time: '1 day ago',
            unread: false,
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool unread;

  const _MessageCard({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.pinkBackground,
              child: Icon(Icons.person, color: AppColors.primary, size: 28),
            ),
            if (unread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: unread ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: unread ? AppColors.primary : AppColors.textSecondary,
                fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to chat screen
        },
      ),
    );
  }
}
