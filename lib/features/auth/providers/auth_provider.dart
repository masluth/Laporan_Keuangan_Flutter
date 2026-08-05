import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    this.isLoading = false,
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
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
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
      : super(const AuthState(
          isAuthenticated: true, // Default logged in for smooth demo experience
          email: 'alex.thompson@greengarden.id',
          userName: 'Alex Thompson',
        ));

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final success = await _repository.signInWithEmail(email, password);
    if (success) {
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        email: email,
        userName: 'Alex Thompson',
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal masuk. Periksa email & kata sandi.',
      );
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    final success = await _repository.signUpWithEmail(email, password);
    if (success) {
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        email: email,
        userName: name.isNotEmpty ? name : 'Alex Thompson',
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Pendaftaran gagal.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    state = const AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
