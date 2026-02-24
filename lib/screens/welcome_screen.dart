import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart'; // ← ADD THIS LINE (critical!)
import 'package:fitmetrics_app/routes.dart'; // ← ADD THIS if you want named routes

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              const Text(
                'FitMetrics',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3B82F6),
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 48),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withAlpha(20),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/fittintroimage.jpg',
                    fit: BoxFit.cover,
                    height: 380,
                    width: double.infinity,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                '"Ready for our fitness journey?"\n"Start tracking today!"',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // This line creates a fresh OnboardingData object
                    final initialData = OnboardingData();

                    // Option 1: Simple push (works if no routes.dart)
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => NameScreen(data: initialData),
                    //   ),
                    // );

                    // Option 2: Recommended - use named route (cleaner & future-proof)
                    Navigator.pushNamed(
                      context,
                      AppRoutes.name,
                      arguments: initialData,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google Sign In – coming soon')),
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 32, color: Color(0xFF4285F4)),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  // TODO: Login flow
                },
                child: const Text('log In', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 16)),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}