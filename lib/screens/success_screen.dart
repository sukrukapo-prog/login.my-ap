import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';

class SuccessScreen extends StatelessWidget {
  final OnboardingData data;

  const SuccessScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 120,
                color: Color(0xFF3B82F6),
              ),
              const SizedBox(height: 40),

              Text(
                'Welcome, ${data.name ?? "FitMetrics User"}!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              const Text(
                "Your account is ready.\nWe're excited to help you reach your fitness goals!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to main app / dashboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Welcome to your dashboard! (to be implemented)'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    // Example: Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text('Go to Dashboard', style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  'Back to Welcome',
                  style: TextStyle(color: Color(0xFF60A5FA), fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}