import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitmetrics/models/onboarding_data.dart';

/// Single source of truth for all local persistence.
/// All screens must use this class — never call SharedPreferences directly.
class LocalStorage {
  // ── Keys ────────────────────────────────────────────────────────────────────
  static const String _keyRegistered = 'isRegistered';
  static const String _keyUserData   = 'userData';
  static const String _keyAvatarId   = 'avatarId';

  // ── Auth ────────────────────────────────────────────────────────────────────

  static Future<void> saveUserData(OnboardingData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyRegistered, true);
      await prefs.setString(_keyUserData, jsonEncode(data.toJson()));
      developer.log('[LocalStorage] User data saved.');
    } catch (e, st) {
      developer.log('[LocalStorage] saveUserData error', error: e, stackTrace: st);
    }
  }

  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRegistered) ?? false;
  }

  static Future<OnboardingData?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_keyUserData);
      if (json == null) return null;
      return OnboardingData.fromJson(jsonDecode(json));
    } catch (e, st) {
      developer.log('[LocalStorage] getUserData error', error: e, stackTrace: st);
      return null;
    }
  }

  /// Wipes every user-related key. Call this on logout.
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyRegistered);
      await prefs.remove(_keyUserData);
      await prefs.remove(_keyAvatarId);
      final keys = prefs.getKeys()
          .where((k) => k.startsWith('meditation_mins_'))
          .toList();
      for (final k in keys) {
        await prefs.remove(k);
      }
      developer.log('[LocalStorage] All user data cleared.');
    } catch (e, st) {
      developer.log('[LocalStorage] clear error', error: e, stackTrace: st);
    }
  }

  // ── Avatar ──────────────────────────────────────────────────────────────────

  static Future<String?> getAvatarId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAvatarId);
  }

  static Future<void> saveAvatarId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatarId, id);
  }

  // ── Meditation stats ────────────────────────────────────────────────────────

  /// Zero-padded ISO date key: meditation_mins_2026-03-07
  static String _meditationKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return 'meditation_mins_' + y + '-' + m + '-' + d;
  }

  static Future<int> getMeditationMinutes(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_meditationKey(date)) ?? 0;
  }

  static Future<void> addMeditationMinutes(DateTime date, int minutes) async {
    if (minutes <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final key = _meditationKey(date);
    final existing = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, existing + minutes);
    developer.log('[LocalStorage] Meditation +' + minutes.toString() + ' min on ' + key);
  }

  /// Total minutes over last [days] days (including today).
  static Future<int> getMeditationMinutesForLastDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    int total = 0;
    for (int i = 0; i < days; i++) {
      final d = today.subtract(Duration(days: i));
      total += prefs.getInt(_meditationKey(d)) ?? 0;
    }
    return total;
  }

  // ── Profile helpers ─────────────────────────────────────────────────────────

  static Future<void> updateDisplayName(String name) async {
    try {
      final data = await getUserData();
      if (data == null) return;
      data.name = name;
      await saveUserData(data);
    } catch (e, st) {
      developer.log('[LocalStorage] updateDisplayName error', error: e, stackTrace: st);
    }
  }

  static Future<void> updateStats({
    double? weightKg,
    double? heightCm,
    int? age,
  }) async {
    try {
      final data = await getUserData();
      if (data == null) return;
      if (weightKg != null) data.currentWeightKg = weightKg;
      if (heightCm != null) data.heightCm = heightCm;
      if (age != null) data.age = age;
      await saveUserData(data);
    } catch (e, st) {
      developer.log('[LocalStorage] updateStats error', error: e, stackTrace: st);
    }
  }
}
