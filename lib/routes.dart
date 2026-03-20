import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/core/page_transitions.dart';

import 'package:fitmetrics/screens/notifications/meditation_history_screen.dart' show MeditationHistoryScreen;
import 'package:fitmetrics/screens/notifications/notification_history_screen.dart' show NotificationHistoryScreen;
import 'package:fitmetrics/screens/community/community_screen.dart';
import 'package:fitmetrics/screens/workout/workout_history_screen.dart';
import 'package:fitmetrics/screens/workout/workout_plans_screen.dart';
import 'package:fitmetrics/screens/profile/bmi_screen.dart';
import 'package:fitmetrics/screens/auth/welcome_screen.dart';
import 'package:fitmetrics/screens/auth/name_screen.dart';
import 'package:fitmetrics/screens/auth/personal_info_screen.dart';
import 'package:fitmetrics/screens/auth/personalize_screen.dart';
import 'package:fitmetrics/screens/auth/goals_screen.dart';
import 'package:fitmetrics/screens/auth/create_account_screen.dart';
import 'package:fitmetrics/screens/auth/success_screen.dart';
import 'package:fitmetrics/screens/auth/login_screen.dart';
import 'package:fitmetrics/screens/main_tab_screen.dart';
import 'package:fitmetrics/screens/settings/settings_screen.dart';
import 'package:fitmetrics/screens/progress/progress_screen.dart';
import 'package:fitmetrics/screens/auth/splash_screen.dart';
import 'package:fitmetrics/screens/auth/onboarding_screen.dart';
import 'package:fitmetrics/screens/leaderboard/leaderboard_screen.dart';
import 'package:fitmetrics/screens/profile/achievements_screen.dart';

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
  static const String meditationHistory   = '/meditation-history';
  static const String achievements         = '/achievements';
  static const String community            = '/community';
  static const String workoutHistory       = '/workout-history';
  static const String workoutPlans         = '/workout-plans';
  static const String bmi                  = '/bmi';

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

      case meditationHistory:
        return SlidePageRoute(page: const MeditationHistoryScreen());

      case achievements:
        return SlidePageRoute(page: const AchievementsScreen());

      case community:
        return SlidePageRoute(page: const CommunityScreen());

      case workoutHistory:
        return SlidePageRoute(page: const WorkoutHistoryScreen());

      case workoutPlans:
        return SlidePageRoute(page: const WorkoutPlansScreen());

      case bmi:
        return SlidePageRoute(page: const BmiScreen());

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