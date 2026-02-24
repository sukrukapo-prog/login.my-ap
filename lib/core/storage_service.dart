import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';

class StorageService {
  static const String _onboardingKey = 'onboarding_data';

  // Save all onboarding data
  static Future<void> saveOnboardingData(OnboardingData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString(_onboardingKey, jsonString);
  }

  // Load saved onboarding data (returns null if none exists)
  static Future<OnboardingData?> loadOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_onboardingKey);
    if (jsonString == null) return null;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return OnboardingData.fromJson(jsonMap);
    } catch (e) {
      print('Error loading onboarding data: $e');
      return null;
    }
  }

  // Clear all onboarding data (e.g. after success or logout)
  static Future<void> clearOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
  }
}