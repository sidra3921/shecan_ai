import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'constants/app_theme.dart';
import 'config/app_config.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/chat_service.dart';
import 'services/video_consultation_service.dart';
import 'services/assessment_service.dart';
import 'services/payment_service.dart';
import 'services/review_service.dart';
import 'services/ai_service.dart';
import 'services/recommendation_service.dart';

final getIt = GetIt.instance;

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

/// Setup all service dependencies (Dependency Injection)
void _setupServiceLocator() {
  // Register Tier 1 feature services
  getIt.registerSingleton<ChatService>(ChatService());
  getIt.registerSingleton<VideoConsultationService>(VideoConsultationService());
  getIt.registerSingleton<AssessmentService>(AssessmentService());
  getIt.registerSingleton<PaymentService>(PaymentService());
  getIt.registerSingleton<ReviewService>(ReviewService());
  getIt.registerSingleton<AIService>(AIService());
  getIt.registerSingleton<RecommendationService>(RecommendationService());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize FCM background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize notification service
  await NotificationService().initialize();

  // Setup Service Locator for Tier 1 features
  _setupServiceLocator();

  // Log configuration (development only)
  AppConfig.logConfiguration();

  // Validate API keys
  if (!AppConfig.validateApiKeys()) {
    if (AppConfig.enableDetailedLogging) {
      print('⚠️ Using mock data for unconfonfigured APIs');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SheCan AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
