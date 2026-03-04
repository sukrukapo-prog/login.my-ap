import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/screens/meditation/widgets/meditation_card.dart';

class MeditationScreen extends StatefulWidget {
  final OnboardingData userData;

  const MeditationScreen({super.key, required this.userData});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  String? _selectedMood;
  double _cardScale1 = 1.0;
  double _cardScale2 = 1.0;

  @override
  Widget build(BuildContext context) {
    final username = widget.userData.name ?? "User";

    return Scaffold(
      body: Container(
        // Subtle background gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1624),
              Color(0xFF0A0F1A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(           // ← This fixes the overflow
            physics: const BouncingScrollPhysics(), // nice bounce on iOS/Android
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header with username
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Welcome${username.isNotEmpty ? ', $username' : ''}!",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF3B82F6),
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : "?",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Let's start your day",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),

                  const SizedBox(height: 32),

                  // Mood selection with colored circles + glow
                  const Text(
                    "How is your mood?",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMood("😊", "Happy",   const Color(0xFFFFC107)),
                      _buildMood("😢", "Sad",     const Color(0xFF2196F3)),
                      _buildMood("😐", "Normal",  Colors.grey),
                      _buildMood("😊", "Good",    const Color(0xFF4CAF50)),
                      _buildMood("😎", "Excited", const Color(0xFFF44336)),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Cards with micro-animation, featured badge, larger size & shadow
                  GestureDetector(
                    onTapDown: (_) => setState(() => _cardScale1 = 0.96),
                    onTapUp: (_) => setState(() => _cardScale1 = 1.0),
                    onTapCancel: () => setState(() => _cardScale1 = 1.0),
                    child: AnimatedScale(
                      scale: _cardScale1,
                      duration: const Duration(milliseconds: 120),
                      child: MeditationCard(
                        title: "$username's Movement Meditation",
                        instructor: username,
                        subtitle: "Awaken Your Body & Mind",
                        buttonText: "Start",
                        buttonColor: Colors.green,
                        imagePath: "assets/images/meditation/movement_meditation.jpg",
                        isFeatured: true,
                        onStartPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Starting Movement Meditation...")),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTapDown: (_) => setState(() => _cardScale2 = 0.96),
                    onTapUp: (_) => setState(() => _cardScale2 = 1.0),
                    onTapCancel: () => setState(() => _cardScale2 = 1.0),
                    child: AnimatedScale(
                      scale: _cardScale2,
                      duration: const Duration(milliseconds: 120),
                      child: MeditationCard(
                        title: "$username's Music Meditation",
                        instructor: username,
                        subtitle: "Calm Your Mind",
                        buttonText: "Start",
                        buttonColor: const Color(0xFF3B82F6),
                        imagePath: "assets/images/meditation/music_meditation.jpg",
                        isFeatured: false,
                        onStartPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Starting Music Meditation...")),
                          );
                        },
                      ),
                    ),
                  ),

                  // Motivational quote – moved to bottom
                  const SizedBox(height: 40),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Breathe. Let go. And remind yourself that this very moment is the only one you know you have for sure.",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60), // extra bottom space – prevents tight look
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMood(String emoji, String label, Color color) {
    final isSelected = _selectedMood == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedMood = label),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: isSelected
                  ? [
                BoxShadow(color: color.withOpacity(0.7), blurRadius: 14, spreadRadius: 5),
                BoxShadow(color: color.withOpacity(0.45), blurRadius: 24, spreadRadius: 12),
              ]
                  : [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 40, color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.white70,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}