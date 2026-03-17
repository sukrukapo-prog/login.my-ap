import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/services/firestore_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get currentFirebaseUser => _auth.currentUser;

  // ── Register ───────────────────────────────────────────────────────────────

  static Future<AuthResult> register(OnboardingData data) async {
    try {
      if (data.email == null || data.email!.isEmpty) {
        return AuthResult.failure('Email is required.');
      }
      if (data.password == null || data.password!.length < 10) {
        return AuthResult.failure('Password must be at least 10 characters.');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: data.email!.trim(),
        password: data.password!,
      );

      final uid = credential.user!.uid;
      await credential.user?.updateDisplayName(data.name ?? '');

      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': data.email!.trim(),
        'name': data.name ?? '',
        'fullName': data.fullName ?? '',
        'age': data.age,
        'gender': data.gender,
        'country': data.country,
        'heightCm': data.heightCm,
        'currentWeightKg': data.currentWeightKg,
        'goalWeightKg': data.goalWeightKg,
        'goals': data.goals.toList(),
        'avatarId': data.avatarId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      await LocalStorage.saveUserData(data);
      // Create initial leaderboard entry for new user
      FirestoreService.updateLeaderboardScore();

      developer.log('[AuthService] Registered user: $uid');
      return AuthResult.success(userData: data);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendlyAuthError(e.code));
    } catch (e) {
      return AuthResult.failure('Registration failed: $e');
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  static Future<AuthResult> login(String email, String password) async {
    try {
      if (email.trim().isEmpty) return AuthResult.failure('Email is required.');
      if (password.isEmpty) return AuthResult.failure('Password is required.');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final doc = await _db.collection('users').doc(uid).get();
      OnboardingData userData;

      if (doc.exists) {
        userData = _onboardingDataFromDoc(doc.data()!);
        await _db.collection('users').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        userData = OnboardingData()
          ..email = email.trim()
          ..name = credential.user?.displayName ?? '';
      }

      await LocalStorage.saveUserData(userData);
      if (userData.avatarId != null) {
        await LocalStorage.saveAvatarId(userData.avatarId!);
      }
      // Pull all Firestore data (meditation, favorites, settings) into local cache
      await FirestoreService.syncToLocal();
      // Push latest score to leaderboard
      FirestoreService.updateLeaderboardScore();

      developer.log('[AuthService] Logged in: $uid');
      return AuthResult.success(userData: userData);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendlyAuthError(e.code));
    } catch (e) {
      return AuthResult.failure('Login failed: $e');
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    await _auth.signOut();
    await LocalStorage.clear();
    developer.log('[AuthService] User signed out.');
  }

  // ── Auth state ─────────────────────────────────────────────────────────────

  static Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  static Future<OnboardingData?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return _onboardingDataFromDoc(doc.data()!);
      }
    } catch (e) {
      developer.log('[AuthService] Firestore fetch failed, using local cache: $e');
    }

    return LocalStorage.getUserData();
  }

  // ── Update profile ─────────────────────────────────────────────────────────

  static Future<void> updateProfile({
    String? name,
    String? avatarId,
    double? weightKg,
    double? heightCm,
    int? age,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (avatarId != null) updates['avatarId'] = avatarId;
    if (weightKg != null) updates['currentWeightKg'] = weightKg;
    if (heightCm != null) updates['heightCm'] = heightCm;
    if (age != null) updates['age'] = age;

    if (updates.isNotEmpty) {
      await _db.collection('users').doc(uid).update(updates);
      await LocalStorage.updateStats(weightKg: weightKg, heightCm: heightCm, age: age);
      if (name != null) await LocalStorage.updateDisplayName(name);
      if (avatarId != null) await LocalStorage.saveAvatarId(avatarId);
    }
  }

  // ── Password reset ─────────────────────────────────────────────────────────

  static Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendlyAuthError(e.code));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static OnboardingData _onboardingDataFromDoc(Map<String, dynamic> data) {
    return OnboardingData()
      ..email = data['email'] as String?
      ..name = data['name'] as String?
      ..fullName = data['fullName'] as String?
      ..age = data['age'] as int?
      ..gender = data['gender'] as String?
      ..country = data['country'] as String?
      ..heightCm = (data['heightCm'] as num?)?.toDouble()
      ..currentWeightKg = (data['currentWeightKg'] as num?)?.toDouble()
      ..goalWeightKg = (data['goalWeightKg'] as num?)?.toDouble()
      ..goals = (data['goals'] as List?)?.cast<String>().toSet() ?? {}
      ..avatarId = data['avatarId'] as String?;
  }

  static String _friendlyAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 10 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

class AuthResult {
  final bool success;
  final String? error;
  final OnboardingData? userData;

  const AuthResult._({required this.success, this.error, this.userData});

  factory AuthResult.success({OnboardingData? userData}) =>
      AuthResult._(success: true, userData: userData);

  factory AuthResult.failure(String error) =>
      AuthResult._(success: false, error: error);
}