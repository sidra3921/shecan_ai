// Firestore removed - use SupabaseDatabaseService instead
import '../models/user_model.dart';

class AIService {
  // FirebaseFirestore instance removed

  // NOTE: Add your OpenAI API Key to environment
  static const String openAiApiKey = 'sk-...';
  static const String openAiBaseUrl = 'https://api.openai.com/v1';

  /// Generate AI resume/profile from user data
  Future<String> generateAIResume({
    required String userId,
    required UserModel user,
    List<Map<String, dynamic>>? projects,
  }) async {
    try {
      final userContext =
          '''
User Information:
- Name: ${user.displayName}
- Skills: ${user.skills.join(', ')}
- Hourly Rate: PKR ${user.hourlyRate}
- City: ${user.city}
- Bio: ${user.bio}
- Rating: ${user.rating}/5
- Completed Projects: ${user.completedProjects}
${projects != null ? '- Sample Projects: ${projects.map((p) => p['title']).join(", ")}' : ''}
''';

      final generatedResume = _mockGenerateResume(userContext);

      await _firestore.collection('generatedResumes').doc(userId).set({
        'userId': userId,
        'resume': generatedResume,
        'generatedAt': DateTime.now(),
        'skills': user.skills,
      });

      return generatedResume;
    } catch (e) {
      print('Error generating resume: $e');
      rethrow;
    }
  }

  /// Mock resume generation (replace with OpenAI API)
  String _mockGenerateResume(String userContext) {
    return '''
PROFESSIONAL PROFILE

I am a dedicated professional with expertise in various technical and soft skills. With a strong track record of successfully completing projects, I am committed to delivering high-quality work that exceeds expectations.

KEY COMPETENCIES
• Advanced problem-solving and analytical skills
• Cross-functional collaboration and communication
• Project management and deadline adherence
• Quality assurance and attention to detail

PROFESSIONAL EXPERIENCE
Demonstrated expertise through successful completion of multiple projects across diverse domains. Strong ability to adapt to different industries and requirements while maintaining consistent quality standards.

ACHIEVEMENTS
• Consistent positive client feedback and high satisfaction rates
• Reliable project delivery and time management
• Continuous learning and skill development
''';
  }

  /// AI Chat Bot - Get response
  Future<String> getChatBotResponse({
    required String userMessage,
    required String userId,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      String botResponse;

      // Check if it's a support-related query
      if (_isSupportQuery(userMessage)) {
        botResponse = await _getSupportResponse(userMessage, userId);
      } else if (_isGigQuery(userMessage)) {
        botResponse = await _getGigRecommendationResponse(userMessage, userId);
      } else if (_isPaymentQuery(userMessage)) {
        botResponse = await _getPaymentResponse(userMessage, userId);
      } else {
        botResponse = _getDefaultBotResponse(userMessage);
      }

      // Save chat to history
      await _saveChatMessage(
        userId: userId,
        userMessage: userMessage,
        botResponse: botResponse,
      );

      return botResponse;
    } catch (e) {
      print('Error getting bot response: $e');
      return 'Sorry, I encountered an error. Please try again later.';
    }
  }

  /// Check if query is support-related
  bool _isSupportQuery(String message) {
    final supportKeywords = [
      'help',
      'support',
      'issue',
      'problem',
      'error',
      'bug',
      'contact',
      'how to',
      'guide',
      'tutorial',
    ];
    return supportKeywords.any(
      (keyword) => message.toLowerCase().contains(keyword),
    );
  }

  /// Check if query is gig-related
  bool _isGigQuery(String message) {
    final gigKeywords = [
      'gig',
      'project',
      'job',
      'work',
      'task',
      'recommend',
      'match',
    ];
    return gigKeywords.any(
      (keyword) => message.toLowerCase().contains(keyword),
    );
  }

  /// Check if query is payment-related
  bool _isPaymentQuery(String message) {
    final paymentKeywords = [
      'payment',
      'withdraw',
      'earning',
      'balance',
      'money',
      'invoice',
      'price',
    ];
    return paymentKeywords.any(
      (keyword) => message.toLowerCase().contains(keyword),
    );
  }

  /// Get support response
  Future<String> _getSupportResponse(String query, String userId) async {
    return '''
Thank you for reaching out! I'm here to help.

I understand you're looking for assistance with: $query

Here are some helpful resources:

1. **FAQ Section** - Browse our frequently asked questions
2. **Knowledge Base** - Detailed guides and documentation
3. **Contact Support** - Reach our support team directly
4. **Community Forum** - Ask questions to our community

How can I specifically help you today?
''';
  }

  /// Get gig recommendation response
  Future<String> _getGigRecommendationResponse(
    String query,
    String userId,
  ) async {
    return '''
Great! I can help you find matching gigs.

Based on your profile and skills, here's what I'm finding for you:

🎯 **Top Matches:**
1. Web Development Project - 85% match
2. Mobile App Consultation - 78% match
3. UI/UX Design Task - 72% match

📊 **Smart Recommendations:**
- These matches are based on your skills, experience level, and location
- All are within your preferred budget range
- Clients have verified reviews

Would you like me to:
- Show more details about any gig?
- Refine recommendations (distance, budget, skills)?
- Help you apply for a specific project?
''';
  }

  /// Get payment response
  Future<String> _getPaymentResponse(String query, String userId) async {
    final wallet = await _getWalletInfo(userId);

    return '''
💰 **Your Wallet Summary:**

**Available Balance:** PKR ${wallet['available']?.toStringAsFixed(2) ?? '0.00'}
**Pending Balance:** PKR ${wallet['pending']?.toStringAsFixed(2) ?? '0.00'}
**Total Earnings:** PKR ${wallet['total']?.toStringAsFixed(2) ?? '0.00'}

**Quick Actions:**
- View full transaction history
- Request withdrawal
- Add payment method
- View earnings over time

For more details or to request a withdrawal, please visit your Payments section or reply with "withdrawal".
''';
  }

  /// Get default bot response
  String _getDefaultBotResponse(String message) {
    return '''
Hello! 👋 I'm the SheCan AI Assistant. I'm here to help you with:

✨ **My Capabilities:**
- 🔍 Finding gig recommendations
- 💰 Answering payment & withdrawal questions
- 📚 Providing guidance on using the platform
- 🤝 Connecting you with support

What would you like to know more about?
''';
  }

  /// Get wallet info
  Future<Map<String, double>> _getWalletInfo(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (doc.exists) {
        return {
          'available':
              (doc.data()?['availableBalance'] as num?)?.toDouble() ?? 0.0,
          'pending': (doc.data()?['pendingBalance'] as num?)?.toDouble() ?? 0.0,
          'total': (doc.data()?['totalEarnings'] as num?)?.toDouble() ?? 0.0,
        };
      }
      return {'available': 0.0, 'pending': 0.0, 'total': 0.0};
    } catch (e) {
      return {'available': 0.0, 'pending': 0.0, 'total': 0.0};
    }
  }

  /// Save chat message
  Future<void> _saveChatMessage({
    required String userId,
    required String userMessage,
    required String botResponse,
  }) async {
    try {
      await _firestore.collection('chatHistory').add({
        'userId': userId,
        'userMessage': userMessage,
        'botResponse': botResponse,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      print('Error saving chat: $e');
    }
  }

  /// Get chat history
  Future<List<Map<String, dynamic>>> getChatHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chatHistory')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting chat history: $e');
      return [];
    }
  }

  /// Clear chat history
  Future<void> clearChatHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chatHistory')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing chat: $e');
      rethrow;
    }
  }

  /// Analyze user profile for improvement suggestions
  Future<List<String>> getProfileImprovementSuggestions(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      final suggestions = <String>[];

      // Bio check
      if ((userData['bio'] as String?)?.isEmpty ?? true) {
        suggestions.add('🎯 Add a professional bio to attract more clients');
      }

      // Skills check
      if ((userData['skills'] as List?)?.isEmpty ?? true) {
        suggestions.add('⚡ Add your skills to get better gig matches');
      }

      // Profile pic check
      if ((userData['profileImageUrl'] as String?)?.isEmpty ?? true) {
        suggestions.add('📸 Upload a profile picture to increase trust');
      }

      // Portfolio check
      if (((userData['completedProjects'] as int?) ?? 0) < 3) {
        suggestions.add('💼 Complete more projects to build credibility');
      }

      // Rating check
      if (((userData['rating'] as num?)?.toDouble() ?? 0) < 4) {
        suggestions.add(
          '⭐ Focus on delivering quality work to improve your rating',
        );
      }

      return suggestions;
    } catch (e) {
      print('Error getting suggestions: $e');
      return [];
    }
  }
}
