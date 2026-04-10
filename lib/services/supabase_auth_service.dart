import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_database_service.dart';

class SupabaseAuthService {
  static final SupabaseAuthService _instance =
      SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  final _supabase = Supabase.instance.client;
  final _dbService = SupabaseDatabaseService();

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  String? get currentUserId => _supabase.auth.currentUser?.id;
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  // Auth state stream
  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  // ==================== EMAIL/PASSWORD AUTH ====================

  /// Sign up with email and password
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String userType,
  }) async {
    try {
      final response = await _supabase.auth.signUpWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        // Update user metadata with display name
        await _supabase.auth.updateUser(
          UserAttributes(data: {'display_name': displayName}),
        );

        // Create user profile in database
        final userModel = UserModel(
          id: user.id,
          email: email,
          displayName: displayName,
          userType: userType,
          photoURL: '',
        );

        await _dbService.saveUser(userModel);
      }

      return user;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with email and password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.user;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate and update password
      await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ==================== USER PROFILE ====================

  /// Update user profile
  Future<void> updateUserProfile({
    required String displayName,
    String? phoneNumber,
    String? photoURL,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final updates = <String, dynamic>{
        'display_name': displayName,
        if (phoneNumber != null) 'phone': phoneNumber,
        if (photoURL != null) 'avatar_url': photoURL,
      };

      await _supabase.auth.updateUser(
        UserAttributes(data: updates),
      );

      // Also update user profile in database
      if (user.userMetadata?['full_profile'] == true) {
        final userModel = UserModel(
          id: user.id,
          email: user.email ?? '',
          displayName: displayName,
          userType: user.userMetadata?['user_type'] ?? 'user',
          photoURL: photoURL ?? '',
        );
        await _dbService.saveUser(userModel);
      }
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ==================== SIGN OUT ====================

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ==================== ERROR HANDLING ====================

  String _handleAuthException(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password';
      case 'User already registered':
        return 'Email already has an account';
      case 'User not found':
        return 'User not found';
      default:
        return e.message ?? 'Authentication error';
    }
  }
}
