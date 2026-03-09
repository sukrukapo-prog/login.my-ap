import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/screens/home/home_screen.dart';
import 'package:fitmetrics/screens/profile/profile_screen.dart';
import 'package:fitmetrics/screens/meditation/meditation_screen.dart';
import 'package:fitmetrics/screens/walkthrough/walkthrough_overlay.dart';
import 'package:fitmetrics/core/audio_service.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/core/smart_notification_service.dart';

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

  void setTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const _ComingSoonScreen(label: 'Workout'),
      MeditationScreen(userData: widget.userData),
      const _ComingSoonScreen(label: 'Food'),
      ProfileScreen(userData: widget.userData),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // Walkthrough overlay
          if (_showWalkthrough)
            WalkthroughOverlay(
              onDone: () => setState(() => _showWalkthrough = false),
              onTabHighlight: (tabIndex) {
                setState(() {
                  _highlightedTab = tabIndex;
                  _currentIndex = tabIndex;
                });
              },
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
              if (_showWalkthrough) return; // disable tap during walkthrough
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
              const BottomNavigationBarItem(
                icon: Icon(Icons.self_improvement_outlined),
                activeIcon: Icon(Icons.self_improvement),
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
              label == 'Workout'
                  ? Icons.fitness_center_outlined
                  : Icons.restaurant_outlined,
              color: Colors.white24,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Coming soon',
                style: TextStyle(color: Colors.white38, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
