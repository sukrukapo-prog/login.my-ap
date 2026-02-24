import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/screens/personal_info_screen.dart';
import 'package:fitmetrics_app/widgets/progress_dots.dart';
import 'package:fitmetrics_app/routes.dart'; // ← important

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

              IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 8),

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

              const SizedBox(height: 32),

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
                );
              }),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.data.goals.isEmpty
                      ? null
                      : () {
                    // Optional feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Goals saved!'),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    // Go to next screen (named route)
                    Navigator.pushNamed(
                      context,
                      AppRoutes.personalInfo,
                      arguments: widget.data,
                    );
                  },
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