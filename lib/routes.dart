import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/screens/welcome_screen.dart';
import 'package:fitmetrics_app/screens/personalize_screen.dart';
import 'package:fitmetrics_app/screens/name_screen.dart';
import 'package:fitmetrics_app/screens/goals_screen.dart';
import 'package:fitmetrics_app/screens/personal_info_screen.dart';
import 'package:fitmetrics_app/screens/body_measurements_screen.dart';
import 'package:fitmetrics_app/screens/create_account_screen.dart';
import 'package:fitmetrics_app/screens/success_screen.dart';
import 'package:fitmetrics_app/screens/dashboard_screen.dart'; // ← ADD THIS IMPORT

class AppRoutes {
  static const String welcome = '/welcome';
  static const String personalize = '/personalize';
  static const String name = '/name';
  static const String goals = '/goals';
  static const String personalInfo = '/personal-info';
  static const String measurements = '/measurements';
  static const String createAccount = '/create-account';
  static const String success = '/success';
  static const String dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case personalize:
        return MaterialPageRoute(builder: (_) => const PersonalizeScreen());

      case name:
        final data = args is OnboardingData ? args : OnboardingData();
        return MaterialPageRoute(builder: (_) => NameScreen(data: data));

      case goals:
        final data = args is OnboardingData ? args : OnboardingData();
        return MaterialPageRoute(builder: (_) => GoalsScreen(data: data));

      case personalInfo:
        final data = args is OnboardingData ? args : OnboardingData();
        return MaterialPageRoute(builder: (_) => PersonalInfoScreen(data: data));

      case measurements:
        final data = args is OnboardingData ? args : OnboardingData();
        return MaterialPageRoute(builder: (_) => BodyMeasurementsScreen(data: data));

      case createAccount:
        final data = args is OnboardingData ? args : OnboardingData();
        return MaterialPageRoute(builder: (_) => CreateAccountScreen(data: data));

      case success:
        final data = args is OnboardingData ? args : OnboardingData();
        return MaterialPageRoute(builder: (_) => SuccessScreen(data: data));

    // ADD THIS CASE
      case dashboard:
        final data = args is OnboardingData ? args : OnboardingData();
        return MaterialPageRoute(builder: (_) => DashboardScreen(data: data));

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            'Route not found!',
            style: TextStyle(
              fontSize: 24,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}