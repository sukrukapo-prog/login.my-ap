import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';

class ProfileScreen extends StatelessWidget {
  final OnboardingData userData;

  const ProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF3B82F6),
            child: Text(
              userData.name?.substring(0, 1).toUpperCase() ?? "?",
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Hello, ${userData.name ?? 'User'}",
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Profile Page\n(Coming soon)",
            style: TextStyle(color: Colors.white70, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}