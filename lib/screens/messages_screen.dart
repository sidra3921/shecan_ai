import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../constants/app_colors.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_database_service.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  String _getChatId(String userId1, String userId2) {
    final users = [userId1, userId2]..sort();
    return '${users[0]}_${users[1]}';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = GetIt.I<SupabaseAuthService>().currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: Text('Please sign in to view messages')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Messages')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: GetIt.I<SupabaseDatabaseService>().query('messages'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger rebuild
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, 
                    size: 64, 
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start a conversation with a mentor or client',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat['otherUserId'] as String;
              final lastMessage = chat['lastMessage'] as String;
              final timestamp = (chat['timestamp'] as DateTime);
              final unreadCount = (chat['unreadCount'] as int?) ?? 0;
              final otherUserName = chat['otherUserName'] as String? ?? 'User';
              final otherUserPhoto = chat['otherUserPhoto'] as String?;

              return _MessageCard(
                name: otherUserName,
                message: lastMessage,
                time: _formatTimestamp(timestamp),
                unread: unreadCount > 0,
                unreadCount: unreadCount,
                photoUrl: otherUserPhoto,
                onTap: () {
                  // Navigate to chat detail screen
                  // You can implement this later
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Chat with $otherUserName'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool unread;
  final int unreadCount;
  final String? photoUrl;
  final VoidCallback onTap;

  const _MessageCard({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    this.unreadCount = 0,
    this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.pinkBackground,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
              child: photoUrl == null 
                ? const Icon(Icons.person, color: AppColors.primary, size: 28)
                : null,
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
            if (unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
