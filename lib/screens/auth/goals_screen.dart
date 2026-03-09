import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/routes.dart';

class GoalsScreen extends StatefulWidget {
  final OnboardingData data;
  const GoalsScreen({super.key, required this.data});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String? _selectedGoal;

  static const int totalSteps = 6;
  static const int currentStep = 4;

  final List<Map<String, dynamic>> _goals = [
    {
      'value': 'explore',
      'title': 'Just Explore',
      'subtitle': 'Browse features & track my habits',
      'icon': Icons.explore_outlined,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'value': 'gain_weight',
      'title': 'Gain Weight',
      'subtitle': 'Build muscle & increase body mass',
      'icon': Icons.trending_up,
      'color': const Color(0xFFF59E0B),
    },
    {
      'value': 'lose_weight',
      'title': 'Lose Weight',
      'subtitle': 'Burn fat & reach my ideal weight',
      'icon': Icons.trending_down,
      'color': const Color(0xFF10B981),
    },
    {
      'value': 'calm_yourself',
      'title': 'Calm Yourself',
      'subtitle': 'Reduce stress & improve wellbeing',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF3B82F6),
    },
  ];

  void _next() {
    if (_selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your goal')),
      );
      return;
    }
    widget.data.goals.add(_selectedGoal!);
    Navigator.pushNamed(context, AppRoutes.createAccount, arguments: widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 20),
                    _ProgressBar(current: currentStep, total: totalSteps),
                    const SizedBox(height: 32),
                    const Text(
                      'Your Goal',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'What do you want to achieve with FitMetrics?',
                      style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    ..._goals.map((goal) {
                      final isSelected = _selectedGoal == goal['value'];
                      final color = goal['color'] as Color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedGoal = goal['value']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? color : Colors.white.withOpacity(0.1),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected ? color : Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  goal['icon'] as IconData,
                                  color: isSelected ? Colors.white : Colors.white54,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal['title'] as String,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white70,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      goal['subtitle'] as String,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white60 : Colors.white38,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Next', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: i < current ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.15),
            ),
          ),
        );
      }),
    );
  }
}