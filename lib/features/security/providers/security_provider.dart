import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/security_repository.dart';

// =========================================================
// SECURITY REPOSITORY PROVIDER
// =========================================================

final securityRepositoryProvider =
    Provider<SecurityRepository>((ref) {
  return SecurityRepository();
});

// =========================================================
// SECURITY STATE
// =========================================================

class SecurityState {
  final bool isLoading;
  final bool isTwoFactorEnabled;
  final String? error;

  const SecurityState({
    this.isLoading = true,
    this.isTwoFactorEnabled = false,
    this.error,
  });

  SecurityState copyWith({
    bool? isLoading,
    bool? isTwoFactorEnabled,
    String? error,
  }) {
    return SecurityState(
      isLoading: isLoading ?? this.isLoading,
      isTwoFactorEnabled:
          isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      error: error,
    );
  }
}

// =========================================================
// SECURITY NOTIFIER
// =========================================================

class SecurityNotifier
    extends StateNotifier<SecurityState> {
  final SecurityRepository _repository;

  SecurityNotifier(this._repository)
      : super(const SecurityState()) {
    loadSecuritySettings();
  }

  // =======================================================
  // PIN VALIDATION
  // =======================================================

  bool _isValidPin(String pin) {
    return RegExp(r'^\d{6}$').hasMatch(pin);
  }

  // =======================================================
  // LOAD SECURITY SETTINGS
  // =======================================================

  Future<void> loadSecuritySettings() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final settings =
          await _repository.getTwoFactorSettings();

      if (settings == null) {
        state = const SecurityState(
          isLoading: false,
          isTwoFactorEnabled: false,
        );

        return;
      }

      state = SecurityState(
        isLoading: false,
        isTwoFactorEnabled:
            settings['two_factor_enabled'] == true,
      );
    } catch (e) {
      state = const SecurityState(
        isLoading: false,
        isTwoFactorEnabled: false,
        error:
            'Gagal mengambil pengaturan keamanan.',
      );
    }
  }

  // =======================================================
  // ENABLE TWO FACTOR
  // =======================================================

  Future<bool> enableTwoFactor(
    String pin,
  ) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      // ---------------------------------------------------
      // VALIDASI PIN
      // ---------------------------------------------------

      if (!_isValidPin(pin)) {
        state = state.copyWith(
          isLoading: false,
          error:
              'PIN harus terdiri dari 6 digit angka.',
        );

        return false;
      }

      // ---------------------------------------------------
      // SIMPAN PIN / AKTIFKAN 2FA
      // ---------------------------------------------------

      final success =
          await _repository.enableTwoFactor(
        pin,
      );

      if (!success) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Gagal mengaktifkan verifikasi dua langkah.',
        );

        return false;
      }

      state = const SecurityState(
        isLoading: false,
        isTwoFactorEnabled: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Terjadi kesalahan saat mengaktifkan 2FA.',
      );

      return false;
    }
  }

  // =======================================================
  // VERIFY PIN
  // =======================================================

  Future<bool> verifyPin(
    String pin,
  ) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      // ---------------------------------------------------
      // VALIDASI FORMAT PIN
      // ---------------------------------------------------

      if (!_isValidPin(pin)) {
        state = state.copyWith(
          isLoading: false,
          error:
              'PIN harus terdiri dari 6 digit angka.',
        );

        return false;
      }

      // ---------------------------------------------------
      // VERIFIKASI KE REPOSITORY
      // ---------------------------------------------------

      final valid =
          await _repository.verifyPin(pin);

      if (!valid) {
        state = state.copyWith(
          isLoading: false,
          error: 'PIN salah.',
        );

        return false;
      }

      state = state.copyWith(
        isLoading: false,
        error: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Terjadi kesalahan saat memverifikasi PIN.',
      );

      return false;
    }
  }

  // =======================================================
  // DISABLE TWO FACTOR
  // =======================================================

  Future<bool> disableTwoFactor(
    String pin,
  ) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      // ---------------------------------------------------
      // VALIDASI FORMAT PIN
      // ---------------------------------------------------

      if (!_isValidPin(pin)) {
        state = state.copyWith(
          isLoading: false,
          error:
              'PIN harus terdiri dari 6 digit angka.',
        );

        return false;
      }

      // ---------------------------------------------------
      // VERIFIKASI PIN
      // ---------------------------------------------------

      final valid =
          await _repository.verifyPin(pin);

      if (!valid) {
        state = state.copyWith(
          isLoading: false,
          error:
              'PIN salah. Verifikasi gagal.',
        );

        return false;
      }

      // ---------------------------------------------------
      // NONAKTIFKAN 2FA
      // ---------------------------------------------------

      final success =
          await _repository.disableTwoFactor();

      if (!success) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Gagal menonaktifkan verifikasi dua langkah.',
        );

        return false;
      }

      state = const SecurityState(
        isLoading: false,
        isTwoFactorEnabled: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Terjadi kesalahan saat menonaktifkan 2FA.',
      );

      return false;
    }
  }

  // =======================================================
  // REFRESH
  // =======================================================

  Future<void> refresh() async {
    await loadSecuritySettings();
  }
}

// =========================================================
// SECURITY PROVIDER
// =========================================================

final securityProvider =
    StateNotifierProvider<
        SecurityNotifier,
        SecurityState>(
  (ref) {
    final repository =
        ref.watch(
      securityRepositoryProvider,
    );

    return SecurityNotifier(
      repository,
    );
  },
);