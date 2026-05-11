import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'config/app_config.dart';
import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/ai_service.dart';
import 'services/assessment_service.dart';
import 'services/chat_service.dart';
import 'services/notification_service.dart';
import 'services/payment_service.dart';
import 'services/recommendation_service.dart';
import 'services/review_service.dart';
import 'services/session_service.dart';
import 'services/supabase_auth_service.dart';
import 'services/supabase_database_service.dart';
import 'services/supabase_service.dart';
import 'services/supabase_storage_service.dart';
import 'services/video_consultation_service.dart';

final getIt = GetIt.instance;
final supabaseService = SupabaseService();

void _setupServiceLocator() {
  if (!getIt.isRegistered<SupabaseService>()) {
    getIt.registerSingleton<SupabaseService>(supabaseService);
  }
  if (!getIt.isRegistered<SupabaseAuthService>()) {
    getIt.registerSingleton<SupabaseAuthService>(SupabaseAuthService());
  }
  if (!getIt.isRegistered<SupabaseDatabaseService>()) {
    getIt.registerSingleton<SupabaseDatabaseService>(SupabaseDatabaseService());
  }
  if (!getIt.isRegistered<SupabaseStorageService>()) {
    getIt.registerSingleton<SupabaseStorageService>(SupabaseStorageService());
  }

  if (!getIt.isRegistered<SessionService>()) {
    getIt.registerSingleton<SessionService>(SessionService());
  }
  if (!getIt.isRegistered<ChatService>()) {
    getIt.registerSingleton<ChatService>(ChatService());
  }
  if (!getIt.isRegistered<VideoConsultationService>()) {
    getIt.registerSingleton<VideoConsultationService>(
      VideoConsultationService(),
    );
  }
  if (!getIt.isRegistered<AssessmentService>()) {
    getIt.registerSingleton<AssessmentService>(AssessmentService());
  }
  if (!getIt.isRegistered<PaymentService>()) {
    getIt.registerSingleton<PaymentService>(PaymentService());
  }
  if (!getIt.isRegistered<ReviewService>()) {
    getIt.registerSingleton<ReviewService>(ReviewService());
  }
  if (!getIt.isRegistered<AIService>()) {
    getIt.registerSingleton<AIService>(AIService());
  }
  if (!getIt.isRegistered<RecommendationService>()) {
    getIt.registerSingleton<RecommendationService>(RecommendationService());
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await supabaseService.initialize(
      supabaseUrl: 'https://ieawgfrukdlhsbjcnjhk.supabase.co',
      supabaseAnonKey: 'sb_publishable_kMwVg-kJ-688DXmlOvf_bg_9ItvRCa9',
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  await NotificationService().initialize();

  _setupServiceLocator();
  await getIt<SessionService>().initialize();

  if (!AppConfig.validateApiKeys()) {
    debugPrint('Using fallback/mock settings for unconfigured API keys.');
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
      // theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
