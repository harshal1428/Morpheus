import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  late final StreamSubscription<AuthState> _authSubscription;

  AuthService() {
    _currentUser = _supabase.auth.currentUser;
    _listenToAuthChanges();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  String? get userId => _currentUser?.id;

  void _listenToAuthChanges() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.initialSession:
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.userUpdated:
          _currentUser = session?.user;
          break;
        case AuthChangeEvent.signedOut:
          _currentUser = null;
          break;
        case AuthChangeEvent.tokenRefreshed:
          _currentUser = session?.user;
          break;
        case AuthChangeEvent.mfaChallengeVerified:
          break;
        case AuthChangeEvent.passwordRecovery:
          break;
        case AuthChangeEvent.userDeleted:
          _currentUser = null;
          break;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );

      _currentUser = res.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign up failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _currentUser = res.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign in failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.signOut();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Sign out failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.resetPasswordForEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Password reset failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Password update failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      _error = 'Failed to fetch user profile: ${e.toString()}';
      return null;
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
