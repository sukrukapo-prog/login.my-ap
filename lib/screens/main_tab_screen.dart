import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';

// Import your tab screens (adjust paths if you moved them)
import 'package:fitmetrics_app/screens/home_screen.dart';
import 'package:fitmetrics_app/screens/workout_screen.dart';
import 'package:fitmetrics_app/screens/meditation/meditation_screen.dart';
import 'package:fitmetrics_app/screens/food_screen.dart';
import 'package:fitmetrics_app/screens/profile_screen.dart';

class MainTabScreen extends StatefulWidget {
  final OnboardingData userData;

  const MainTabScreen({super.key, required this.userData});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 2; // Start on Meditation

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const WorkoutScreen(),
      MeditationScreen(userData: widget.userData),
      const FoodScreen(),
      ProfileScreen(userData: widget.userData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F1624),
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.self_improvement_outlined), activeIcon: Icon(Icons.self_improvement), label: 'Meditation'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_outlined), activeIcon: Icon(Icons.restaurant), label: 'Food'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}