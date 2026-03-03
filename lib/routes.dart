import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';

// Onboarding screens
import 'package:fitmetrics_app/screens/welcome_screen.dart';
import 'package:fitmetrics_app/screens/personalize_screen.dart';
import 'package:fitmetrics_app/screens/name_screen.dart';
import 'package:fitmetrics_app/screens/goals_screen.dart';
import 'package:fitmetrics_app/screens/personal_info_screen.dart';
import 'package:fitmetrics_app/screens/body_measurements_screen.dart';
import 'package:fitmetrics_app/screens/create_account_screen.dart';
import 'package:fitmetrics_app/screens/success_screen.dart';

// Tab system screens
import 'package:fitmetrics_app/screens/main_tab_screen.dart';     // ← NEW
// import 'package:fitmetrics_app/screens/dashboard_screen.dart'; // ← comment out or remove if replacing

class AppRoutes {
  // Onboarding routes
  static const String welcome          = '/welcome';
  static const String personalize      = '/personalize';
  static const String name             = '/name';
  static const String goals            = '/goals';
  static const String personalInfo     = '/personal-info';
  static const String measurements     = '/measurements';
  static const String createAccount    = '/create-account';
  static const String success          = '/success';

  // Main app route (with bottom navigation bar)
  static const String main             = '/main';               // ← NEW: entry point after onboarding

  // Optional: keep if you still want a separate dashboard later
  // static const String dashboard     = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case personalize:
        return MaterialPageRoute(
          builder: (_) => PersonalizeScreen(
            data: args is OnboardingData ? args : OnboardingData(),
          ),
        );

      case name:
        return MaterialPageRoute(
          builder: (_) => NameScreen(
            data: args is OnboardingData ? args : OnboardingData(),
          ),
        );

      case goals:
        return MaterialPageRoute(
          builder: (_) => GoalsScreen(
            data: args is OnboardingData ? args : OnboardingData(),
          ),
        );

      case personalInfo:
        return MaterialPageRoute(
          builder: (_) => PersonalInfoScreen(
            data: args is OnboardingData ? args : OnboardingData(),
          ),
        );

      case measurements:
        return MaterialPageRoute(
          builder: (_) => BodyMeasurementsScreen(
            data: args is OnboardingData ? args : OnboardingData(),
          ),
        );

      case createAccount:
        return MaterialPageRoute(
          builder: (_) => CreateAccountScreen(
            data: args is OnboardingData ? args : OnboardingData(),
          ),
        );

      case success:
        return MaterialPageRoute(
          builder: (_) => SuccessScreen(
            data: args is OnboardingData ? args : OnboardingData(),
          ),
        );

    // ── NEW ── Main tab screen (replaces old dashboard)
      case main:
        return MaterialPageRoute(
          builder: (_) => MainTabScreen(
            userData: args is OnboardingData ? args : OnboardingData(),
          ),
        );

    // Optional: keep this if you want to test old dashboard separately
    // case dashboard:
    //   return MaterialPageRoute(
    //     builder: (_) => DashboardScreen(
    //       data: args is OnboardingData ? args : OnboardingData(),
    //     ),
    //   );

      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: const Color(0xFF0F1624),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
              const SizedBox(height: 16),
              Text(
                'Route not found:\n$routeName',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}