// lib/services/food_storage_service.dart
//
// Handles all food-related SharedPreferences reads/writes.
// Key prefix: "food_"  — zero conflict with existing LocalStorage keys
// (which use: userData, avatarId, meditation_*, seenOnboarding, etc.)

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitmetrics/models/food_item.dart';

class FoodStorageService {
  // ── Key helpers ─────────────────────────────────────────────────────────────

  static String _calorieKey(String mealId) => 'food_calories_$mealId';
  static String _logKey(String mealId)     => 'food_log_$mealId';

  // ── Calories ─────────────────────────────────────────────────────────────────

  /// Get saved calories for one meal category today.
  static Future<int> getCalories(String mealId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_calorieKey(mealId)) ?? 0;
    } catch (e) {
      developer.log('[FoodStorage] getCalories error: $e');
      return 0;
    }
  }

  /// Add calories to a meal category (accumulates).
  static Future<void> addCalories(String mealId, int amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_calorieKey(mealId)) ?? 0;
      await prefs.setInt(_calorieKey(mealId), current + amount);
    } catch (e) {
      developer.log('[FoodStorage] addCalories error: $e');
    }
  }

  /// Get calories for ALL meal categories at once (used by FoodScreen dashboard).
  static Future<Map<String, int>> getAllCalories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        for (final cat in allMealCategories)
          cat.id: prefs.getInt(_calorieKey(cat.id)) ?? 0,
      };
    } catch (e) {
      developer.log('[FoodStorage] getAllCalories error: $e');
      return {for (final cat in allMealCategories) cat.id: 0};
    }
  }

  /// Reset all food calories (called by "Reset Day" button).
  static Future<void> resetAllCalories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final cat in allMealCategories) {
        await prefs.remove(_calorieKey(cat.id));
      }
    } catch (e) {
      developer.log('[FoodStorage] resetAllCalories error: $e');
    }
  }

  // ── Log entries ───────────────────────────────────────────────────────────────

  /// Get the log (list of {name, qty, cal, time}) for one meal category.
  static Future<List<Map<String, dynamic>>> getLog(String mealId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_logKey(mealId));
      if (raw == null) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(raw));
    } catch (e) {
      developer.log('[FoodStorage] getLog error: $e');
      return [];
    }
  }

  /// Append a new log entry for a meal item.
  static Future<void> appendLog(
      String mealId,
      String itemName,
      int qty,
      int totalCal,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final log = await getLog(mealId);
      log.add({
        'name': itemName,
        'qty': qty,
        'cal': totalCal,
        'time': DateTime.now().toIso8601String(),
      });
      await prefs.setString(_logKey(mealId), jsonEncode(log));
    } catch (e) {
      developer.log('[FoodStorage] appendLog error: $e');
    }
  }

  /// Clear the log for one meal category (and its calorie total).
  static Future<void> clearMealLog(String mealId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logKey(mealId));
      await prefs.remove(_calorieKey(mealId));
    } catch (e) {
      developer.log('[FoodStorage] clearMealLog error: $e');
    }
  }

  /// Clear ALL food logs and calories (full reset).
  static Future<void> resetAll() async {
    try {
      await resetAllCalories();
      final prefs = await SharedPreferences.getInstance();
      for (final cat in allMealCategories) {
        await prefs.remove(_logKey(cat.id));
      }
    } catch (e) {
      developer.log('[FoodStorage] resetAll error: $e');
    }
  }
}