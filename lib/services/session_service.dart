import 'package:flutter/foundation.dart';

import 'supabase_auth_service.dart';

class SessionService extends ChangeNotifier {
  SessionService({SupabaseAuthService? authService})
      : _authService = authService ?? SupabaseAuthService();

  final SupabaseAuthService _authService;

  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  bool get isAuthenticated => _currentUserId != null;

  Future<void> initialize() async {
    _currentUserId = _authService.currentUserId;
    notifyListeners();

    _authService.authStateChanges.listen((state) {
      _currentUserId = state.session?.user.id;
      notifyListeners();
    });
  }
}
