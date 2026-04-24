// Application Configuration File
//
// This file contains all API keys and configuration values for Tier 1 features.
//
// SECURITY NOTE:
// - NEVER commit real API keys to version control
// - Use environment variables or secure storage in production
// - Use test keys for development and testing

import 'package:flutter/foundation.dart';

class AppConfig {
  /// ============ STRIPE PAYMENT CONFIGURATION ============
  ///
  /// Get keys from: https://dashboard.stripe.com/apikeys
  ///
  /// Production:
  ///   - Publishable Key: pk_live_...
  ///   - Secret Key: sk_live_... (server-side only)
  ///
  /// Testing:
  ///   - Publishable Key: pk_test_...
  ///   - Secret Key: sk_test_...
  static const String stripePublishableKey =
      'pk_test_YOUR_STRIPE_PUBLISHABLE_KEY';

  // Server-side only - never expose in client
  static const String stripeSecretKey = 'sk_test_YOUR_STRIPE_SECRET_KEY';

  /// ============ TWILIO VIDEO CONFIGURATION ============
  ///
  /// Get credentials from: https://www.twilio.com/console/video/runtime-capture
  ///
  /// For production video calls:
  ///   1. Set up Twilio Video account
  ///   2. Create API key and secret
  ///   3. Get Account SID from console
  static const String twilioAccountSid = 'AC_YOUR_TWILIO_ACCOUNT_SID';
  static const String twilioApiKey = 'YOUR_TWILIO_API_KEY';
  static const String twilioApiSecret = 'YOUR_TWILIO_API_SECRET';

  /// ============ AGORA VIDEO CONFIGURATION (ALTERNATIVE TO TWILIO) ============
  ///
  /// Get credentials from: https://console.agora.io/
  ///
  /// Agora is often cheaper than Twilio for mobile apps
  /// Choose ONE video provider: Twilio OR Agora
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';

  // Agora customer ID (optional)
  static const String agoraCertificate = 'YOUR_AGORA_CERTIFICATE';

  /// ============ OPENAI CONFIGURATION ============
  ///
  /// Get key from: https://platform.openai.com/api-keys
  ///
  /// Used for:
  ///   - AI Resume generation
  ///   - Advanced chat bot responses
  ///   - Profile improvement suggestions
  ///
  /// Current implementation uses mock responses for testing.
  /// To enable real OpenAI:
  ///   1. Get your API key
  ///   2. Update this constant
  ///   3. Uncomment OpenAI calls in ai_service.dart
  static const String openaiApiKey = 'sk-YOUR_OPENAI_API_KEY';

  /// OpenAI Model to use
  static const String openaiModel = 'gpt-3.5-turbo'; // or 'gpt-4' for advanced

  /// ============ GEMINI CONFIGURATION ============
  ///
  /// Pass at runtime with:
  /// flutter run --dart-define=GEMINI_API_KEY=your_key_here
  /// Optional:
  /// flutter run --dart-define=GEMINI_MODEL=gemini-2.5-flash-lite
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Default model selected for free-tier friendly usage.
  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash-lite',
  );

  static String get resolvedGeminiApiKey {
    return geminiApiKey.trim();
  }

  /// ============ BACKEND CONFIGURATION ============
  ///
  /// Backend is powered by Supabase.
  static const String backendProvider = 'supabase';

  /// ============ APP FEATURE FLAGS ============
  ///
  /// Use these to enable/disable features during development
  static const bool enableRealStripePayments =
      false; // Set to true in production with real keys
  static const bool enableRealVideoCallsWithTwilio = false;
  static const bool enableRealVideoCallsWithAgora = false;
  static const bool enableRealOpenAI = false; // Uses mock responses instead

  /// Enable Gemini when a key is supplied via --dart-define.
  static bool get enableRealGemini => resolvedGeminiApiKey.isNotEmpty;

  /// ============ PAYMENT SETTINGS ============
  static const double defaultVideoConsultationPricePerMinute =
      50.0; // Currency units
  static const String currencyCode = 'USD';

  /// ============ ASSESSMENT SETTINGS ============
  static const double defaultAssessmentPassingScore = 70.0; // Percentage

  /// ============ REVIEW FRAUD DETECTION SETTINGS ============
  static const int minimumCommentLength = 20;
  static const int fraudFlagThreshold =
      2; // Red flags needed to mark as suspicious

  /// ============ RECOMMENDATION SETTINGS ============
  static const int maxSmartRecommendations = 15;
  static const int maxTrendingProjects = 10;

  /// ============ DATABASE RETENTION POLICIES ============
  /// How long to keep data (in days)
  static const int deleteMessagesAfterDays = 365; // 1 year
  static const int deletePaymentRecordsAfterDays =
      2555; // 7 years (legal requirement)

  /// ============ RATE LIMITING ============
  static const int maxMessagesPerMinute = 20;
  static const int maxAssessmentsPerDay = 3;

  /// ============ DEBUGGING & LOGGING ============
  static const bool enableDetailedLogging = true;
  static const bool enablePerformanceMetrics = true;

  /// ============ HELPER METHODS ============

  /// Get the active video provider: 'twilio' or 'agora'
  static String getVideoProvider() {
    if (enableRealVideoCallsWithTwilio) return 'twilio';
    if (enableRealVideoCallsWithAgora) return 'agora';
    return 'mock'; // Returns mock data for testing
  }

  /// Validate that required API keys are set before using real APIs
  static bool validateApiKeys() {
    final warnings = <String>[];

    if (stripePublishableKey.contains('YOUR_')) {
      warnings.add('⚠️ Stripe key not configured');
    }
    if (openaiApiKey.contains('YOUR_')) {
      warnings.add('⚠️ OpenAI key not configured');
    }
    if (resolvedGeminiApiKey.isEmpty) {
      warnings.add('⚠️ Gemini key not configured (GEMINI_API_KEY)');
    }
    if (getVideoProvider() == 'twilio' && twilioAccountSid.contains('YOUR_')) {
      warnings.add('⚠️ Twilio credentials not configured');
    }
    if (getVideoProvider() == 'agora' && agoraAppId.contains('YOUR_')) {
      warnings.add('⚠️ Agora credentials not configured');
    }

    if (warnings.isNotEmpty) {
      debugPrint('\n=== API Configuration Warnings ===');
      for (final warning in warnings) {
        debugPrint(warning);
      }
      debugPrint('====================================\n');
      return false;
    }

    return true;
  }

  /// Log current configuration (development only)
  static void logConfiguration() {
    if (!enableDetailedLogging) return;

    debugPrint('\n=== SheCan AI Configuration ===');
    debugPrint(
      '🚀 Stripe Payments: ${enableRealStripePayments ? "ENABLED" : "DISABLED (Mock)"}',
    );
    debugPrint('📹 Video Provider: ${getVideoProvider()}');
    debugPrint(
      '🤖 OpenAI Integration: ${enableRealOpenAI ? "ENABLED" : "DISABLED (Mock)"}',
    );
    debugPrint(
      '✨ Gemini Integration: ${enableRealGemini ? "ENABLED" : "DISABLED (No Key)"}',
    );
    debugPrint('🧠 Gemini Model: $geminiModel');
    debugPrint('🔐 Backend: $backendProvider');
    debugPrint('📊 Detailed Logging: ${enableDetailedLogging ? "ON" : "OFF"}');
    debugPrint('================================\n');
  }
}

/// Assistant Configuration for AI Chat Bot
class AssistantConfig {
  /// System prompt for the AI chat bot
  static const String systemPrompt =
      '''You are SheCan AI Assistant, a helpful support bot for the SheCan platform.
Your role is to:
- Help users understand how to use gig features
- Answer questions about payments and earnings
- Guide users through profile setup
- Provide career development advice
- Be professional, friendly, and concise

When asked about features, give practical examples. When unsure, offer to connect them with human support.''';

  /// Suggested chat commands for UI display
  static const List<String> suggestedQuestions = [
    'How do I get paid?',
    'What projects match my skills?',
    'How do I improve my profile?',
    "What's the minimum withdrawal amount?",
    'How do video consultations work?',
    'Can you help me prepare for a test?',
  ];

  /// FAQs that the bot can answer
  static const Map<String, String> faqs = {
    'earnings':
        'You can view your earnings in the Wallet section. Earnings come from completed projects and consultations. Minimum withdrawal is \$10.',
    'payment':
        'Payments are processed via Stripe. Your funds will be available within 2-3 business days after withdrawal.',
    'profile':
        'A complete profile includes: professional photo, bio, skills, portfolio samples, and hourly rate. This helps you get more project matches.',
    'assessment':
        'Skill assessments help verify your abilities. Pass the test to earn a badge that appears on your profile.',
    'consultant':
        'Video consultations are 1-on-1 sessions where you can share expertise. Set your hourly rate and available time slots.',
  };
}

/// Test Account Credentials (Development Only)
class TestAccounts {
  // Stripe test cards: https://stripe.com/docs/testing
  static const String stripeTestCardVisa = '4242 4242 4242 4242';
  static const String stripeTestCardFailure = '4000 0000 0000 0002';

  // Test user credentials (if using test data)
  static const String testUserEmail = 'test@shecan.ai';
  static const String testUserPassword = 'TestPassword123!';

  // Test IDs
  static const String testUserId = 'test_user_001';
  static const String testMentorId = 'test_mentor_001';
  static const String testProjectId = 'test_project_001';
}
