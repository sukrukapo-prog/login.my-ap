import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'dart:developer' as developer; // Use developer.log for better debugging

class StorageService {
  static const String _onboardingKey = 'onboarding_data';

  // Save all onboarding data
  static Future<void> saveOnboardingData(OnboardingData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data.toJson());
      await prefs.setString(_onboardingKey, jsonString);
      developer.log('Onboarding data saved successfully');
    } catch (e, stackTrace) {
      developer.log('Error saving onboarding data', error: e, stackTrace: stackTrace);
    }
  }

  // Load saved onboarding data
  static Future<OnboardingData?> loadOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_onboardingKey);

      if (jsonString == null) {
        developer.log('No onboarding data found in storage');
        return null;
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return OnboardingData.fromJson(jsonMap);
    } catch (e, stackTrace) {
      developer.log('Error loading onboarding data', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Clear all onboarding data
  static Future<void> clearOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
      developer.log('Onboarding data cleared');
    } catch (e) {
      developer.log('Error clearing onboarding data: $e');
    }
  }
}