import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/services/local_storage.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  OnboardingData? _userData;
  int _meditationToday = 0;
  int _meditationWeek = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _userData = await LocalStorage.getUserData();
    _meditationToday = await LocalStorage.getMeditationMinutes(DateTime.now());
    _meditationWeek = await LocalStorage.getMeditationMinutesForLastDays(7);
    setState(() => _isLoading = false);
  }

  double? _calcBMR() {
    final d = _userData;
    if (d == null || d.currentWeightKg == null ||
        d.heightCm == null || d.age == null || d.gender == null) return null;
    if (d.gender == 'Male') {
      return 10 * d.currentWeightKg! + 6.25 * d.heightCm! - 5 * d.age! + 5;
    }
    return 10 * d.currentWeightKg! + 6.25 * d.heightCm! - 5 * d.age! - 161;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1624),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }
    final bmr = _calcBMR();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('My Progress',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A5F), Color(0xFF0F1624)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Weekly Summary',
                              style: TextStyle(color: Colors.white54, fontSize: 12,
                                  fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                          SizedBox(height: 6),
                          Text('Keep it up! 🔥',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                          SizedBox(height: 4),
                          Text('Track your progress every day',
                              style: TextStyle(color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Your Stats',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        _StatCard(
                          title: 'Weight',
                          value: _userData?.currentWeightKg != null
                              ? '${_userData!.currentWeightKg!.toStringAsFixed(1)} kg'
                              : '—',
                          icon: Icons.monitor_weight_outlined,
                          color: const Color(0xFF3B82F6),
                        ),
                        _StatCard(
                          title: 'Height',
                          value: _userData?.heightCm != null
                              ? '${_userData!.heightCm!.round()} cm'
                              : '—',
                          icon: Icons.height,
                          color: const Color(0xFF10B981),
                        ),
                        _StatCard(
                          title: 'BMR',
                          value: bmr != null ? '${bmr.round()} kcal' : '—',
                          icon: Icons.local_fire_department_outlined,
                          color: const Color(0xFFF59E0B),
                        ),
                        _StatCard(
                          title: 'Meditation Today',
                          value: '$_meditationToday min',
                          icon: Icons.self_improvement,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Meditation this week
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF8B5CF6).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                'assets/images/meditation/meditation_icon.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.self_improvement,
                                    color: Color(0xFF8B5CF6), size: 26),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Meditation This Week',
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('$_meditationWeek minutes total',
                                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Coming soon
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bar_chart_outlined, color: Colors.white38, size: 24),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Detailed Charts',
                                  style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w600)),
                              Text('Coming soon',
                                  style: TextStyle(color: Colors.white30, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value,
    required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              Text(title,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}