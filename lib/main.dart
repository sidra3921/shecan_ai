import 'package:flutter/material.dart';
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
import 'services/supabase_service.dart';
import 'services/supabase_auth_service.dart';
import 'services/supabase_database_service.dart';
import 'services/supabase_storage_service.dart';

final getIt = GetIt.instance;
final supabaseService = SupabaseService();

/// Setup all service dependencies (Dependency Injection)
void _setupServiceLocator() {
  // Register Supabase services
  getIt.registerSingleton<SupabaseService>(supabaseService);
  getIt.registerSingleton<SupabaseAuthService>(SupabaseAuthService());
  getIt.registerSingleton<SupabaseDatabaseService>(SupabaseDatabaseService());
  getIt.registerSingleton<SupabaseStorageService>(SupabaseStorageService());

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

  // Initialize Supabase
  // ⚠️ IMPORTANT: Replace with your actual Supabase credentials
  // Get from: https://app.supabase.com → Project Settings → API
  try {
    await supabaseService.initialize(
      supabaseUrl: 'https://ieawgfrukdlhsbjcnjhk.supabase.co',
      supabaseAnonKey: 'sb_publishable_kMwVg-kJ-688DXmlOvf_bg_9ItvRCa9',
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize Supabase: $e');
    // Continue anyway - will fail on API calls
  }

  // Initialize notification service
  await NotificationService().initialize();

  // Setup Service Locator for Tier 1 features and Supabase
  _setupServiceLocator();

  // Log configuration (development only)
  AppConfig.logConfiguration();

  // Validate API keys
  if (!AppConfig.validateApiKeys()) {
    if (AppConfig.enableDetailedLogging) {
      print('⚠️ Using mock data for unconfigured APIs');
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
