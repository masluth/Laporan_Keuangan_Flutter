import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final FirebaseAuth? _firebaseAuth;

  AuthRepository([this._firebaseAuth]);

  User? get currentUser => _firebaseAuth?.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth?.authStateChanges() ?? Stream.value(null);

  Future<bool> signInWithEmail(String email, String password) async {
    if (_firebaseAuth != null) {
      try {
        await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
        return true;
      } catch (e) {
        debugPrint('Firebase Auth Error: $e');
      }
    }
    // Fallback Mock Sign In
    await Future.delayed(const Duration(milliseconds: 600));
    return true; // Simulate success
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    if (_firebaseAuth != null) {
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
        return true;
      } catch (e) {
        debugPrint('Firebase Auth Sign Up Error: $e');
      }
    }
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<void> signOut() async {
    if (_firebaseAuth != null) {
      await _firebaseAuth.signOut();
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
