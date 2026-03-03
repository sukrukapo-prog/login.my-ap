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

  @override
  Widget build(BuildContext context) {
    final String username = widget.userData.name ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF3B82F6),
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : "?",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Welcome${username.isNotEmpty ? ', $username' : ''}!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Let's start your day",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 32),

              // Mood selection – now interactive
              const Text(
                "How is your mood?",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMoodEmoji("😊", "Happy"),
                  _buildMoodEmoji("😢", "Sad"),
                  _buildMoodEmoji("😐", "Normal"),
                  _buildMoodEmoji("😊", "Good"),
                  _buildMoodEmoji("😂", "Excited"),
                ],
              ),
              const SizedBox(height: 40),

              // Meditation cards – using the extracted widget
              MeditationCard(
                title: "Movement Meditation",
                instructor: "Rachel Jules",
                subtitle: "Yoga Guru",
                buttonText: "Start",
                buttonColor: Colors.green,
                imagePath: "assets/images/meditation/movement_meditation.jpg",
                onStartPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Starting Movement Meditation...")),
                  );
                  // Later → Navigator.push to timer or player screen
                },
              ),
              const SizedBox(height: 16),
              MeditationCard(
                title: "Music Meditation",
                instructor: "Alice Brook",
                subtitle: "Calm Your Mind",
                buttonText: "Start",
                buttonColor: const Color(0xFF3B82F6),
                imagePath: "assets/images/meditation/music_meditation.jpg",
                onStartPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Starting Music Meditation...")),
                  );
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
      // IMPORTANT: NO bottomNavigationBar here!
      // It is managed by MainTabScreen
    );
  }

  Widget _buildMoodEmoji(String emoji, String label) {
    final isSelected = _selectedMood == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = label;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.25) : null,
              border: isSelected
                  ? Border.all(color: const Color(0xFF3B82F6), width: 2.5)
                  : null,
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 38),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}