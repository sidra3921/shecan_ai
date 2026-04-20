class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final List<String>? attachmentUrls;
  final DateTime timestamp;
  final List<String> readBy; // User IDs who read this message
  final bool isRead;
  final DateTime? seenAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    this.attachmentUrls,
    required this.timestamp,
    this.readBy = const [],
    this.isRead = false,
    this.seenAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'attachmentUrls': attachmentUrls,
      'timestamp': timestamp,
      'readBy': readBy,
      'isRead': isRead,
      'seenAt': seenAt?.toIso8601String(),
    };
  }

  bool isSeenBy(String userId) => readBy.contains(userId);

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessage(
      id: docId,
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderAvatar: map['senderAvatar'] ?? '',
      content: map['content'] ?? '',
      attachmentUrls: List<String>.from(map['attachmentUrls'] ?? []),
      timestamp: _parseDateTime(map['timestamp']) ?? DateTime.now(),
      readBy: List<String>.from(map['readBy'] ?? []),
      isRead: map['isRead'] ?? false,
      seenAt: _parseDateTime(map['seenAt']),
    );
  }
}

class Conversation {
  static const String groupNameMetaKey = '__group_name';
  static const String groupAdminMetaKey = '__group_admin_id';
  static const String groupAvatarMetaKey = '__group_avatar';

  final String id;
  final List<String> participantIds; // User IDs involved
  final Map<String, String> participantNames; // userId -> displayName
  final Map<String, String> participantAvatars; // userId -> avatar URL
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final String lastMessageSenderId;
  final int unreadCount;
  final DateTime createdAt;
  final String? projectId; // If conversation is about a specific project
  final String? projectTitle;

  Conversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantAvatars,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.lastMessageSenderId,
    this.unreadCount = 0,
    required this.createdAt,
    this.projectId,
    this.projectTitle,
  });

  Map<String, String> get visibleParticipantNames {
    return Map<String, String>.fromEntries(
      participantNames.entries.where((e) => !e.key.startsWith('__')),
    );
  }

  Map<String, String> get visibleParticipantAvatars {
    return Map<String, String>.fromEntries(
      participantAvatars.entries.where((e) => !e.key.startsWith('__')),
    );
  }

  bool get isGroup {
    final namedGroup = (participantNames[groupNameMetaKey] ?? '').trim().isNotEmpty;
    return namedGroup || visibleParticipantNames.length > 2;
  }

  String get groupName {
    final name = (participantNames[groupNameMetaKey] ?? '').trim();
    if (name.isNotEmpty) return name;
    return 'Community Group';
  }

  String get groupAdminId {
    return (participantNames[groupAdminMetaKey] ?? '').trim();
  }

  String get groupAvatarUrl {
    return (participantAvatars[groupAvatarMetaKey] ?? '').trim();
  }

  bool canManageGroup(String userId) {
    if (!isGroup) return false;
    return groupAdminId.isNotEmpty && groupAdminId == userId;
  }

  String get displayTitle {
    if (isGroup) return groupName;
    return otherUserName ?? 'Mentor';
  }

  String get displaySubtitle {
    if (isGroup) return '${visibleParticipantNames.length} members';
    return '';
  }

  // Helper getters for easier access to other user info
  String? get otherUserName {
    if (visibleParticipantNames.isEmpty) return null;
    return visibleParticipantNames.values.first;
  }

  String? get otherUserAvatar {
    if (visibleParticipantAvatars.isEmpty) return null;
    return visibleParticipantAvatars.values.first;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'createdAt': createdAt,
      'projectId': projectId,
      'projectTitle': projectTitle,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  factory Conversation.fromMap(Map<String, dynamic> map, String docId) {
    return Conversation(
      id: docId,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      participantAvatars: Map<String, String>.from(
        map['participantAvatars'] ?? {},
      ),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTimestamp: _parseDateTime(map['lastMessageTimestamp']) ?? DateTime.now(),
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      unreadCount: map['unreadCount'] ?? 0,
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      projectId: map['projectId'],
      projectTitle: map['projectTitle'],
    );
  }
}
