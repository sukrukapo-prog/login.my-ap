import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/core/avatar_data.dart';
import 'package:fitmetrics/core/audio_service.dart';
import 'package:fitmetrics/routes.dart';
import 'package:fitmetrics/screens/main_tab_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OnboardingData? _userData;
  double? _maintenanceCalories;
  String? _avatarId;
  int _meditationMinutesToday = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('userData');
    if (jsonString != null) {
      final data = OnboardingData.fromJson(jsonDecode(jsonString));
      _userData = data;
      _maintenanceCalories = _calculateMaintenance(data);
    }
    _avatarId = prefs.getString('avatarId');
    final today = DateTime.now();
    final todayKey = 'meditation_mins_${today.year}_${today.month}_${today.day}';
    _meditationMinutesToday = prefs.getInt(todayKey) ?? 0;
    setState(() => _isLoading = false);
  }

  double? _calculateMaintenance(OnboardingData data) {
    if (data.currentWeightKg == null || data.heightCm == null ||
        data.age == null || data.gender == null) return null;
    double bmr;
    if (data.gender == 'Male') {
      bmr = 10 * data.currentWeightKg! + 6.25 * data.heightCm! - 5 * data.age! + 5;
    } else {
      bmr = 10 * data.currentWeightKg! + 6.25 * data.heightCm! - 5 * data.age! - 161;
    }
    double multiplier = 1.375;
    for (final goal in data.goals) {
      if (goal.contains('sedentary')) multiplier = 1.2;
      if (goal.contains('lightly_active')) multiplier = 1.375;
      if (goal.contains('moderately_active')) multiplier = 1.55;
      if (goal.contains('very_active')) multiplier = 1.725;
    }
    return bmr * multiplier;
  }

  void _navigate(String dest) {
    AudioService().playClickSound();
    if (dest == 'meditation') {
      // Find main tab screen and switch to meditation tab
      final mainTabState = context.findAncestorStateOfType<MainTabScreenState>();
      mainTabState?.setTab(2);
    } else if (dest == 'progress') {
      Navigator.pushNamed(context, AppRoutes.progress);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dest[0].toUpperCase()}${dest.substring(1)} — coming soon!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1624),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }

    final calories = _maintenanceCalories;
    final name = _userData?.name ?? 'there';
    final meditationText = _meditationMinutesToday > 0
        ? '$_meditationMinutesToday min today'
        : 'Start today';

    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF3B82F6),
          backgroundColor: const Color(0xFF1A2540),
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hey, $name! 👋',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        const Text("Here's your daily summary",
                            style: TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                    AvatarWidget(avatarId: _avatarId, size: 46, showBorder: true),
                  ],
                ),
                const SizedBox(height: 28),

                // Calories card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A5F), Color(0xFF0F1624)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['GOAL', 'FOOD', 'EXERCISE', 'NET'].map((label) =>
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(label,
                                  style: TextStyle(
                                    color: label == 'NET' ? const Color(0xFF3B82F6) : Colors.white38,
                                    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5,
                                  )),
                            )).toList(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 160, height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 160, height: 160,
                              child: CircularProgressIndicator(
                                value: 1.0, strokeWidth: 12,
                                backgroundColor: Colors.white.withOpacity(0.08),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('your balance\ncalories',
                                    style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 6),
                                Text(calories != null ? calories.round().toString() : '—',
                                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                                const Text('kcal net',
                                    style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(label: 'GOAL', value: calories != null ? calories.round().toString() : '—', color: Colors.white70),
                          _StatItem(label: '- FOOD', value: '0', color: Colors.orangeAccent, icon: Icons.restaurant_outlined),
                          _StatItem(label: '+ BURNED', value: '0', color: const Color(0xFF10B981), icon: Icons.local_fire_department_outlined),
                          _StatItem(label: 'REMAINING', value: calories != null ? calories.round().toString() : '—', color: Colors.white70),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (calories == null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Complete your profile to see your maintenance calories.',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                const Text('Quick Access',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
                  children: [
                    _QuickCard(title: 'Diet', subtitle: 'Log meals & macros',
                        icon: Icons.restaurant_menu_outlined, color: const Color(0xFF10B981),
                        onTap: () => _navigate('diet')),
                    _QuickCard(title: 'Workout', subtitle: "Today's plan",
                        icon: Icons.fitness_center_outlined, color: const Color(0xFF3B82F6),
                        onTap: () => _navigate('workout')),
                    _MeditationCard(subtitle: meditationText, onTap: () => _navigate('meditation')),
                    _QuickCard(title: 'Progress', subtitle: 'View your stats',
                        icon: Icons.trending_up, color: const Color(0xFFF59E0B),
                        onTap: () => _navigate('progress')),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MeditationCard extends StatelessWidget {
  final String subtitle;
  final VoidCallback onTap;
  const _MeditationCard({required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF8B5CF6);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset('assets/images/meditation/meditation_icon.jpg',
                  width: 28, height: 28, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.self_improvement, color: color, size: 26)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Meditation', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;
  const _StatItem({required this.label, required this.value, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) Icon(icon, color: color, size: 14),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard({required this.title, required this.subtitle,
    required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 26),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}