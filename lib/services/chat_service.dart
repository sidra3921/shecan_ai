import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_model.dart';
import '../models/user_model.dart';

class PresenceStatus {
  final bool isOnline;
  final DateTime? lastSeenAt;

  const PresenceStatus({required this.isOnline, this.lastSeenAt});
}

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> _fetchConversationRow(String conversationId) async {
    return await _supabase
        .from('conversations')
        .select()
        .eq('id', conversationId)
        .maybeSingle();
  }

  String? _extractMissingColumn(String message) {
    final match = RegExp("Could not find the '([^']+)' column")
        .firstMatch(message);
    return match?.group(1);
  }

  Future<void> _updateMessageWithPrunedColumns(
    String messageId,
    Map<String, dynamic> payload,
  ) async {
    final working = Map<String, dynamic>.from(payload);

    for (var i = 0; i < 10; i++) {
      try {
        await _supabase.from('messages').update(working).eq('id', messageId);
        return;
      } on PostgrestException catch (e) {
        final missingColumn = _extractMissingColumn(e.message);
        if (missingColumn == null || !working.containsKey(missingColumn)) {
          rethrow;
        }
        working.remove(missingColumn);
      }
    }

    throw Exception('Failed to update message after removing unsupported columns');
  }

  Future<void> _upsertWithPrunedColumns(
    String table,
    Map<String, dynamic> payload,
    String? onConflict,
  ) async {
    final working = Map<String, dynamic>.from(payload);

    for (var i = 0; i < 10; i++) {
      try {
        await _supabase.from(table).upsert(
              working,
              onConflict: onConflict,
            );
        return;
      } on PostgrestException catch (e) {
        final missingColumn = _extractMissingColumn(e.message);
        if (missingColumn == null || !working.containsKey(missingColumn)) {
          rethrow;
        }
        working.remove(missingColumn);
      }
    }

    throw Exception('Failed to upsert into $table after removing unsupported columns');
  }

  Future<void> _insertMessageWithPrunedColumns(Map<String, dynamic> payload) async {
    final working = Map<String, dynamic>.from(payload);

    for (var i = 0; i < 12; i++) {
      try {
        await _supabase.from('messages').insert(working);
        return;
      } on PostgrestException catch (e) {
        final missingColumn = _extractMissingColumn(e.message);
        if (missingColumn == null || !working.containsKey(missingColumn)) {
          rethrow;
        }
        working.remove(missingColumn);
      }
    }

    throw Exception('Failed to send message after removing unsupported columns');
  }

  Future<void> _updateConversationWithPrunedColumns(
    String conversationId,
    Map<String, dynamic> payload,
  ) async {
    final working = Map<String, dynamic>.from(payload);

    for (var i = 0; i < 8; i++) {
      try {
        await _supabase.from('conversations').update(working).eq('id', conversationId);
        return;
      } on PostgrestException catch (e) {
        final missingColumn = _extractMissingColumn(e.message);
        if (missingColumn == null || !working.containsKey(missingColumn)) {
          rethrow;
        }
        working.remove(missingColumn);
      }
    }

    throw Exception('Failed to update conversation after removing unsupported columns');
  }

  Stream<List<Conversation>> getConversationsStream(String userId) {
    return (() async* {
      // Always emit initial data so UI does not fail-hard on first render.
      yield await _fetchConversationsSnapshot(userId);

      try {
        yield* _supabase
            .from('conversations')
            .stream(primaryKey: ['id'])
            .map((rows) => _mapConversations(rows, userId));
      } catch (_) {
        yield* Stream.periodic(const Duration(seconds: 12))
            .asyncMap((_) => _fetchConversationsSnapshot(userId));
      }
    })();
  }

  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return (() async* {
      yield await _fetchMessagesSnapshot(conversationId);

      try {
        yield* _supabase
            .from('messages')
            .stream(primaryKey: ['id'])
            .eq('conversation_id', conversationId)
            .map((rows) {
              final mapped = rows.map((row) => _mapMessage(row)).toList();
              mapped.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              return mapped;
            });
      } catch (_) {
        yield* Stream.periodic(const Duration(seconds: 8))
            .asyncMap((_) => _fetchMessagesSnapshot(conversationId));
      }
    })();
  }

  List<Conversation> _mapConversations(List<Map<String, dynamic>> rows, String userId) {
    final mapped = rows
        .where((row) => (row['participant_ids'] as List?)?.contains(userId) ?? false)
        .map((row) => _mapConversation(row, userId))
        .toList();
    mapped.sort((a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
    return mapped;
  }

  Future<List<Conversation>> _fetchConversationsSnapshot(String userId) async {
    try {
      final rows = await _supabase.from('conversations').select();
      final list = (rows as List).cast<Map<String, dynamic>>();
      return _mapConversations(list, userId);
    } catch (_) {
      return const [];
    }
  }

  Future<List<ChatMessage>> _fetchMessagesSnapshot(String conversationId) async {
    try {
      final rows = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false);
      final mapped = (rows as List)
          .cast<Map<String, dynamic>>()
          .map((row) => _mapMessage(row))
          .toList();
      mapped.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return mapped;
    } catch (_) {
      return const [];
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String content,
  }) async {
    final now = DateTime.now().toIso8601String();

    final conversation = await _supabase
        .from('conversations')
        .select('participant_ids')
        .eq('id', conversationId)
        .maybeSingle();

    final participantIds = List<String>.from(
      (conversation?['participant_ids'] as List?) ?? const [],
    );

    final receiverId = participantIds.firstWhere(
      (id) => id != senderId,
      orElse: () => '',
    );
    final isDirectConversation = participantIds.length == 2;

    await _insertMessageWithPrunedColumns({
      'conversation_id': conversationId,
      'sender_id': senderId,
      if (isDirectConversation && receiverId.isNotEmpty) 'receiver_id': receiverId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'content': content,
      'read_by': [senderId],
      'is_read': false,
      'created_at': now,
    });

    await _updateConversationWithPrunedColumns(conversationId, {
      'last_message': content,
      'last_message_sender_id': senderId,
      'last_message_timestamp': now,
      'updated_at': now,
    });
  }

  Future<void> markConversationAsRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    final rows = await _supabase
        .from('messages')
        .select('id,sender_id,read_by,is_read')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .limit(100);

    final now = DateTime.now().toIso8601String();

    for (final raw in (rows as List)) {
      final row = raw as Map<String, dynamic>;
      final senderId = row['sender_id']?.toString() ?? '';
      if (senderId.isEmpty || senderId == currentUserId) continue;

      final readBy = List<String>.from(row['read_by'] ?? const []);
      if (readBy.contains(currentUserId)) continue;

      readBy.add(currentUserId);
      await _updateMessageWithPrunedColumns(
        row['id'].toString(),
        {
          'read_by': readBy,
          'is_read': true,
          'seen_at': now,
        },
      );
    }
  }

  Future<void> setTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) async {
    await _upsertWithPrunedColumns(
      'typing_indicators',
      {
        'conversation_id': conversationId,
        'user_id': userId,
        'is_typing': isTyping,
        'updated_at': DateTime.now().toIso8601String(),
      },
      'conversation_id,user_id',
    );
  }

  Stream<bool> streamTypingStatus({
    required String conversationId,
    required String otherUserId,
  }) {
    return (() async* {
      yield await _fetchTypingState(conversationId, otherUserId);
      try {
        yield* _supabase
            .from('typing_indicators')
            .stream(primaryKey: ['conversation_id', 'user_id'])
            .eq('conversation_id', conversationId)
            .map((rows) {
              final match = rows.cast<Map<String, dynamic>>().firstWhere(
                    (row) => row['user_id']?.toString() == otherUserId,
                    orElse: () => const <String, dynamic>{},
                  );
              if (match.isEmpty) return false;
              return match['is_typing'] == true;
            });
      } catch (_) {
        yield* Stream.periodic(const Duration(seconds: 3)).asyncMap(
          (_) => _fetchTypingState(conversationId, otherUserId),
        );
      }
    })();
  }

  Stream<List<String>> streamTypingUsers({
    required String conversationId,
    required String currentUserId,
    required Map<String, String> participantNames,
  }) {
    return (() async* {
      yield await _fetchTypingUsers(conversationId, currentUserId, participantNames);
      try {
        yield* _supabase
            .from('typing_indicators')
            .stream(primaryKey: ['conversation_id', 'user_id'])
            .eq('conversation_id', conversationId)
            .map((rows) {
              final active = rows
                  .cast<Map<String, dynamic>>()
                  .where((row) {
                    final isTyping = row['is_typing'] == true;
                    final userId = row['user_id']?.toString() ?? '';
                    if (!isTyping || userId.isEmpty || userId == currentUserId) {
                      return false;
                    }
                    final updatedAt = DateTime.tryParse(row['updated_at']?.toString() ?? '');
                    if (updatedAt == null) return false;
                    return DateTime.now().difference(updatedAt).inSeconds <= 8;
                  })
                  .map((row) {
                    final userId = row['user_id']?.toString() ?? '';
                    return participantNames[userId] ?? 'Member';
                  })
                  .toSet()
                  .toList();

              return active;
            });
      } catch (_) {
        yield* Stream.periodic(const Duration(seconds: 3)).asyncMap(
          (_) => _fetchTypingUsers(conversationId, currentUserId, participantNames),
        );
      }
    })();
  }

  Future<List<String>> _fetchTypingUsers(
    String conversationId,
    String currentUserId,
    Map<String, String> participantNames,
  ) async {
    try {
      final rows = await _supabase
          .from('typing_indicators')
          .select('user_id,is_typing,updated_at')
          .eq('conversation_id', conversationId);

      return (rows as List)
          .cast<Map<String, dynamic>>()
          .where((row) {
            final isTyping = row['is_typing'] == true;
            final userId = row['user_id']?.toString() ?? '';
            if (!isTyping || userId.isEmpty || userId == currentUserId) {
              return false;
            }
            final updatedAt = DateTime.tryParse(row['updated_at']?.toString() ?? '');
            if (updatedAt == null) return false;
            return DateTime.now().difference(updatedAt).inSeconds <= 8;
          })
          .map((row) {
            final userId = row['user_id']?.toString() ?? '';
            return participantNames[userId] ?? 'Member';
          })
          .toSet()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<bool> _fetchTypingState(String conversationId, String otherUserId) async {
    try {
      final row = await _supabase
          .from('typing_indicators')
          .select('is_typing,updated_at')
          .eq('conversation_id', conversationId)
          .eq('user_id', otherUserId)
          .maybeSingle();

      if (row == null) return false;
      if (row['is_typing'] != true) return false;

      final updatedAt = DateTime.tryParse(row['updated_at']?.toString() ?? '');
      if (updatedAt == null) return false;
      return DateTime.now().difference(updatedAt).inSeconds <= 8;
    } catch (_) {
      return false;
    }
  }

  Future<void> setPresence({
    required String userId,
    required bool isOnline,
  }) async {
    await _upsertWithPrunedColumns(
      'user_presence',
      {
        'user_id': userId,
        'is_online': isOnline,
        'last_seen_at': DateTime.now().toIso8601String(),
      },
      'user_id',
    );
  }

  Stream<PresenceStatus> streamPresence(String userId) {
    return (() async* {
      yield await _fetchPresence(userId);
      try {
        yield* _supabase
            .from('user_presence')
            .stream(primaryKey: ['user_id'])
            .eq('user_id', userId)
            .map((rows) {
              if (rows.isEmpty) return const PresenceStatus(isOnline: false);
              final row = rows.first;
              return PresenceStatus(
                isOnline: row['is_online'] == true,
                lastSeenAt: DateTime.tryParse(row['last_seen_at']?.toString() ?? ''),
              );
            });
      } catch (_) {
        yield* Stream.periodic(const Duration(seconds: 10)).asyncMap(
          (_) => _fetchPresence(userId),
        );
      }
    })();
  }

  Future<PresenceStatus> _fetchPresence(String userId) async {
    try {
      final row = await _supabase
          .from('user_presence')
          .select('is_online,last_seen_at')
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) return const PresenceStatus(isOnline: false);
      return PresenceStatus(
        isOnline: row['is_online'] == true,
        lastSeenAt: DateTime.tryParse(row['last_seen_at']?.toString() ?? ''),
      );
    } catch (_) {
      return const PresenceStatus(isOnline: false);
    }
  }

  Future<Conversation> getOrCreateDirectConversation({
    required String currentUserId,
    required String currentUserName,
    required UserModel otherUser,
  }) async {
    final existingRows = await _supabase.from('conversations').select();
    final rows = (existingRows as List).cast<Map<String, dynamic>>();

    for (final row in rows) {
      final ids = List<String>.from(row['participant_ids'] ?? const []);
      if (ids.length == 2 && ids.contains(currentUserId) && ids.contains(otherUser.id)) {
        return _mapConversation(row, currentUserId);
      }
    }

    final now = DateTime.now().toIso8601String();
    final payload = {
      'participant_ids': [currentUserId, otherUser.id],
      'participant_names': {
        currentUserId: currentUserName,
        otherUser.id: otherUser.displayName,
      },
      'participant_avatars': {
        currentUserId: '',
        otherUser.id: otherUser.photoURL,
      },
      'last_message': '',
      'last_message_sender_id': currentUserId,
      'last_message_timestamp': now,
      'unread_count': 0,
      'created_at': now,
      'updated_at': now,
    };

    final inserted = await _supabase
        .from('conversations')
        .insert(payload)
        .select()
        .single();

    return _mapConversation(inserted, currentUserId);
  }

  Future<Conversation> createCommunityConversation({
    required String creatorId,
    required String creatorName,
    required String communityName,
    required List<UserModel> members,
  }) async {
    final uniqueIds = <String>{creatorId, ...members.map((m) => m.id)};
    final ids = uniqueIds.toList();
    final now = DateTime.now().toIso8601String();

    final participantNames = <String, String>{
      Conversation.groupNameMetaKey: communityName.trim(),
      Conversation.groupAdminMetaKey: creatorId,
      creatorId: creatorName,
    };
    final participantAvatars = <String, String>{
      Conversation.groupAvatarMetaKey: '',
      creatorId: '',
    };

    for (final user in members) {
      participantNames[user.id] = user.displayName;
      participantAvatars[user.id] = user.photoURL;
    }

    final payload = {
      'participant_ids': ids,
      'participant_names': participantNames,
      'participant_avatars': participantAvatars,
      'last_message': 'Community created',
      'last_message_sender_id': creatorId,
      'last_message_timestamp': now,
      'unread_count': 0,
      'created_at': now,
      'updated_at': now,
    };

    final inserted = await _supabase
        .from('conversations')
        .insert(payload)
        .select()
        .single();

    return _mapConversation(inserted, creatorId);
  }

  Future<Conversation?> renameCommunity({
    required String conversationId,
    required String adminUserId,
    required String newName,
  }) async {
    final row = await _fetchConversationRow(conversationId);
    if (row == null) return null;

    final names = Map<String, String>.from(row['participant_names'] ?? const <String, String>{});
    final currentAdmin = names[Conversation.groupAdminMetaKey] ?? '';
    if (currentAdmin.isEmpty || currentAdmin != adminUserId) {
      throw Exception('Only the community admin can rename this group.');
    }

    final trimmed = newName.trim();
    if (trimmed.isEmpty) throw Exception('Community name cannot be empty.');

    names[Conversation.groupNameMetaKey] = trimmed;

    await _updateConversationWithPrunedColumns(conversationId, {
      'participant_names': names,
      'updated_at': DateTime.now().toIso8601String(),
    });

    final updated = await _fetchConversationRow(conversationId);
    if (updated == null) return null;
    return _mapConversation(updated, adminUserId);
  }

  Future<Conversation?> updateCommunityAvatar({
    required String conversationId,
    required String adminUserId,
    required String avatarUrl,
  }) async {
    final row = await _fetchConversationRow(conversationId);
    if (row == null) return null;

    final names = Map<String, String>.from(row['participant_names'] ?? const <String, String>{});
    final avatars = Map<String, String>.from(row['participant_avatars'] ?? const <String, String>{});
    final currentAdmin = names[Conversation.groupAdminMetaKey] ?? '';
    if (currentAdmin.isEmpty || currentAdmin != adminUserId) {
      throw Exception('Only the community admin can update group avatar.');
    }

    avatars[Conversation.groupAvatarMetaKey] = avatarUrl.trim();

    await _updateConversationWithPrunedColumns(conversationId, {
      'participant_avatars': avatars,
      'updated_at': DateTime.now().toIso8601String(),
    });

    final updated = await _fetchConversationRow(conversationId);
    if (updated == null) return null;
    return _mapConversation(updated, adminUserId);
  }

  Future<Conversation?> addMembersToCommunity({
    required String conversationId,
    required String adminUserId,
    required List<UserModel> newMembers,
  }) async {
    if (newMembers.isEmpty) return await getConversationById(conversationId, adminUserId);

    final row = await _fetchConversationRow(conversationId);
    if (row == null) return null;

    final ids = List<String>.from(row['participant_ids'] ?? const []);
    final names = Map<String, String>.from(row['participant_names'] ?? const <String, String>{});
    final avatars = Map<String, String>.from(row['participant_avatars'] ?? const <String, String>{});
    final currentAdmin = names[Conversation.groupAdminMetaKey] ?? '';
    if (currentAdmin.isEmpty || currentAdmin != adminUserId) {
      throw Exception('Only the community admin can add members.');
    }

    final updatedIds = <String>{...ids};
    for (final member in newMembers) {
      updatedIds.add(member.id);
      names[member.id] = member.displayName;
      avatars[member.id] = member.photoURL;
    }

    await _updateConversationWithPrunedColumns(conversationId, {
      'participant_ids': updatedIds.toList(),
      'participant_names': names,
      'participant_avatars': avatars,
      'updated_at': DateTime.now().toIso8601String(),
    });

    final updated = await _fetchConversationRow(conversationId);
    if (updated == null) return null;
    return _mapConversation(updated, adminUserId);
  }

  Future<Conversation?> removeMemberFromCommunity({
    required String conversationId,
    required String adminUserId,
    required String memberId,
  }) async {
    final row = await _fetchConversationRow(conversationId);
    if (row == null) return null;

    final ids = List<String>.from(row['participant_ids'] ?? const []);
    final names = Map<String, String>.from(row['participant_names'] ?? const <String, String>{});
    final avatars = Map<String, String>.from(row['participant_avatars'] ?? const <String, String>{});
    final currentAdmin = names[Conversation.groupAdminMetaKey] ?? '';
    if (currentAdmin.isEmpty || currentAdmin != adminUserId) {
      throw Exception('Only the community admin can remove members.');
    }
    if (memberId == adminUserId) {
      throw Exception('Admin cannot remove herself from community.');
    }

    ids.removeWhere((id) => id == memberId);
    names.remove(memberId);
    avatars.remove(memberId);

    if (ids.length < 2) {
      throw Exception('A community must have at least 2 members.');
    }

    await _updateConversationWithPrunedColumns(conversationId, {
      'participant_ids': ids,
      'participant_names': names,
      'participant_avatars': avatars,
      'updated_at': DateTime.now().toIso8601String(),
    });

    await _supabase
        .from('typing_indicators')
        .delete()
        .eq('conversation_id', conversationId)
        .eq('user_id', memberId);

    final updated = await _fetchConversationRow(conversationId);
    if (updated == null) return null;
    return _mapConversation(updated, adminUserId);
  }

  Future<Conversation?> getConversationById(String conversationId, String currentUserId) async {
    final row = await _fetchConversationRow(conversationId);
    if (row == null) return null;
    return _mapConversation(row, currentUserId);
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
      seenAt: DateTime.tryParse(row['seen_at']?.toString() ?? ''),
    );
  }

  Conversation _mapConversation(Map<String, dynamic> row, String userId) {
    final participantIds = List<String>.from(row['participant_ids'] ?? const []);
    final names = Map<String, String>.from(row['participant_names'] ?? const <String, String>{});
    final avatars = Map<String, String>.from(row['participant_avatars'] ?? const <String, String>{});

    final namedGroup = (names[Conversation.groupNameMetaKey] ?? '').trim().isNotEmpty;
    final isGroup = namedGroup || participantIds.length > 2;

    final otherUserId = isGroup
      ? ''
      : participantIds.firstWhere(
        (id) => id != userId,
        orElse: () => participantIds.isNotEmpty ? participantIds.first : '',
        );

    return Conversation(
      id: row['id']?.toString() ?? '',
      participantIds: participantIds,
      participantNames: isGroup
        ? names
        : (otherUserId.isEmpty
          ? names
          : {otherUserId: names[otherUserId] ?? 'Unknown'}),
      participantAvatars: isGroup
        ? avatars
        : (otherUserId.isEmpty
          ? avatars
          : {otherUserId: avatars[otherUserId] ?? ''}),
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
