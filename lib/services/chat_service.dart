import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final _supabase = Supabase.instance.client;

  Stream<List<Conversation>> getConversationsStream(String userId) {
    return _supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .map((rows) {
          final mapped = rows
              .where((row) => (row['participant_ids'] as List?)?.contains(userId) ?? false)
              .map((row) => _mapConversation(row, userId))
              .toList();
          mapped.sort(
            (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp),
          );
          return mapped;
        });
  }

  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .map((rows) {
          final mapped = rows.map((row) => _mapMessage(row)).toList();
          mapped.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return mapped;
        });
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String content,
  }) async {
    final now = DateTime.now().toIso8601String();

    await _supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'content': content,
      'read_by': [senderId],
      'is_read': false,
      'created_at': now,
    });

    await _supabase.from('conversations').update({
      'last_message': content,
      'last_message_sender_id': senderId,
      'last_message_timestamp': now,
      'updated_at': now,
    }).eq('id', conversationId);
  }

  ChatMessage _mapMessage(Map<String, dynamic> row) {
    return ChatMessage(
      id: row['id']?.toString() ?? '',
      conversationId: row['conversation_id']?.toString() ?? '',
      senderId: row['sender_id']?.toString() ?? '',
      senderName: row['sender_name']?.toString() ?? '',
      senderAvatar: row['sender_avatar']?.toString() ?? '',
      content: row['content']?.toString() ?? '',
      attachmentUrls: List<String>.from(row['attachment_urls'] ?? const []),
      timestamp: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
      readBy: List<String>.from(row['read_by'] ?? const []),
      isRead: row['is_read'] == true,
    );
  }

  Conversation _mapConversation(Map<String, dynamic> row, String userId) {
    final participantIds = List<String>.from(row['participant_ids'] ?? const []);
    final names = Map<String, String>.from(row['participant_names'] ?? const {});
    final avatars = Map<String, String>.from(row['participant_avatars'] ?? const {});

    final otherUserId = participantIds.firstWhere(
      (id) => id != userId,
      orElse: () => participantIds.isNotEmpty ? participantIds.first : '',
    );

    return Conversation(
      id: row['id']?.toString() ?? '',
      participantIds: participantIds,
      participantNames: otherUserId.isEmpty
          ? names
          : {otherUserId: names[otherUserId] ?? 'Unknown'},
      participantAvatars: otherUserId.isEmpty
          ? avatars
          : {otherUserId: avatars[otherUserId] ?? ''},
      lastMessage: row['last_message']?.toString() ?? '',
      lastMessageTimestamp:
          DateTime.tryParse(row['last_message_timestamp']?.toString() ?? '') ??
          DateTime.now(),
      lastMessageSenderId: row['last_message_sender_id']?.toString() ?? '',
      unreadCount: (row['unread_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
      projectId: row['project_id']?.toString(),
      projectTitle: row['project_title']?.toString(),
    );
  }
}
