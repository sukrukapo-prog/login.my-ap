import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';

// Onboarding screens
import 'package:fitmetrics/screens/welcome_screen.dart';
import 'package:fitmetrics/screens/personalize_screen.dart';
import 'package:fitmetrics/screens/name_screen.dart';
import 'package:fitmetrics/screens/goals_screen.dart';
import 'package:fitmetrics/screens/personal_info_screen.dart';
import 'package:fitmetrics/screens/body_measurements_screen.dart';
import 'package:fitmetrics/screens/create_account_screen.dart';
import 'package:fitmetrics/screens/success_screen.dart';

// Login screen
import 'package:fitmetrics/screens/login_screen.dart';

// Main tabs
import 'package:fitmetrics/screens/main_tab_screen.dart';

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

  // Login route
  static const String login            = '/login';

  // Main app tabs
  static const String main             = '/main';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case personalize:
      // Intro screen – no data parameter
        return MaterialPageRoute(builder: (_) => const PersonalizeScreen());

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

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case main:
        return MaterialPageRoute(
          builder: (_) => MainTabScreen(
            userData: args is OnboardingData ? args : OnboardingData(),
          ),
        );

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