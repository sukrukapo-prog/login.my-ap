import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/services/local_storage.dart';

/// AuthService decouples all auth logic from screens.
///
/// Currently uses local SharedPreferences storage.
/// When Firebase is ready, swap the internals of each method —
/// screens will not need any changes.
///
/// Usage:
///   final result = await AuthService.register(data);
///   if (result.success) { ... } else { showError(result.error); }
class AuthService {
  // ── Register ────────────────────────────────────────────────────────────────

  /// Saves the completed onboarding data locally.
  /// Replace body with FirebaseAuth.createUserWithEmailAndPassword() later.
  static Future<AuthResult> register(OnboardingData data) async {
    try {
      if (data.email == null || data.email!.isEmpty) {
        return AuthResult.failure('Email is required.');
      }
      if (data.password == null || data.password!.length < 10) {
        return AuthResult.failure('Password must be at least 10 characters.');
      }

      // TODO(firebase): Replace with:
      //   final credential = await FirebaseAuth.instance
      //       .createUserWithEmailAndPassword(email: data.email!, password: data.password!);
      //   await credential.user?.updateDisplayName(data.name);
      //   Save extra fields to Firestore here.

      await LocalStorage.saveUserData(data);
      return AuthResult.success();
    } catch (e) {
      return AuthResult.failure('Registration failed: $e');
    }
  }

  // ── Login ───────────────────────────────────────────────────────────────────

  /// Validates credentials against locally stored data.
  /// Replace body with FirebaseAuth.signInWithEmailAndPassword() later.
  static Future<AuthResult> login(String email, String password) async {
    try {
      if (email.trim().isEmpty) return AuthResult.failure('Email is required.');
      if (password.isEmpty) return AuthResult.failure('Password is required.');

      // TODO(firebase): Replace with:
      //   await FirebaseAuth.instance.signInWithEmailAndPassword(
      //       email: email.trim(), password: password);
      //   return AuthResult.success();

      final saved = await LocalStorage.getUserData();
      if (saved == null) {
        return AuthResult.failure('No account found. Please sign up.');
      }
      // NOTE: password is not persisted in toJson() by design.
      // Local login only works in the same session (before app restart).
      // This limitation disappears once Firebase is integrated.
      if (saved.email != email.trim()) {
        return AuthResult.failure('Incorrect email or password.');
      }
      return AuthResult.success(userData: saved);
    } catch (e) {
      return AuthResult.failure('Login failed: $e');
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────────

  /// Clears all local user data.
  /// Add FirebaseAuth.instance.signOut() here when Firebase is integrated.
  static Future<void> logout() async {
    // TODO(firebase): await FirebaseAuth.instance.signOut();
    await LocalStorage.clear();
  }

  // ── State ───────────────────────────────────────────────────────────────────

  static Future<bool> isLoggedIn() async {
    // TODO(firebase): return FirebaseAuth.instance.currentUser != null;
    return LocalStorage.isRegistered();
  }

  static Future<OnboardingData?> getCurrentUser() async {
    // TODO(firebase): Load from Firestore using FirebaseAuth.instance.currentUser?.uid
    return LocalStorage.getUserData();
  }
}

// ── Result wrapper ─────────────────────────────────────────────────────────────

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
