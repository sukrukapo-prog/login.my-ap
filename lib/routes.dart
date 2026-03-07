import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/core/page_transitions.dart';

import 'package:fitmetrics/screens/welcome_screen.dart';
import 'package:fitmetrics/screens/name_screen.dart';
import 'package:fitmetrics/screens/personal_info_screen.dart';
import 'package:fitmetrics/screens/personalize_screen.dart';
import 'package:fitmetrics/screens/goals_screen.dart';
import 'package:fitmetrics/screens/create_account_screen.dart';
import 'package:fitmetrics/screens/success_screen.dart';
import 'package:fitmetrics/screens/login_screen.dart';
import 'package:fitmetrics/screens/main_tab_screen.dart';
import 'package:fitmetrics/screens/settings_screen.dart';
import 'package:fitmetrics/screens/progress_screen.dart';
import 'package:fitmetrics/screens/splash_screen.dart';
import 'package:fitmetrics/screens/onboarding_screen.dart';
import 'package:fitmetrics/screens/leaderboard_screen.dart';
import 'package:fitmetrics/screens/notification_history_screen.dart';

class AppRoutes {
  static const String splash              = '/';
  static const String onboarding          = '/onboarding';
  static const String welcome             = '/welcome';
  static const String name          = '/name';
  static const String personalInfo  = '/personal-info';
  static const String personalize   = '/personalize';
  static const String goals         = '/goals';
  static const String createAccount = '/create-account';
  static const String success       = '/success';
  static const String login         = '/login';
  static const String main          = '/main';
  static const String settings      = '/settings';
  static const String progress             = '/progress';
  static const String leaderboard         = '/leaderboard';
  static const String notificationHistory = '/notification-history';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final args = routeSettings.arguments;

    switch (routeSettings.name) {
      case welcome:
        return FadePageRoute(page: const WelcomeScreen());

      case name:
        return SlidePageRoute(
          page: NameScreen(data: args is OnboardingData ? args : OnboardingData()),
        );

      case personalInfo:
        return SlidePageRoute(
          page: PersonalInfoScreen(data: args is OnboardingData ? args : OnboardingData()),
        );

      case personalize:
        return SlidePageRoute(
          page: PersonalizeScreen(data: args is OnboardingData ? args : OnboardingData()),
        );

      case goals:
        return SlidePageRoute(
          page: GoalsScreen(data: args is OnboardingData ? args : OnboardingData()),
        );

      case createAccount:
        return SlidePageRoute(
          page: CreateAccountScreen(data: args is OnboardingData ? args : OnboardingData()),
        );

      case success:
        return SlidePageRoute(
          page: SuccessScreen(data: args is OnboardingData ? args : OnboardingData()),
        );

      case login:
        return SlidePageRoute(
          page: const LoginScreen(),
          direction: SlideDirection.bottomToTop,
        );

      case main:
        return FadePageRoute(
          page: MainTabScreen(
            userData: args is OnboardingData ? args : OnboardingData(),
          ),
        );

      case settings:
        return SlidePageRoute(
          page: const SettingsScreen(),
          direction: SlideDirection.bottomToTop,
        );

      case splash:
        return FadePageRoute(page: const SplashScreen());

      case onboarding:
        return FadePageRoute(page: const OnboardingScreen());

      case progress:
        return SlidePageRoute(page: const ProgressScreen());

      case leaderboard:
        return SlidePageRoute(page: const LeaderboardScreen());

      case notificationHistory:
        return SlidePageRoute(page: const NotificationHistoryScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: const Color(0xFF0F1624),
            body: Center(
              child: Text('Route not found: ${routeSettings.name}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center),
            ),
          ),
        );
    }
  }
}