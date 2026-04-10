// Firestore removed - use SupabaseDatabaseService instead
import '../models/chat_model.dart';

class ChatService {
  // FirebaseFirestore instance removed

  /// Get or create a conversation between two users
  Future<Conversation> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
    required String currentUserAvatar,
    required String otherUserAvatar,
    String? projectId,
    String? projectTitle,
  }) async {
    try {
      final query = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: currentUserId)
          .get();

      for (final doc in query.docs) {
        final conv = Conversation.fromMap(doc.data(), doc.id);
        if (conv.participantIds.contains(otherUserId)) {
          return conv;
        }
      }

      final conversationRef = _firestore.collection('conversations').doc();
      final participants = [currentUserId, otherUserId];
      final participantNames = {
        currentUserId: currentUserName,
        otherUserId: otherUserName,
      };

      final conversation = Conversation(
        id: conversationRef.id,
        participantIds: participants,
        participantNames: participantNames,
        participantAvatars: {
          currentUserId: currentUserAvatar,
          otherUserId: otherUserAvatar,
        },
        lastMessage: 'Conversation started',
        lastMessageTimestamp: DateTime.now(),
        lastMessageSenderId: currentUserId,
        createdAt: DateTime.now(),
        projectId: projectId,
        projectTitle: projectTitle,
      );

      await conversationRef.set(conversation.toMap());
      return conversation;
    } catch (e) {
      print('Error creating conversation: $e');
      rethrow;
    }
  }

  /// Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String content,
    List<String>? attachmentUrls,
  }) async {
    try {
      final messageRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc();

      final message = ChatMessage(
        id: messageRef.id,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        content: content,
        attachmentUrls: attachmentUrls,
        timestamp: DateTime.now(),
      );

      await messageRef.set(message.toMap());

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content.length > 100
            ? '${content.substring(0, 100)}...'
            : content,
        'lastMessageTimestamp': DateTime.now(),
        'lastMessageSenderId': senderId,
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Get messages stream
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// Get conversations stream
  Stream<List<Conversation>> getConversationsStream(String userId) {
    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Conversation.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// Mark message as read
  Future<void> markMessageAsRead({
    required String conversationId,
    required String messageId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({
            // Replace with Supabase: doc.update({...});
            //'readBy': [...],
            'isRead': true,
          });
    } catch (e) {
      print('Error marking read: $e');
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).delete();
    } catch (e) {
      print('Error deleting conversation: $e');
      rethrow;
    }
  }

  /// Search conversations
  Future<List<Conversation>> searchConversations({
    required String userId,
    required String searchQuery,
  }) async {
    try {
      final conversations = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          .get();

      final filtered = conversations.docs
          .map((doc) => Conversation.fromMap(doc.data(), doc.id))
          .where((conv) {
            final names = conv.participantNames.values.join(' ').toLowerCase();
            return names.contains(searchQuery.toLowerCase());
          })
          .toList();

      return filtered;
    } catch (e) {
      print('Error searching: $e');
      return [];
    }
  }
}
