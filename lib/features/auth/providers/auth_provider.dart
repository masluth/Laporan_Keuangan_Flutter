import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../../security/data/security_repository.dart';
import '../../transactions/providers/transaction_provider.dart';

// =========================================================
// AUTH REPOSITORY PROVIDER
// =========================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// =========================================================
// SECURITY REPOSITORY PROVIDER
// =========================================================

final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  return SecurityRepository();
});

// =========================================================
// AUTH STATE
// =========================================================

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool requiresTwoFactor;
  final String? email;
  final String? userName;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = true,
    this.requiresTwoFactor = false,
    this.email,
    this.userName,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? requiresTwoFactor,
    String? email,
    String? userName,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated:
          isAuthenticated ?? this.isAuthenticated,
      isLoading:
          isLoading ?? this.isLoading,
      requiresTwoFactor:
          requiresTwoFactor ?? this.requiresTwoFactor,
      email:
          email ?? this.email,
      userName:
          userName ?? this.userName,
      error: clearError
          ? null
          : (error ?? this.error),
    );
  }
}

// =========================================================
// AUTH NOTIFIER
// =========================================================

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SecurityRepository _securityRepository;
  final Ref _ref;

  AuthNotifier(
    this._repository,
    this._securityRepository,
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
       * Kolom "id" menggunakan UUID yang sama
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

      // -----------------------------------------------------
      // TIDAK ADA SESSION
      // -----------------------------------------------------

      if (session == null) {
        state = const AuthState(
          isAuthenticated: false,
          isLoading: false,
          requiresTwoFactor: false,
        );

        debugPrint(
          'TIDAK ADA SESSION USER.',
        );

        return;
      }

      final user = session.user;

      // -----------------------------------------------------
      // GET PROFILE
      // -----------------------------------------------------

      final userName =
          await _getUserName(user);

      // -----------------------------------------------------
      // CEK 2FA
      // -----------------------------------------------------

      final twoFactorEnabled =
          await _securityRepository.isTwoFactorEnabled();

      debugPrint(
        'CURRENT USER ID: ${user.id}',
      );

      debugPrint(
        'CURRENT USER EMAIL: ${user.email}',
      );

      debugPrint(
        'CURRENT USER NAME: $userName',
      );

      debugPrint(
        'CURRENT 2FA ENABLED: $twoFactorEnabled',
      );

      // -----------------------------------------------------
      // 2FA AKTIF
      // -----------------------------------------------------

      if (twoFactorEnabled) {
        state = AuthState(
          isAuthenticated: false,
          isLoading: false,
          requiresTwoFactor: true,
          email: user.email,
          userName: userName,
        );

        debugPrint(
          'Session ditemukan. 2FA diperlukan.',
        );

        return;
      }

      // -----------------------------------------------------
      // 2FA TIDAK AKTIF
      // -----------------------------------------------------

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        requiresTwoFactor: false,
        email: user.email,
        userName: userName,
      );

      debugPrint(
        'Session valid. User authenticated.',
      );
    } catch (e) {
      debugPrint(
        'Check Session Error: $e',
      );

      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        requiresTwoFactor: false,
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
      clearError: true,
    );

    // -----------------------------------------------------
    // LOGIN SUPABASE
    // -----------------------------------------------------

    final success =
        await _repository.signInWithEmail(
      email,
      password,
    );

    // -----------------------------------------------------
    // LOGIN GAGAL
    // -----------------------------------------------------

    if (!success) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        requiresTwoFactor: false,
        error:
            'Gagal masuk. Periksa email & kata sandi.',
      );

      return false;
    }

    try {
      // ---------------------------------------------------
      // GET SESSION
      // ---------------------------------------------------

      final session =
          Supabase.instance.client.auth.currentSession;

      final user = session?.user;

      if (user == null) {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          requiresTwoFactor: false,
          error: 'User tidak ditemukan.',
        );

        return false;
      }

      // ---------------------------------------------------
      // GET PROFILE
      // ---------------------------------------------------

      final userName =
          await _getUserName(user);

      // ---------------------------------------------------
      // CEK 2FA
      // ---------------------------------------------------

      final twoFactorEnabled =
          await _securityRepository.isTwoFactorEnabled();

      debugPrint(
        'LOGIN USER ID: ${user.id}',
      );

      debugPrint(
        'LOGIN EMAIL: ${user.email}',
      );

      debugPrint(
        'LOGIN USER NAME: $userName',
      );

      debugPrint(
        'LOGIN 2FA ENABLED: $twoFactorEnabled',
      );

      // ---------------------------------------------------
      // 2FA AKTIF
      // ---------------------------------------------------

      if (twoFactorEnabled) {
        state = AuthState(
          isAuthenticated: false,
          isLoading: false,
          requiresTwoFactor: true,
          email: user.email ?? email,
          userName: userName,
        );

        debugPrint(
          '2FA diperlukan sebelum masuk dashboard.',
        );

        return true;
      }

      // ---------------------------------------------------
      // 2FA TIDAK AKTIF
      // ---------------------------------------------------

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        requiresTwoFactor: false,
        email: user.email ?? email,
        userName: userName,
      );

      debugPrint(
        'Login berhasil tanpa 2FA.',
      );

      // ---------------------------------------------------
      // RESET TRANSACTION STATE
      // ---------------------------------------------------

      _ref.invalidate(transactionProvider);

      return true;
    } catch (e) {
      debugPrint(
        'Login Profile Error: $e',
      );

      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        requiresTwoFactor: false,
        error:
            'Gagal mengambil data profil.',
      );

      return false;
    }
  }

  // =======================================================
  // VERIFY TWO FACTOR
  // =======================================================

  Future<bool> verifyTwoFactor(
    String pin,
  ) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      clearError: true,
    );

    try {
      // ---------------------------------------------------
      // VERIFY PIN
      // ---------------------------------------------------

      final verified =
          await _securityRepository.verifyPin(pin);

      // ---------------------------------------------------
      // PIN SALAH
      // ---------------------------------------------------

      if (!verified) {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          requiresTwoFactor: true,
          error: 'PIN 2FA salah.',
        );

        debugPrint(
          '2FA verification gagal.',
        );

        return false;
      }

      // ---------------------------------------------------
      // GET SESSION
      // ---------------------------------------------------

      final session =
          Supabase.instance.client.auth.currentSession;

      final user = session?.user;

      if (user == null) {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          requiresTwoFactor: false,
          error:
              'Session user tidak ditemukan.',
        );

        return false;
      }

      // ---------------------------------------------------
      // GET PROFILE
      // ---------------------------------------------------

      final userName =
          await _getUserName(user);

      // ---------------------------------------------------
      // AUTHENTICATION SELESAI
      // ---------------------------------------------------

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        requiresTwoFactor: false,
        email: user.email,
        userName: userName,
      );

      // ---------------------------------------------------
      // RESET TRANSACTION STATE
      // ---------------------------------------------------

      _ref.invalidate(transactionProvider);

      debugPrint(
        '2FA berhasil diverifikasi.',
      );

      debugPrint(
        'User diperbolehkan masuk dashboard.',
      );

      return true;
    } catch (e) {
      debugPrint(
        'Verify 2FA Error: $e',
      );

      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        requiresTwoFactor: true,
        error:
            'Terjadi kesalahan saat memverifikasi PIN.',
      );

      return false;
    }
  }

  // =======================================================
  // CANCEL TWO FACTOR LOGIN
  // =======================================================

  Future<void> cancelTwoFactorLogin() async {
    try {
      /*
       * Login email/password sudah membuat session
       * Supabase.
       *
       * Karena PIN 2FA belum berhasil diverifikasi,
       * session tersebut harus dibuang ketika user
       * membatalkan proses login.
       */

      await _repository.signOut();

      // ---------------------------------------------------
      // RESET TRANSACTION STATE
      // ---------------------------------------------------

      _ref.invalidate(transactionProvider);

      // ---------------------------------------------------
      // RESET AUTH STATE
      // ---------------------------------------------------

      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        requiresTwoFactor: false,
        email: null,
        userName: null,
        error: null,
      );

      debugPrint(
        '2FA LOGIN DIBATALKAN.',
      );
    } catch (e) {
      debugPrint(
        'Cancel Two Factor Login Error: $e',
      );

      // Tetap reset state aplikasi.
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        requiresTwoFactor: false,
        email: null,
        userName: null,
        error: null,
      );
    }
  }

  // =======================================================
  // LOGOUT
  // =======================================================

  Future<void> logout() async {
    try {
      // ---------------------------------------------------
      // LOGOUT SUPABASE
      // ---------------------------------------------------

      await _repository.signOut();

      // ---------------------------------------------------
      // RESET TRANSACTION STATE
      // ---------------------------------------------------

      _ref.invalidate(transactionProvider);

      // ---------------------------------------------------
      // RESET AUTH STATE
      // ---------------------------------------------------

      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        requiresTwoFactor: false,
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

    final securityRepository =
        ref.watch(securityRepositoryProvider);

    return AuthNotifier(
      repository,
      securityRepository,
      ref,
    );
  },
);