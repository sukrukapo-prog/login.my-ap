import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';

class DashboardScreen extends StatelessWidget {
  final OnboardingData data;

  const DashboardScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitMetrics Dashboard'),
        backgroundColor: const Color(0xFF0F1624),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${data.name ?? "User"}!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your goals: ${data.goals.isEmpty ? "None set" : data.goals.join(", ")}',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Height: ${data.heightCm ?? "?"} cm • Weight: ${data.currentWeightKg ?? "?"} kg',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Goal weight: ${data.goalWeightKg ?? "?"} kg',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Start tracking / go to main app features
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tracking started!')),
                    );
                  },
                  child: const Text('Start Tracking Today'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}