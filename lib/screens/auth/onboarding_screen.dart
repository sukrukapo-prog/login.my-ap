import 'package:flutter/material.dart';
import 'package:fitmetrics/routes.dart';
import 'package:fitmetrics/services/local_storage.dart';

// Onboarding now goes directly to welcome — no feature showcase pages
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    _proceed();
  }

  Future<void> _proceed() async {
    await LocalStorage.setSeenOnboarding();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F1624),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
      ),
    );
  }
}
