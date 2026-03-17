import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/screens/home/home_screen.dart';
import 'package:fitmetrics/screens/profile/profile_screen.dart';
import 'package:fitmetrics/screens/meditation/meditation_screen.dart';
import 'package:fitmetrics/screens/food/food_screen.dart';
import 'package:fitmetrics/screens/workout/workout_screen.dart';
import 'package:fitmetrics/screens/walkthrough/walkthrough_overlay.dart';
import 'package:fitmetrics/core/audio_service.dart';
import 'package:fitmetrics/services/local_storage.dart';

class MainTabScreen extends StatefulWidget {
  final OnboardingData userData;
  const MainTabScreen({super.key, required this.userData});

  @override
  State<MainTabScreen> createState() => MainTabScreenState();
}

class MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  bool _showWalkthrough = false;
  int _highlightedTab = 0;

  @override
  void initState() {
    super.initState();
    _checkWalkthrough();
  }

  Future<void> _checkWalkthrough() async {
    final seen = await LocalStorage.hasSeenWalkthrough();
    if (!seen && mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _showWalkthrough = true);
        });
      }
    }
  }

  void setTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const WorkoutScreen(),                          // ← Workout where Community was
      MeditationScreen(userData: widget.userData),
      const FoodScreen(),
      ProfileScreen(userData: widget.userData),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: screens),
          if (_showWalkthrough)
            WalkthroughOverlay(
              onDone: () => setState(() => _showWalkthrough = false),
              onTabHighlight: (tabIndex) => setState(() {
                _highlightedTab = tabIndex;
                _currentIndex   = tabIndex;
              }),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2540),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(75),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) {
              if (_showWalkthrough) return;
              AudioService().playClickSound();
              setState(() => _currentIndex = i);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF3B82F6),
            unselectedItemColor: Colors.white38,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_outlined),
                activeIcon: Icon(Icons.fitness_center),
                label: 'Workout',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                    'assets/images/meditation/meditation_icon.jpg',
                    width: 24, height: 24, color: Colors.white54),
                activeIcon: Image.asset(
                    'assets/images/meditation/meditation_icon.jpg',
                    width: 24, height: 24,
                    color: const Color(0xFF3B82F6)),
                label: 'Meditation',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/food/food_icon.png',
                  width: 24, height: 24,
                  color: Colors.white38,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.restaurant_outlined,
                      color: Colors.white38, size: 24),
                ),
                activeIcon: Image.asset(
                  'assets/images/food/food_icon.png',
                  width: 24, height: 24,
                  color: const Color(0xFF3B82F6),
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.restaurant,
                      color: Color(0xFF3B82F6), size: 24),
                ),
                label: 'Food',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}