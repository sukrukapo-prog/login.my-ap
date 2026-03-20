import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/routes.dart';

class PersonalizeScreen extends StatefulWidget {
  final OnboardingData? data;
  const PersonalizeScreen({super.key, this.data});

  @override
  State<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  String? _selectedActivity;

  static const int totalSteps = 6;
  static const int currentStep = 3;

  final List<Map<String, dynamic>> _activities = [
    {
      'value': 'sedentary',
      'title': 'Sedentary',
      'subtitle': 'Little or no exercise, desk job',
      'icon': Icons.chair_outlined,
    },
    {
      'value': 'lightly_active',
      'title': 'Lightly Active',
      'subtitle': 'Light exercise 1-3 days/week',
      'icon': Icons.directions_walk,
    },
    {
      'value': 'moderately_active',
      'title': 'Moderately Active',
      'subtitle': 'Moderate exercise 3-5 days/week',
      'icon': Icons.fitness_center_outlined,
    },
    {
      'value': 'very_active',
      'title': 'Very Active',
      'subtitle': 'Hard exercise 6-7 days/week',
      'icon': Icons.bolt,
    },
  ];

  void _next() {
    if (_selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your activity level')),
      );
      return;
    }
    final data = widget.data ?? OnboardingData();
    // Remove any previously stored activity before adding new one.
    // Prevents duplicates if user goes Back and reselects.
    data.goals.removeWhere((g) => g.startsWith('activity:'));
    data.goals.add('activity:$_selectedActivity');
    Navigator.pushNamed(context, AppRoutes.goals, arguments: data);
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
                      'Activity Level',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select the option that best describes your daily lifestyle.',
                      style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    ..._activities.map((activity) {
                      final isSelected = _selectedActivity == activity['value'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedActivity = activity['value']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF3B82F6).withOpacity(0.15)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF3B82F6)
                                  : Colors.white.withOpacity(0.1),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF3B82F6)
                                      : Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  activity['icon'] as IconData,
                                  color: isSelected ? Colors.white : Colors.white54,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity['title'] as String,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white70,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      activity['subtitle'] as String,
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
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3B82F6),
                                    shape: BoxShape.circle,
                                  ),
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
                      Text('Continue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
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