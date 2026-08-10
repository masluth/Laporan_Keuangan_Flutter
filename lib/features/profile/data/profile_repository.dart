import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileModel {
  final String id;
  final String fullName;
  final String businessName;
  final String? createdAt;
  final String? updatedAt;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.businessName,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      businessName: map['business_name']?.toString() ?? '',
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'business_name': businessName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository([SupabaseClient? supabase])
      : _supabase =
            supabase ?? Supabase.instance.client;

  // ============================================
  // CURRENT USER ID
  // ============================================

  String? get currentUserId {
    return _supabase.auth.currentUser?.id;
  }

  // ============================================
  // GET CURRENT USER PROFILE
  // ============================================

  Future<ProfileModel?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login.');
    }

    debugPrint(
      'GET PROFILE USER ID: ${user.id}',
    );

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      debugPrint(
        'Profile tidak ditemukan untuk user: ${user.id}',
      );

      return null;
    }

    return ProfileModel.fromMap(
      Map<String, dynamic>.from(response),
    );
  }

  // ============================================
  // UPDATE PROFILE
  // ============================================

  Future<ProfileModel> updateProfile({
    required String fullName,
    required String businessName,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login.');
    }

    final response = await _supabase
        .from('profiles')
        .update({
          'full_name': fullName.trim(),
          'business_name': businessName.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', user.id)
        .select()
        .single();

    return ProfileModel.fromMap(
      Map<String, dynamic>.from(response),
    );
  }
}