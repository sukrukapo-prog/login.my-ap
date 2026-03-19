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

      // Update leaderboard score
      await updateLeaderboardScore();
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
      // Get meditation dates
      final medSnap = await _db.collection('users').doc(_uid)
          .collection('meditation')
          .orderBy('date', descending: true)
          .limit(365)
          .get();
      final medDates = <String>{};
      for (final doc in medSnap.docs) {
        if (((doc.data()['minutes'] as int?) ?? 0) > 0) medDates.add(doc.id);
      }

      // Get workout dates
      final workoutSnap = await _db.collection('users').doc(_uid)
          .collection('workouts')
          .orderBy('loggedAt', descending: false)
          .get();
      final workoutDates = <String>{};
      for (final doc in workoutSnap.docs) {
        final date = doc.data()['date'] as String?;
        if (date != null) workoutDates.add(date);
      }

      // Get food activity dates
      final foodSnap = await _db.collection('users').doc(_uid)
          .collection('food_daily')
          .orderBy('date', descending: true)
          .limit(365)
          .get();
      final foodDates = <String>{};
      for (final doc in foodSnap.docs) {
        if (((doc.data()['totalCalories'] as int?) ?? 0) > 0) foodDates.add(doc.id);
      }

      // Union of all active dates
      final activeDates = {...medDates, ...workoutDates, ...foodDates};

      final today = DateTime.now();
      int current = 0;
      int longest = 0;
      int running = 0;
      bool currentCounted = false;

      for (int i = 0; i < 365; i++) {
        final key = _dateKey(today.subtract(Duration(days: i)));
        if (activeDates.contains(key)) {
          running++;
          if (!currentCounted) current = running;
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

  // ── Feedback ───────────────────────────────────────────────────────────────
  //   feedback/{auto-id}  ← top-level collection (not per-user)
  //   Also mirrors under users/{uid}/feedback/{auto-id} when logged in.

  static Future<void> submitFeedback({
    required String name,
    required String email,
    required String type,
    required int rating,
    required String message,
  }) async {
    try {
      final payload = {
        'name': name.trim(),
        'email': email.trim(),
        'type': type,
        'rating': rating,
        'message': message.trim(),
        'uid': _uid,            // null when not logged in — that's fine
        'submittedAt': FieldValue.serverTimestamp(),
      };

      // Always write to the top-level feedback collection so you can view
      // all feedback in one place in the Firebase console.
      await _db.collection('feedback').add(payload);

      // Also mirror under the user doc when logged in.
      if (_isLoggedIn) {
        await _db
            .collection('users')
            .doc(_uid)
            .collection('feedback')
            .add(payload);
      }
    } catch (e) {
      developer.log('[Firestore] submitFeedback: $e');
      rethrow; // let the UI show an error instead of silently swallowing it
    }
  }

  // ── Workout logging ───────────────────────────────────────────────────────
  //   users/{uid}/workouts/{auto-id}  ← per workout session log

  static Future<void> logWorkout({
    required String exerciseId,
    required String exerciseName,
    required String category,
    required int setsCompleted,
    required int repsCompleted,
    required int caloriesBurned,
  }) async {
    try {
      final payload = {
        'exerciseId':    exerciseId,
        'exerciseName':  exerciseName,
        'category':      category,
        'setsCompleted': setsCompleted,
        'repsCompleted': repsCompleted,
        'caloriesBurned': caloriesBurned,
        'date': _dateKey(DateTime.now()),
        'loggedAt': FieldValue.serverTimestamp(),
        'uid': _uid,
      };

      // Save under user's workouts subcollection
      if (_isLoggedIn) {
        await _db
            .collection('users')
            .doc(_uid)
            .collection('workouts')
            .add(payload);

        // Also update total calories burned in stats
        await _db.collection('users').doc(_uid)
            .collection('stats').doc('summary')
            .set({
          'totalCaloriesBurned': FieldValue.increment(caloriesBurned),
          'totalWorkouts': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Update leaderboard score
        await updateLeaderboardScore();
      }
    } catch (e) {
      developer.log('[Firestore] logWorkout: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getWorkoutHistory() async {
    if (!_isLoggedIn) return [];
    try {
      final snap = await _db.collection('users').doc(_uid)
          .collection('workouts')
          .orderBy('loggedAt', descending: true)
          .limit(50)
          .get();
      return snap.docs.map((d) {
        final data = d.data();
        return {
          'exerciseId':    data['exerciseId'] ?? '',
          'exerciseName':  data['exerciseName'] ?? '',
          'category':      data['category'] ?? '',
          'setsCompleted': data['setsCompleted'] ?? 0,
          'repsCompleted': data['repsCompleted'] ?? 0,
          'caloriesBurned': data['caloriesBurned'] ?? 0,
          'date':          data['date'] ?? '',
          'loggedAt':      (data['loggedAt'] as Timestamp?)
              ?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
        };
      }).toList();
    } catch (_) { return []; }
  }

  // ── Leaderboard ───────────────────────────────────────────────────────────
  //   leaderboard/{uid}  ← public score doc for every user

  static Future<void> updateLeaderboardScore() async {
    if (!_isLoggedIn) return;
    try {
      // Pull summary stats
      final summary = await _db.collection('users').doc(_uid)
          .collection('stats').doc('summary').get();
      final data = summary.data() ?? {};
      final totalMins     = (data['totalMinutes']        as int?) ?? 0;
      final totalWorkouts = (data['totalWorkouts']        as int?) ?? 0;
      final totalCal      = (data['totalCaloriesBurned']  as int?) ?? 0;
      final totalFoodPts  = (data['totalFoodPoints']      as int?) ?? 0;

      final streak = await _calculateStreak();
      final streakDays = streak['current'] ?? 0;

      // Score: meditation×2 + calories÷10 + streak×50 + foodPoints
      final score = (totalMins * 2) + (totalCal ~/ 10) + (streakDays * 50) + totalFoodPts;

      // Pull profile for display
      final profile = await _db.collection('users').doc(_uid).get();
      final pData = profile.data() ?? {};
      final name    = (pData['name'] as String?)?.trim() ?? 'User';
      final avatarId = pData['avatarId'] as String?;

      await _db.collection('leaderboard').doc(_uid).set({
        'uid':           _uid,
        'name':          name,
        'avatarId':      avatarId,
        'score':         score,
        'totalMinutes':  totalMins,
        'totalWorkouts': totalWorkouts,
        'totalCaloriesBurned': totalCal,
        'streakDays':    streakDays,
        'updatedAt':     FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('[Firestore] updateLeaderboardScore: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    if (!_isLoggedIn) return [];
    try {
      final snap = await _db.collection('leaderboard')
          .orderBy('score', descending: true)
          .limit(50)
          .get();
      return snap.docs.map((d) => {...d.data(), 'uid': d.id}).toList();
    } catch (_) { return []; }
  }

  // ── Full progress data ────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getFullProgressData() async {
    if (!_isLoggedIn) return {};
    try {
      final today = DateTime.now();
      final todayKey = _dateKey(today);

      // Summary stats
      final summary = await _db.collection('users').doc(_uid)
          .collection('stats').doc('summary').get();
      final s = summary.data() ?? {};

      // Today's meditation
      final medToday = await getMeditationMinutes(today);

      // This week meditation
      int medWeek = 0;
      final List<int> weeklyMed = [];
      for (int i = 6; i >= 0; i--) {
        final m = await getMeditationMinutes(today.subtract(Duration(days: i)));
        weeklyMed.add(m);
        medWeek += m;
      }

      // Streak
      final streak = await _calculateStreak();

      // Today's workouts
      final workoutsSnap = await _db.collection('users').doc(_uid)
          .collection('workouts')
          .where('date', isEqualTo: todayKey)
          .get();
      final workoutsToday = workoutsSnap.docs.length;
      final calToday = workoutsSnap.docs.fold<int>(
          0, (s, d) => s + ((d.data()['caloriesBurned'] as int?) ?? 0));

      // This week workouts
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final workoutsWeekSnap = await _db.collection('users').doc(_uid)
          .collection('workouts')
          .orderBy('loggedAt', descending: false)
          .get();
      int workoutsWeek = 0;
      int calWeek = 0;
      final List<int> weeklyWorkoutCal = List.filled(7, 0);
      for (final doc in workoutsWeekSnap.docs) {
        final dateStr = doc.data()['date'] as String? ?? '';
        final docDate = DateTime.tryParse(dateStr);
        if (docDate != null) {
          final diff = today.difference(docDate).inDays;
          if (diff < 7) {
            workoutsWeek++;
            final cal = (doc.data()['caloriesBurned'] as int?) ?? 0;
            calWeek += cal;
            final dayIndex = 6 - diff;
            if (dayIndex >= 0 && dayIndex < 7) weeklyWorkoutCal[dayIndex] += cal;
          }
        }
      }

      return {
        // Meditation
        'medToday':        medToday,
        'medWeek':         medWeek,
        'medTotal':        (s['totalMinutes'] as int?) ?? 0,
        'medSessions':     (s['totalSessions'] as int?) ?? 0,
        'streakCurrent':   streak['current'] ?? 0,
        'streakLongest':   streak['longest'] ?? 0,
        'weeklyMed':       weeklyMed,
        // Workout
        'workoutsToday':   workoutsToday,
        'calToday':        calToday,
        'workoutsWeek':    workoutsWeek,
        'calWeek':         calWeek,
        'workoutsTotal':   (s['totalWorkouts'] as int?) ?? 0,
        'calTotal':        (s['totalCaloriesBurned'] as int?) ?? 0,
        'weeklyWorkoutCal': weeklyWorkoutCal,
      };
    } catch (e) {
      developer.log('[Firestore] getFullProgressData: $e');
      return {};
    }
  }

  // ── Food daily save ───────────────────────────────────────────────────────
  //   users/{uid}/food_daily/{YYYY-MM-DD}

  static Future<void> saveDailyFood({
    required int totalCalories,
    required int goal,
  }) async {
    if (!_isLoggedIn) return;
    try {
      final today = _dateKey(DateTime.now());
      String status;
      int foodPoints;
      if (totalCalories == 0) {
        status = 'no_log';
        foodPoints = 0;
      } else if ((totalCalories - goal).abs() <= 100) {
        status = 'goal_met';
        foodPoints = 30;
      } else if (totalCalories < goal) {
        status = 'under_goal';
        foodPoints = 5;
      } else {
        status = 'over_goal';
        foodPoints = 10;
      }

      await _db.collection('users').doc(_uid)
          .collection('food_daily').doc(today)
          .set({
        'date': today,
        'totalCalories': totalCalories,
        'goal': goal,
        'status': status,
        'foodPoints': foodPoints,
        'savedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update cumulative food points in stats
      await _db.collection('users').doc(_uid)
          .collection('stats').doc('summary')
          .set({
        'totalFoodPoints': FieldValue.increment(foodPoints),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Refresh leaderboard
      await updateLeaderboardScore();
    } catch (e) {
      developer.log('[Firestore] saveDailyFood: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getFoodHistory() async {
    if (!_isLoggedIn) return [];
    try {
      final snap = await _db.collection('users').doc(_uid)
          .collection('food_daily')
          .orderBy('date', descending: true)
          .limit(30)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (_) { return []; }
  }

  static Future<int> getUnreadNotificationCount() async {
    if (!_isLoggedIn) return 0;
    try {
      final snap = await _db.collection('users').doc(_uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();
      return snap.docs.length;
    } catch (_) { return 0; }
  }

  static Future<int> getBurnedCaloriesToday() async {
    if (!_isLoggedIn) return 0;
    try {
      final now      = DateTime.now();
      final todayKey = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
      final snap = await _db.collection('users').doc(_uid)
          .collection('workouts')
          .where('date', isEqualTo: todayKey)
          .get();
      return snap.docs.fold<int>(
          0, (sum, d) => sum + ((d.data()['caloriesBurned'] as int?) ?? 0));
    } catch (_) { return 0; }
  }

  static Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    if (!_isLoggedIn) return [];
    try {
      final snap = await _db.collection('users').doc(_uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snap.docs.map((d) => {
        ...d.data(),
        'id': d.id,
        'createdAt': (d.data()['createdAt'] as Timestamp?)
            ?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
      }).toList();
    } catch (_) { return []; }
  }

  static Future<void> markSingleNotificationRead(String notifId) async {
    if (!_isLoggedIn) return;
    try {
      await _db.collection('users').doc(_uid)
          .collection('notifications').doc(notifId)
          .update({'read': true});
    } catch (e) {
      developer.log('[Firestore] markSingleNotificationRead: $e');
    }
  }

  static Future<void> deleteNotification(String notifId) async {
    if (!_isLoggedIn) return;
    try {
      await _db.collection('users').doc(_uid)
          .collection('notifications').doc(notifId)
          .delete();
    } catch (e) {
      developer.log('[Firestore] deleteNotification: $e');
    }
  }

  static Future<void> markNotificationsRead() async {
    if (!_isLoggedIn) return;
    try {
      final snap = await _db.collection('users').doc(_uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      developer.log('[Firestore] markNotificationsRead: $e');
    }
  }

  // ── Community notifications ───────────────────────────────────────────────
  //   users/{uid}/community_notifications/{auto-id}

  static Future<void> sendCommunityNotification({
    required String senderName,
    required String senderUid,
    required String messageText,
  }) async {
    if (!_isLoggedIn) return;
    try {
      // Get all users except sender
      final usersSnap = await _db.collection('users').get();
      final batch = _db.batch();
      for (final doc in usersSnap.docs) {
        if (doc.id == senderUid) continue;
        final notifRef = _db.collection('users').doc(doc.id)
            .collection('community_notifications').doc();
        batch.set(notifRef, {
          'senderName': senderName,
          'senderUid': senderUid,
          'message': messageText.length > 50
              ? '${messageText.substring(0, 50)}...'
              : messageText,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      developer.log('[Firestore] sendCommunityNotification: $e');
    }
  }

  static Future<int> getUnreadCommunityCount() async {
    if (!_isLoggedIn) return 0;
    try {
      final snap = await _db.collection('users').doc(_uid)
          .collection('community_notifications')
          .where('read', isEqualTo: false)
          .get();
      return snap.docs.length;
    } catch (_) { return 0; }
  }

  static Future<void> markCommunityNotificationsRead() async {
    if (!_isLoggedIn) return;
    try {
      final snap = await _db.collection('users').doc(_uid)
          .collection('community_notifications')
          .where('read', isEqualTo: false)
          .get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      developer.log('[Firestore] markCommunityNotificationsRead: $e');
    }
  }

  // ── Workout Plans ─────────────────────────────────────────────────────────
  //   users/{uid}/plans/{planId}

  static Future<void> savePlan(Map<String, dynamic> planJson) async {
    if (!_isLoggedIn) return;
    try {
      await _db.collection('users').doc(_uid)
          .collection('plans').doc(planJson['id'] as String)
          .set(planJson);
    } catch (e) {
      developer.log('[Firestore] savePlan: $e');
      rethrow;
    }
  }

  static Future<void> deletePlan(String planId) async {
    if (!_isLoggedIn) return;
    try {
      await _db.collection('users').doc(_uid)
          .collection('plans').doc(planId).delete();
    } catch (e) {
      developer.log('[Firestore] deletePlan: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getPlans() async {
    if (!_isLoggedIn) return [];
    try {
      final snap = await _db.collection('users').doc(_uid)
          .collection('plans')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (_) { return []; }
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