/// ⚠️ DEPRECATED: Use SupabaseAuthService instead
/// This file is kept for backward compatibility only
/// All new code should use SupabaseAuthService from 'supabase_auth_service.dart'

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  @deprecated
  User? get currentUser => throw UnsupportedError('Use SupabaseAuthService instead');
  
  @deprecated
  String? get currentUserId => throw UnsupportedError('Use SupabaseAuthService instead');
  
  @deprecated
  bool get isAuthenticated => throw UnsupportedError('Use SupabaseAuthService instead');

  @Deprecated('Use SupabaseAuthService instead')
  Future<void> signOut() =>
      throw UnsupportedError('Use SupabaseAuthService instead');
}
