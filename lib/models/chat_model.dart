import 'package:cloud_firestore/cloud_firestore.dart';

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
    };
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
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(map['readBy'] ?? []),
      isRead: map['isRead'] ?? false,
    );
  }
}

class Conversation {
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

  // Helper getters for easier access to other user info
  String? get otherUserName {
    if (participantNames.isEmpty) return null;
    return participantNames.values.first;
  }

  String? get otherUserAvatar {
    if (participantAvatars.isEmpty) return null;
    return participantAvatars.values.first;
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

  factory Conversation.fromMap(Map<String, dynamic> map, String docId) {
    return Conversation(
      id: docId,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      participantAvatars: Map<String, String>.from(
        map['participantAvatars'] ?? {},
      ),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTimestamp:
          (map['lastMessageTimestamp'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      unreadCount: map['unreadCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      projectId: map['projectId'],
      projectTitle: map['projectTitle'],
    );
  }
}
