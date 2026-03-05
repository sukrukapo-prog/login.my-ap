import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitmetrics/models/onboarding_data.dart';

class LocalStorage {
  static const String _keyRegistered = 'isRegistered';
  static const String _keyUserData = 'userData';

  // Save after registration
  static Future<void> saveUserData(OnboardingData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRegistered, true);
    await prefs.setString(_keyUserData, jsonEncode(data.toJson()));
  }

  // Check if registered
  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRegistered) ?? false;
  }

  // Get saved data
  static Future<OnboardingData?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUserData);
    if (jsonString != null) {
      return OnboardingData.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  // Logout / reset
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRegistered);
    await prefs.remove(_keyUserData);
  }
}