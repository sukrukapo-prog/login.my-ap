import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FirestoreService — syncs ALL user progress data to Firestore.
///
/// Firestore structure:
///   users/{uid}                          ← profile (name, avatar, weight, etc.)
///   users/{uid}/meditation/{YYYY-MM-DD}  ← daily meditation minutes
///   users/{uid}/history/{auto-id}        ← session history entries
///   users/{uid}/favorites/{sessionId}    ← favorited sessions
///   users/{uid}/stats/summary            ← total sessions, total minutes
///   users/{uid}/settings/prefs           ← daily goal
///
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  static bool get _isLoggedIn => _uid != null;

  // ── Meditation minutes ─────────────────────────────────────────────────────

  static Future<void> addMeditationMinutes(DateTime date, int minutes) async {
    if (!_isLoggedIn || minutes <= 0) return;
    try {
      await _db.collection('users').doc(_uid)
          .collection('meditation').doc(_dateKey(date))
          .set({
        'date': _dateKey(date),
        'minutes': FieldValue.increment(minutes),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _db.collection('users').doc(_uid)
          .collection('stats').doc('summary')
          .set({
        'totalMinutes': FieldValue.increment(minutes),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('[Firestore] addMeditationMinutes: $e');
    }
  }

  static Future<int> getMeditationMinutes(DateTime date) async {
    if (!_isLoggedIn) return 0;
    try {
      final doc = await _db.collection('users').doc(_uid)
          .collection('meditation').doc(_dateKey(date)).get();
      return (doc.data()?['minutes'] as int?) ?? 0;
    } catch (_) { return 0; }
  }

  static Future<List<int>> getWeeklyMeditationData() async {
    if (!_isLoggedIn) return List.filled(7, 0);
    try {
      final today = DateTime.now();
      final List<int> result = [];
      for (int i = 6; i >= 0; i--) {
        result.add(await getMeditationMinutes(today.subtract(Duration(days: i))));
      }
      return result;
    } catch (_) { return List.filled(7, 0); }
  }

  static Future<int> getMeditationMinutesForLastDays(int days) async {
    if (!_isLoggedIn) return 0;
    int total = 0;
    final today = DateTime.now();
    for (int i = 0; i < days; i++) {
      total += await getMeditationMinutes(today.subtract(Duration(days: i)));
    }
    return total;
  }

  // ── Session history ────────────────────────────────────────────────────────

  static Future<void> addMeditationHistory({
    required String sessionId,
    required String sessionName,
    required String type,
    required int minutes,
  }) async {
    if (!_isLoggedIn) return;
    try {
      await _db.collection('users').doc(_uid).collection('history').add({
        'sessionId': sessionId,
        'sessionName': sessionName,
        'type': type,
        'minutes': minutes,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _db.collection('users').doc(_uid)
          .collection('stats').doc('summary')
          .set({
        'totalSessions': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('[Firestore] addMeditationHistory: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMeditationHistory() async {
    if (!_isLoggedIn) return [];
    try {
      final snap = await _db.collection('users').doc(_uid)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        return {
          'sessionId': data['sessionId'] ?? '',
          'sessionName': data['sessionName'] ?? '',
          'type': data['type'] ?? '',
          'minutes': data['minutes'] ?? 0,
          'timestamp': (data['timestamp'] as Timestamp?)
              ?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
        };
      }).toList();
    } catch (_) { return []; }
  }

  // ── Favorites ──────────────────────────────────────────────────────────────

  static Future<void> toggleFavorite(String sessionId) async {
    if (!_isLoggedIn) return;
    try {
      final ref = _db.collection('users').doc(_uid)
          .collection('favorites').doc(sessionId);
      final doc = await ref.get();
      if (doc.exists) {
        await ref.delete();
      } else {
        await ref.set({'sessionId': sessionId, 'addedAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      developer.log('[Firestore] toggleFavorite: $e');
    }
  }

  static Future<bool> isFavorite(String sessionId) async {
    if (!_isLoggedIn) return false;
    try {
      final doc = await _db.collection('users').doc(_uid)
          .collection('favorites').doc(sessionId).get();
      return doc.exists;
    } catch (_) { return false; }
  }

  static Future<List<String>> getFavorites() async {
    if (!_isLoggedIn) return [];
    try {
      final snap = await _db.collection('users').doc(_uid)
          .collection('favorites').get();
      return snap.docs.map((d) => d.id).toList();
    } catch (_) { return []; }
  }

  // ── Settings ───────────────────────────────────────────────────────────────

  static Future<void> setDailyGoalMinutes(int minutes) async {
    if (!_isLoggedIn) return;
    try {
      await _db.collection('users').doc(_uid)
          .collection('settings').doc('prefs')
          .set({'dailyGoalMinutes': minutes}, SetOptions(merge: true));
    } catch (e) {
      developer.log('[Firestore] setDailyGoalMinutes: $e');
    }
  }

  static Future<int> getDailyGoalMinutes() async {
    if (!_isLoggedIn) return 15;
    try {
      final doc = await _db.collection('users').doc(_uid)
          .collection('settings').doc('prefs').get();
      return (doc.data()?['dailyGoalMinutes'] as int?) ?? 15;
    } catch (_) { return 15; }
  }

  // ── All-time stats ─────────────────────────────────────────────────────────

  static Future<Map<String, int>> getAllTimeStats() async {
    if (!_isLoggedIn) return _emptyStats();
    try {
      final summary = await _db.collection('users').doc(_uid)
          .collection('stats').doc('summary').get();
      final data = summary.data() ?? {};
      final totalMins = (data['totalMinutes'] as int?) ?? 0;
      final totalSessions = (data['totalSessions'] as int?) ?? 0;
      final streak = await _calculateStreak();
      return {
        'totalMinutes': totalMins,
        'totalHours': totalMins ~/ 60,
        'streakDays': streak['current']!,
        'longestStreak': streak['longest']!,
        'totalSessions': totalSessions,
      };
    } catch (_) { return _emptyStats(); }
  }

  static Future<Map<String, int>> _calculateStreak() async {
    try {
      final snap = await _db.collection('users').doc(_uid)
          .collection('meditation')
          .orderBy('date', descending: true)
          .limit(365)
          .get();

      final datesWithMins = <String>{};
      for (final doc in snap.docs) {
        if (((doc.data()['minutes'] as int?) ?? 0) > 0) {
          datesWithMins.add(doc.id);
        }
      }

      final today = DateTime.now();
      int current = 0;
      int longest = 0;
      int running = 0;
      bool currentCounted = false;

      for (int i = 0; i < 365; i++) {
        final key = _dateKey(today.subtract(Duration(days: i)));
        if (datesWithMins.contains(key)) {
          running++;
          if (!currentCounted) { current = running; }
          if (running > longest) longest = running;
        } else {
          if (i > 0) { currentCounted = true; running = 0; }
        }
      }
      return {'current': current, 'longest': longest};
    } catch (_) { return {'current': 0, 'longest': 0}; }
  }

  static Future<void> incrementTotalSessions() async {
    if (!_isLoggedIn) return;
    try {
      await _db.collection('users').doc(_uid)
          .collection('stats').doc('summary')
          .set({'totalSessions': FieldValue.increment(1)}, SetOptions(merge: true));
    } catch (e) {
      developer.log('[Firestore] incrementTotalSessions: $e');
    }
  }

  // ── Profile updates ────────────────────────────────────────────────────────

  static Future<void> updateDisplayName(String name) async {
    if (!_isLoggedIn) return;
    try {
      await _db.collection('users').doc(_uid).update({'name': name});
    } catch (e) {
      developer.log('[Firestore] updateDisplayName: $e');
    }
  }

  static Future<void> updateStats({double? weightKg, double? heightCm, int? age}) async {
    if (!_isLoggedIn) return;
    try {
      final updates = <String, dynamic>{};
      if (weightKg != null) updates['currentWeightKg'] = weightKg;
      if (heightCm != null) updates['heightCm'] = heightCm;
      if (age != null) updates['age'] = age;
      if (updates.isNotEmpty) {
        await _db.collection('users').doc(_uid).update(updates);
      }
    } catch (e) {
      developer.log('[Firestore] updateStats: $e');
    }
  }

  static Future<void> saveAvatarId(String avatarId) async {
    if (!_isLoggedIn) return;
    try {
      await _db.collection('users').doc(_uid).update({'avatarId': avatarId});
    } catch (e) {
      developer.log('[Firestore] saveAvatarId: $e');
    }
  }

  // ── Full sync: Firestore → LocalStorage (called after login) ───────────────

  static Future<void> syncToLocal() async {
    if (!_isLoggedIn) return;
    developer.log('[Firestore] Syncing to local cache...');
    try {
      final prefs = await SharedPreferences.getInstance();

      // Daily goal
      final goal = await getDailyGoalMinutes();
      await prefs.setInt('daily_goal_minutes', goal);

      // Last 30 days meditation minutes
      final today = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final d = today.subtract(Duration(days: i));
        final mins = await getMeditationMinutes(d);
        final key = 'meditation_mins_${_dateKey(d)}';
        await prefs.setInt(key, mins);
      }

      // Favorites
      final favs = await getFavorites();
      await prefs.setStringList('meditation_favorites', favs);

      // Total sessions from stats
      final stats = await getAllTimeStats();
      await prefs.setInt('total_sessions', stats['totalSessions'] ?? 0);

      developer.log('[Firestore] Sync complete.');
    } catch (e) {
      developer.log('[Firestore] Sync error: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

  static Map<String, int> _emptyStats() => {
    'totalMinutes': 0,
    'totalHours': 0,
    'streakDays': 0,
    'longestStreak': 0,
    'totalSessions': 0,
  };
}