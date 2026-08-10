import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_repository.dart';

// ============================================================
// PROFILE REPOSITORY PROVIDER
// ============================================================

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// ============================================================
// PROFILE STATE
// ============================================================

class ProfileState {
  final ProfileModel? profile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    ProfileModel? profile,
    bool? isLoading,
    String? error,
    bool clearProfile = false,
  }) {
    return ProfileState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ============================================================
// PROFILE NOTIFIER
// ============================================================

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository)
      : super(const ProfileState()) {
    loadProfile();
  }

  // ==========================================================
  // LOAD PROFILE
  // ==========================================================

  Future<void> loadProfile() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final profile =
          await _repository.getCurrentProfile();

      state = ProfileState(
        profile: profile,
        isLoading: false,
        error: null,
      );

      debugPrint(
        'PROFILE LOADED: ${profile?.fullName}',
      );

      debugPrint(
        'BUSINESS LOADED: ${profile?.businessName}',
      );
    } catch (e) {
      debugPrint(
        'Gagal mengambil profile: $e',
      );

      state = ProfileState(
        profile: null,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ==========================================================
  // UPDATE PROFILE
  // ==========================================================

  Future<bool> updateProfile({
    required String fullName,
    required String businessName,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final updatedProfile =
          await _repository.updateProfile(
        fullName: fullName,
        businessName: businessName,
      );

      state = ProfileState(
        profile: updatedProfile,
        isLoading: false,
        error: null,
      );

      return true;
    } catch (e) {
      debugPrint(
        'Gagal memperbarui profile: $e',
      );

      state = ProfileState(
        profile: state.profile,
        isLoading: false,
        error: e.toString(),
      );

      return false;
    }
  }

  // ==========================================================
  // CLEAR PROFILE
  // ==========================================================

  void clearProfile() {
    state = const ProfileState();
  }
}

// ============================================================
// PROFILE PROVIDER
// ============================================================

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) {
    final repository =
        ref.watch(profileRepositoryProvider);

    return ProfileNotifier(repository);
  },
);