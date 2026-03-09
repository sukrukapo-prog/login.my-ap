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
  static const String _keyAvatarId       = 'avatarId';
  static const String _keySeenOnboarding  = 'seenOnboarding';
  static const String _keySeenWalkthrough = 'seenWalkthrough';

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

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySeenOnboarding) ?? false;
  }

  static Future<void> setSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeenOnboarding, true);
  }

  static Future<bool> hasSeenWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySeenWalkthrough) ?? false;
  }

  static Future<void> setSeenWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeenWalkthrough, true);
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

  // ── Meditation favorites ────────────────────────────────────────────────────

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('meditation_favorites') ?? [];
  }

  static Future<void> toggleFavorite(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('meditation_favorites') ?? [];
    if (favs.contains(sessionId)) {
      favs.remove(sessionId);
    } else {
      favs.add(sessionId);
    }
    await prefs.setStringList('meditation_favorites', favs);
  }

  static Future<bool> isFavorite(String sessionId) async {
    final favs = await getFavorites();
    return favs.contains(sessionId);
  }

  // ── Meditation history ──────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMeditationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('meditation_history') ?? [];
    return raw.map((e) => Map<String, dynamic>.from(
        (e.split('|').asMap()..remove(0)).isEmpty
            ? {}
            : {
          'sessionId': e.split('|')[0],
          'sessionName': e.split('|')[1],
          'type': e.split('|')[2],
          'minutes': int.tryParse(e.split('|')[3]) ?? 0,
          'timestamp': e.split('|')[4],
        })).toList();
  }

  static Future<void> addMeditationHistory({
    required String sessionId,
    required String sessionName,
    required String type,
    required int minutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('meditation_history') ?? [];
    final entry = '$sessionId|$sessionName|$type|$minutes|${DateTime.now().toIso8601String()}';
    history.insert(0, entry); // newest first
    if (history.length > 50) history.removeLast(); // keep last 50
    await prefs.setStringList('meditation_history', history);
  }

  // ── Daily goal ──────────────────────────────────────────────────────────────

  static Future<int> getDailyGoalMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_goal_minutes') ?? 15;
  }

  static Future<void> setDailyGoalMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal_minutes', minutes);
  }

  // ── All-time stats ──────────────────────────────────────────────────────────

  static Future<Map<String, int>> getAllTimeStats() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('meditation_mins_')).toList();
    int totalMins = 0;
    int streakDays = 0;
    int longestStreak = 0;
    int currentStreak = 0;
    final today = DateTime.now();

    // Calculate total minutes
    for (final k in keys) {
      totalMins += prefs.getInt(k) ?? 0;
    }

    // Calculate current streak
    for (int i = 0; i < 365; i++) {
      final d = today.subtract(Duration(days: i));
      final y = d.year.toString();
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      final key = 'meditation_mins_$y-$m-$day';
      final mins = prefs.getInt(key) ?? 0;
      if (mins > 0) {
        currentStreak++;
        if (currentStreak > longestStreak) longestStreak = currentStreak;
      } else if (i > 0) {
        break;
      }
    }
    streakDays = currentStreak;

    return {
      'totalMinutes': totalMins,
      'totalHours': totalMins ~/ 60,
      'streakDays': streakDays,
      'longestStreak': longestStreak,
      'totalSessions': prefs.getInt('total_sessions') ?? 0,
    };
  }

  static Future<bool> isFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('has_opened_app') ?? false);
  }

  static Future<void> markFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_opened_app', true);
  }

  static Future<void> incrementTotalSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('total_sessions') ?? 0;
    await prefs.setInt('total_sessions', current + 1);
  }

  // ── Weekly chart data ───────────────────────────────────────────────────────

  static Future<List<int>> getWeeklyMeditationData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    return List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      final y = d.year.toString();
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return prefs.getInt('meditation_mins_$y-$m-$day') ?? 0;
    });
  }

}