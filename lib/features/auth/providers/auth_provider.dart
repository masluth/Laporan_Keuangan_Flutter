import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

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
      isLoading: isLoading ?? this.isLoading,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository)
      : super(const AuthState()) {
    _checkSession();
  }

  // =========================================================
  // CHECK SESSION
  // =========================================================

  void _checkSession() {
    final session =
        Supabase.instance.client.auth.currentSession;

    if (session != null) {
      final user = session.user;

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        email: user.email,
        userName: user.userMetadata?['name'],
      );
    } else {
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  // =========================================================
  // LOGIN
  // =========================================================

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

    if (success) {
      final session =
          Supabase.instance.client.auth.currentSession;

      final user = session?.user;

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        email: user?.email ?? email,
        userName: user?.userMetadata?['name'],
      );

      return true;
    }

    state = state.copyWith(
      isAuthenticated: false,
      isLoading: false,
      error: 'Gagal masuk. Periksa email & kata sandi.',
    );

    return false;
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    await _repository.signOut();

    state = const AuthState(
      isAuthenticated: false,
      isLoading: false,
    );
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    final repository =
        ref.watch(authRepositoryProvider);

    return AuthNotifier(repository);
  },
);