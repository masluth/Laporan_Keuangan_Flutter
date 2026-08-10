import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../../transactions/providers/transaction_provider.dart';

// =========================================================
// AUTH REPOSITORY PROVIDER
// =========================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// =========================================================
// AUTH STATE
// =========================================================

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? email;
  final String? userName;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = true,
    this.email,
    this.userName,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? email,
    String? userName,
    String? error,
  }) {
    return AuthState(
      isAuthenticated:
          isAuthenticated ?? this.isAuthenticated,
      isLoading:
          isLoading ?? this.isLoading,
      email:
          email ?? this.email,
      userName:
          userName ?? this.userName,
      error: error,
    );
  }
}

// =========================================================
// AUTH NOTIFIER
// =========================================================

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(
    this._repository,
    this._ref,
  ) : super(const AuthState()) {
    _checkSession();
  }

  // =======================================================
  // GET USER PROFILE
  // =======================================================

  Future<String?> _getUserName(User user) async {
    try {
      /*
       * Struktur tabel profiles:
       *
       * id
       * full_name
       * business_name
       * created_at
       * updated_at
       *
       * Kolom "id" berisi UUID yang sama
       * dengan auth.users.id.
       */

      final response = await Supabase.instance.client
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        debugPrint(
          'Profile tidak ditemukan untuk user: ${user.id}',
        );

        return null;
      }

      final fullName =
          response['full_name']?.toString();

      debugPrint(
        'PROFILE FULL NAME: $fullName',
      );

      return fullName;
    } catch (e) {
      debugPrint(
        'Gagal mengambil nama profile: $e',
      );

      return null;
    }
  }

  // =======================================================
  // CHECK SESSION
  // =======================================================

  Future<void> _checkSession() async {
    try {
      final session =
          Supabase.instance.client.auth.currentSession;

      if (session == null) {
        state = const AuthState(
          isAuthenticated: false,
          isLoading: false,
        );

        return;
      }

      final user = session.user;

      final userName = await _getUserName(user);

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        email: user.email,
        userName: userName,
      );

      debugPrint(
        'CURRENT USER ID: ${user.id}',
      );

      debugPrint(
        'CURRENT USER EMAIL: ${user.email}',
      );

      debugPrint(
        'CURRENT USER NAME: $userName',
      );
    } catch (e) {
      debugPrint(
        'Check Session Error: $e',
      );

      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  // =======================================================
  // LOGIN
  // =======================================================

  Future<bool> login(
    String email,
    String password,
  ) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    final success =
        await _repository.signInWithEmail(
      email,
      password,
    );

    if (!success) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error:
            'Gagal masuk. Periksa email & kata sandi.',
      );

      return false;
    }

    try {
      final session =
          Supabase.instance.client.auth.currentSession;

      final user = session?.user;

      if (user == null) {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          error: 'User tidak ditemukan.',
        );

        return false;
      }

      // ===================================================
      // AMBIL NAMA DARI TABLE PROFILES
      // ===================================================

      final userName =
          await _getUserName(user);

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        email: user.email ?? email,
        userName: userName,
      );

      debugPrint(
        'LOGIN USER ID: ${user.id}',
      );

      debugPrint(
        'LOGIN EMAIL: ${user.email}',
      );

      debugPrint(
        'LOGIN USER NAME: $userName',
      );

      // ===================================================
      // RESET TRANSACTION STATE
      // ===================================================

      _ref.invalidate(transactionProvider);

      return true;
    } catch (e) {
      debugPrint(
        'Login Profile Error: $e',
      );

      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error:
            'Gagal mengambil data profil.',
      );

      return false;
    }
  }

  // =======================================================
  // LOGOUT
  // =======================================================

  Future<void> logout() async {
    try {
      // Logout dari Supabase.
      await _repository.signOut();

      // Buang transaksi user sebelumnya.
      _ref.invalidate(transactionProvider);

      // Reset auth state.
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        email: null,
        userName: null,
        error: null,
      );

      debugPrint(
        'USER LOGGED OUT',
      );
    } catch (e) {
      debugPrint(
        'Logout Error: $e',
      );
    }
  }
}

// =========================================================
// AUTH PROVIDER
// =========================================================

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    final repository =
        ref.watch(authRepositoryProvider);

    return AuthNotifier(
      repository,
      ref,
    );
  },
);