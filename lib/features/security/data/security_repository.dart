import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityRepository {
  final SupabaseClient _supabase;

  SecurityRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  // =========================================================
  // PBKDF2 CONFIGURATION
  // =========================================================

  static const int _pbkdf2Iterations = 100000;
  static const int _hashBits = 256;
  static const int _saltLength = 16;

  final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _pbkdf2Iterations,
    bits: _hashBits,
  );

  // =========================================================
  // CURRENT USER ID
  // =========================================================

  String? get currentUserId {
    return _supabase.auth.currentUser?.id;
  }

  // =========================================================
  // GET TWO FACTOR SETTINGS
  // =========================================================

  Future<Map<String, dynamic>?> getTwoFactorSettings() async {
    try {
      final userId = currentUserId;

      if (userId == null) {
        debugPrint(
          'Security Repository: User belum login.',
        );

        return null;
      }

      final response = await _supabase
          .from('user_security')
          .select(
            'user_id, two_factor_enabled, two_factor_pin_hash',
          )
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint(
        'Get Two Factor Settings Error: $e',
      );

      return null;
    }
  }

  // =========================================================
  // CHECK TWO FACTOR ENABLED
  // =========================================================

  Future<bool> isTwoFactorEnabled() async {
    try {
      final settings = await getTwoFactorSettings();

      if (settings == null) {
        return false;
      }

      return settings['two_factor_enabled'] == true;
    } catch (e) {
      debugPrint(
        'Check Two Factor Error: $e',
      );

      return false;
    }
  }

  // =========================================================
  // CREATE SECURITY SETTINGS
  // =========================================================

  Future<bool> createSecuritySettings() async {
    try {
      final userId = currentUserId;

      if (userId == null) {
        debugPrint(
          'Create Security Settings: User belum login.',
        );

        return false;
      }

      await _supabase
          .from('user_security')
          .insert({
            'user_id': userId,
            'two_factor_enabled': false,
            'two_factor_pin_hash': null,
          });

      debugPrint(
        'Security settings berhasil dibuat.',
      );

      return true;
    } catch (e) {
      debugPrint(
        'Create Security Settings Error: $e',
      );

      return false;
    }
  }

  // =========================================================
  // GENERATE PIN HASH
  // =========================================================

  Future<String> hashPin(String pin) async {
    if (!_isValidPin(pin)) {
      throw ArgumentError(
        'PIN harus terdiri dari 6 digit angka.',
      );
    }

    final random = Random.secure();

    final salt = List<int>.generate(
      _saltLength,
      (_) => random.nextInt(256),
    );

    final secretKey =
        await _pbkdf2.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );

    final hashBytes =
        await secretKey.extractBytes();

    final saltBase64 =
        base64UrlEncode(salt);

    final hashBase64 =
        base64UrlEncode(hashBytes);

    return [
      'pbkdf2-sha256',
      _pbkdf2Iterations.toString(),
      saltBase64,
      hashBase64,
    ].join('\$');
  }

  // =========================================================
  // VERIFY PIN
  // =========================================================

  Future<bool> verifyPin(String pin) async {
    try {
      if (!_isValidPin(pin)) {
        return false;
      }

      final settings =
          await getTwoFactorSettings();

      if (settings == null) {
        return false;
      }

      final enabled =
          settings['two_factor_enabled'] == true;

      if (!enabled) {
        return false;
      }

      final storedHash =
          settings['two_factor_pin_hash']
              ?.toString();

      if (storedHash == null ||
          storedHash.isEmpty) {
        return false;
      }

      final parts =
          storedHash.split('\$');

      if (parts.length != 4) {
        debugPrint(
          'Format PIN hash tidak valid.',
        );

        return false;
      }

      final algorithm = parts[0];
      final iterations =
          int.tryParse(parts[1]);
      final saltBase64 = parts[2];
      final hashBase64 = parts[3];

      if (algorithm != 'pbkdf2-sha256' ||
          iterations == null) {
        return false;
      }

      final salt =
          base64Url.decode(saltBase64);

      final expectedHash =
          base64Url.decode(hashBase64);

      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterations,
        bits: expectedHash.length * 8,
      );

      final secretKey =
          await pbkdf2.deriveKeyFromPassword(
        password: pin,
        nonce: salt,
      );

      final actualHash =
          await secretKey.extractBytes();

      return _constantTimeEquals(
        actualHash,
        expectedHash,
      );
    } catch (e) {
      debugPrint(
        'Verify PIN Error: $e',
      );

      return false;
    }
  }

  // =========================================================
  // UPDATE TWO FACTOR SETTINGS
  // =========================================================

  Future<bool> updateTwoFactorSettings({
    required bool enabled,
    String? pinHash,
  }) async {
    try {
      final userId = currentUserId;

      if (userId == null) {
        debugPrint(
          'Update Security Settings: User belum login.',
        );

        return false;
      }

      await _supabase
          .from('user_security')
          .update({
            'two_factor_enabled': enabled,
            'two_factor_pin_hash': pinHash,
            'updated_at':
                DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      debugPrint(
        'Two factor settings berhasil diperbarui.',
      );

      return true;
    } catch (e) {
      debugPrint(
        'Update Two Factor Settings Error: $e',
      );

      return false;
    }
  }

  // =========================================================
  // ENABLE TWO FACTOR WITH PIN
  // =========================================================

  Future<bool> enableTwoFactor(
    String pin,
  ) async {
    try {
      if (!_isValidPin(pin)) {
        debugPrint(
          'Enable 2FA gagal: PIN tidak valid.',
        );

        return false;
      }

      final settings =
          await getTwoFactorSettings();

      if (settings == null) {
        final created =
            await createSecuritySettings();

        if (!created) {
          return false;
        }
      }

      final pinHash =
          await hashPin(pin);

      return await updateTwoFactorSettings(
        enabled: true,
        pinHash: pinHash,
      );
    } catch (e) {
      debugPrint(
        'Enable Two Factor Error: $e',
      );

      return false;
    }
  }

  // =========================================================
  // DISABLE TWO FACTOR
  // =========================================================

  Future<bool> disableTwoFactor() async {
    try {
      return await updateTwoFactorSettings(
        enabled: false,
        pinHash: null,
      );
    } catch (e) {
      debugPrint(
        'Disable Two Factor Error: $e',
      );

      return false;
    }
  }

  // =========================================================
  // PIN VALIDATION
  // =========================================================

  bool _isValidPin(String pin) {
    return RegExp(
      r'^\d{6}$',
    ).hasMatch(pin);
  }

  // =========================================================
  // CONSTANT-TIME COMPARISON
  // =========================================================

  bool _constantTimeEquals(
    List<int> a,
    List<int> b,
  ) {
    if (a.length != b.length) {
      return false;
    }

    var difference = 0;

    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }

    return difference == 0;
  }
}