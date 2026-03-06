import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/screens/home_screen.dart';
import 'package:fitmetrics/screens/profile_screen.dart';
import 'package:fitmetrics/screens/meditation/meditation_screen.dart';
import 'package:fitmetrics/core/audio_service.dart';

class MainTabScreen extends StatefulWidget {
  final OnboardingData userData;
  const MainTabScreen({super.key, required this.userData});

  @override
  State<MainTabScreen> createState() => MainTabScreenState();
}

class MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  void setTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),                              // 0 - Home
      const _ComingSoonScreen(label: 'Workout'),       // 1 - Workout
      MeditationScreen(userData: widget.userData),     // 2 - Meditation
      const _ComingSoonScreen(label: 'Food'),          // 3 - Food
      ProfileScreen(userData: widget.userData),        // 4 - Profile
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2540),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
                icon: Icon(Icons.open_with_outlined),
                activeIcon: Icon(Icons.open_with),
                label: 'Workout',
              ),
              BottomNavigationBarItem(
                icon: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/meditation/meditation_icon.jpg',
                    width: 24, height: 24, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.self_improvement),
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF3B82F6), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'assets/images/meditation/meditation_icon.jpg',
                      width: 22, height: 22, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.self_improvement),
                    ),
                  ),
                ),
                label: 'Meditation',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_outlined),
                activeIcon: Icon(Icons.restaurant),
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

// ── Placeholder screen for Workout and Food ───────────────────────────────────
class _ComingSoonScreen extends StatelessWidget {
  final String label;
  const _ComingSoonScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label == 'Workout' ? Icons.fitness_center_outlined : Icons.restaurant_outlined,
              color: Colors.white24,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming soon',
              style: TextStyle(color: Colors.white38, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}