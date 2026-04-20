import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late SupabaseClient _client;

  SupabaseClient get client => _client;

  /// Initialize Supabase with your credentials
  /// Call this in main() before running the app
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  /// Get the authenticated user's ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
