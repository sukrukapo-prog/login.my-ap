import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/routes.dart';

class SuccessScreen extends StatelessWidget {
  final OnboardingData data;

  const SuccessScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated celebration icon
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: const Icon(
                  Icons.celebration_rounded,
                  size: 140,
                  color: Color(0xFF3B82F6),
                ),
              ),

              const SizedBox(height: 48),

              // Personalized welcome
              Text(
                'Welcome aboard, ${data.name ?? "FitMetrics User"}!',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Motivational message
              const Text(
                "Your fitness journey begins today.\nWe're excited to help you become the strongest, healthiest version of yourself.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Main button – larger + icon
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.main,
                      arguments: data,
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 24),
                  label: const Text(
                    'Start Your Journey',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Reset button with confirmation
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E293B),
                      title: const Text("Reset Onboarding?", style: TextStyle(color: Colors.white)),
                      content: const Text(
                        "This will clear your progress and take you back to the beginning.",
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          child: const Text("Reset", style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Start Over',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const Spacer(),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  "FitMetrics • Your Personal Fitness Companion",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}