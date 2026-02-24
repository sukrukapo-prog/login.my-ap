import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/screens/personal_info_screen.dart';
import 'package:fitmetrics_app/widgets/progress_dots.dart';
import 'package:fitmetrics_app/routes.dart'; // ← import your routes file

class GoalsScreen extends StatefulWidget {
  final OnboardingData data;

  const GoalsScreen({super.key, required this.data});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final List<String> _options = [
    'Gain weight',
    'Lose weight',
    'Gain muscle',
  ];

  bool get _hasGoals => widget.data.goals.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 8),

              // Progress
              const ProgressDots(current: 2),

              const SizedBox(height: 32),

              const Text(
                "Hey, let's start with your goals.",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Select up to three that are most important to you',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),

              const SizedBox(height: 24),

              // Goals list
              ..._options.map((goal) {
                return CheckboxListTile(
                  title: Text(goal),
                  value: widget.data.goals.contains(goal),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (widget.data.goals.length < 3) {
                          widget.data.goals.add(goal);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Maximum 3 goals allowed')),
                          );
                        }
                      } else {
                        widget.data.goals.remove(goal);
                      }
                    });
                  },
                  activeColor: const Color(0xFF3B82F6),
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: EdgeInsets.zero,
                );
              }),

              // Error message if no goals selected
              if (!_hasGoals)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    'Please select at least one goal',
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),

              const Spacer(),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _hasGoals
                      ? () {
                    // Optional: show brief confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Goals saved!'),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    // Go to next screen using named route
                    Navigator.pushNamed(
                      context,
                      AppRoutes.personalInfo,
                      arguments: widget.data,
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Next', style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}