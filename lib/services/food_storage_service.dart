// lib/services/food_storage_service.dart
// Key prefix: "food_"  — zero conflict with existing keys.
// v3 additions:
//   food_last_date     (String)     — last date food was active (auto-reset)
//   food_calorie_goal  (int)        — user's daily calorie goal
//   food_favs          (StringList) — "categoryId::itemName"
//   food_water_ml      (int)        — water drunk today in ml

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitmetrics/models/food_item.dart';

class FoodStorageService {
  static String _calorieKey(String id) => 'food_calories_$id';
  static String _logKey(String id)     => 'food_log_$id';
  static const _goalKey     = 'food_calorie_goal';
  static const _favsKey     = 'food_favs';
  static const _waterKey    = 'food_water_ml';
  static const _lastDateKey = 'food_last_date';

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  // ── Auto midnight reset ──────────────────────────────────────────────────────
  // Call this on every food screen load. If stored date != today → silent reset.

  static Future<void> checkAndResetIfNewDay() async {
    try {
      final p = await SharedPreferences.getInstance();
      final stored = p.getString(_lastDateKey);
      final today  = _todayKey();
      if (stored != null && stored != today) {
        developer.log('[FoodStorage] New day detected — resetting food data silently.');
        await resetAll();
      }
      await p.setString(_lastDateKey, today);
    } catch (e) {
      developer.log('[FoodStorage] checkAndResetIfNewDay: $e');
    }
  }

  // ── Calorie goal ─────────────────────────────────────────────────────────────

  static Future<int> getCalorieGoal() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_goalKey) ?? 2000;
  }

  static Future<void> setCalorieGoal(int kcal) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_goalKey, kcal.clamp(500, 9999));
  }

  // ── Calories ─────────────────────────────────────────────────────────────────

  static Future<int> getCalories(String mealId) async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getInt(_calorieKey(mealId)) ?? 0;
    } catch (e) { developer.log('[FoodStorage] getCalories: $e'); return 0; }
  }

  static Future<void> addCalories(String mealId, int amount) async {
    try {
      final p = await SharedPreferences.getInstance();
      final cur = p.getInt(_calorieKey(mealId)) ?? 0;
      await p.setInt(_calorieKey(mealId), cur + amount);
    } catch (e) { developer.log('[FoodStorage] addCalories: $e'); }
  }

  static Future<Map<String, int>> getAllCalories() async {
    try {
      final p = await SharedPreferences.getInstance();
      return { for (final c in allMealCategories) c.id: p.getInt(_calorieKey(c.id)) ?? 0 };
    } catch (e) {
      developer.log('[FoodStorage] getAllCalories: $e');
      return { for (final c in allMealCategories) c.id: 0 };
    }
  }

  static Future<void> resetAllCalories() async {
    try {
      final p = await SharedPreferences.getInstance();
      for (final c in allMealCategories) await p.remove(_calorieKey(c.id));
    } catch (e) { developer.log('[FoodStorage] resetAllCalories: $e'); }
  }

  // ── Log ───────────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getLog(String mealId) async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_logKey(mealId));
      if (raw == null) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(raw));
    } catch (e) { developer.log('[FoodStorage] getLog: $e'); return []; }
  }

  static Future<void> appendLog(String mealId, String name, int qty, int cal) async {
    try {
      final p = await SharedPreferences.getInstance();
      final log = await getLog(mealId);
      log.add({ 'name': name, 'qty': qty, 'cal': cal, 'time': DateTime.now().toIso8601String() });
      await p.setString(_logKey(mealId), jsonEncode(log));
    } catch (e) { developer.log('[FoodStorage] appendLog: $e'); }
  }

  static Future<void> clearMealLog(String mealId) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_logKey(mealId));
      await p.remove(_calorieKey(mealId));
    } catch (e) { developer.log('[FoodStorage] clearMealLog: $e'); }
  }

  static Future<void> resetAll() async {
    try {
      await resetAllCalories();
      final p = await SharedPreferences.getInstance();
      for (final c in allMealCategories) await p.remove(_logKey(c.id));
      await p.remove(_waterKey);
      // Note: we keep _goalKey and _favsKey across resets — they are preferences, not daily data
    } catch (e) { developer.log('[FoodStorage] resetAll: $e'); }
  }

  // ── Daily activity marker (for streak) ────────────────────────────────────────
  static Future<bool> hasLoggedFoodToday() async {
    try {
      final p = await SharedPreferences.getInstance();
      for (final c in allMealCategories) {
        if ((p.getInt(_calorieKey(c.id)) ?? 0) > 0) return true;
      }
      if ((p.getInt(_waterKey) ?? 0) > 0) return true;
      return false;
    } catch (_) { return false; }
  }

  // ── Get today's total calories ────────────────────────────────────────────────
  static Future<int> getTotalCaloriesToday() async {
    final all = await getAllCalories();
    return all.values.fold<int>(0, (a, b) => a + b);
  }

  // ── Favourites ────────────────────────────────────────────────────────────────
  // Stored as List<String> where each element = "categoryId::itemName"

  static Future<Set<String>> getFavourites() async {
    try {
      final p = await SharedPreferences.getInstance();
      return (p.getStringList(_favsKey) ?? []).toSet();
    } catch (e) { developer.log('[FoodStorage] getFavourites: $e'); return {}; }
  }

  static String _favKey(String catId, String name) => '$catId::$name';

  static Future<bool> isFavourite(String catId, String name) async {
    final favs = await getFavourites();
    return favs.contains(_favKey(catId, name));
  }

  static Future<void> toggleFavourite(String catId, String name) async {
    try {
      final p = await SharedPreferences.getInstance();
      final favs = (p.getStringList(_favsKey) ?? []).toSet();
      final key  = _favKey(catId, name);
      if (favs.contains(key)) { favs.remove(key); } else { favs.add(key); }
      await p.setStringList(_favsKey, favs.toList());
    } catch (e) { developer.log('[FoodStorage] toggleFavourite: $e'); }
  }

  // ── Water ─────────────────────────────────────────────────────────────────────

  static Future<int> getWaterMl() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getInt(_waterKey) ?? 0;
    } catch (e) { return 0; }
  }

  static Future<void> addWaterMl(int ml) async {
    try {
      final p = await SharedPreferences.getInstance();
      final cur = p.getInt(_waterKey) ?? 0;
      await p.setInt(_waterKey, cur + ml);
    } catch (e) { developer.log('[FoodStorage] addWaterMl: $e'); }
  }

  static Future<void> resetWater() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_waterKey);
    } catch (e) { developer.log('[FoodStorage] resetWater: $e'); }
  }
}