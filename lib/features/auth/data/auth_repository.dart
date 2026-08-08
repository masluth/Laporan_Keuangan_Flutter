import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  // =========================================================
  // CURRENT USER
  // =========================================================

  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  // =========================================================
  // AUTH STATE
  // =========================================================

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<bool> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final response =
          await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      return response.user != null;
    } on AuthException catch (e) {
      debugPrint(
        'Supabase Login Error: ${e.message}',
      );
      return false;
    } catch (e) {
      debugPrint(
        'Login Error: $e',
      );
      return false;
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      debugPrint(
        'Supabase Logout Error: ${e.message}',
      );
    } catch (e) {
      debugPrint(
        'Logout Error: $e',
      );
    }
  }
}