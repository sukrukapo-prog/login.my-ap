import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/core/avatar_data.dart';
import 'package:fitmetrics/screens/meditation/widgets/meditation_card.dart';
import 'package:fitmetrics/screens/meditation/choose_calmness_screen.dart';
import 'package:fitmetrics/screens/meditation/movement/movement_meditation_screen.dart';
import 'package:fitmetrics/services/local_storage.dart';

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
  String _preferredName = '';
  String? _avatarId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String name = widget.userData.name ?? '';
    if (name.isEmpty) {
      final saved = await LocalStorage.getUserData();
      name = saved?.name ?? '';
    }
    final avatarId = await LocalStorage.getAvatarId();
    setState(() {
      _preferredName = name;
      _avatarId = avatarId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = _preferredName.isNotEmpty ? _preferredName : 'there';

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1624), Color(0xFF0A0F1A)],
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20, 0, 20,
              MediaQuery.of(context).padding.bottom + 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header with avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Welcome, $username!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // User's selected avatar
                    AvatarWidget(avatarId: _avatarId, size: 44, showBorder: true),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's start your day",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),

                const SizedBox(height: 36),

                const Text(
                  "How is your mood?",
                  style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // Mood selection
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: 5,
                    separatorBuilder: (context, index) => const SizedBox(width: 20),
                    itemBuilder: (context, index) {
                      final moods = [
                        ["🥺", "Sad",       const Color(0xFF007AA5)],
                        ["😩", "Exhausted", const Color(0xFFDEBD9E)],
                        ["😐", "Normal",    Colors.grey],
                        ["😊", "Good",      const Color(0xFF9CFFDB)],
                        ["😎", "Excited",   const Color(0xFFE09B51)],
                      ];
                      final mood = moods[index];
                      return _buildMood(mood[0] as String, mood[1] as String, mood[2] as Color);
                    },
                  ),
                ),

                const SizedBox(height: 48),

                // Movement card
                GestureDetector(
                  onTapDown: (_) => setState(() => _cardScale1 = 0.96),
                  onTapUp: (_) => setState(() => _cardScale1 = 1.0),
                  onTapCancel: () => setState(() => _cardScale1 = 1.0),
                  child: AnimatedScale(
                    scale: _cardScale1,
                    duration: const Duration(milliseconds: 120),
                    child: MeditationCard(
                      title: "lets start Movement Meditation",
                      instructor: username,
                      subtitle: "Awaken Your Body & Mind",
                      buttonText: "Start",
                      buttonColor: Colors.green,
                      imagePath: "assets/images/meditation/movement_meditation.jpg",
                      isFeatured: true,
                      onStartPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MovementMeditationScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Music card
                GestureDetector(
                  onTapDown: (_) => setState(() => _cardScale2 = 0.96),
                  onTapUp: (_) => setState(() => _cardScale2 = 1.0),
                  onTapCancel: () => setState(() => _cardScale2 = 1.0),
                  child: AnimatedScale(
                    scale: _cardScale2,
                    duration: const Duration(milliseconds: 120),
                    child: MeditationCard(
                      title: "Relax your breathing with music",
                      instructor: username,
                      subtitle: "Calm Your Mind",
                      buttonText: "Start",
                      buttonColor: const Color(0xFF3B82F6),
                      imagePath: "assets/images/meditation/music_meditation.jpg",
                      isFeatured: false,
                      onStartPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChooseCalmnessScreen()),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 48),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Breathe. Let go. And remind yourself that this very moment is the only one you know you have for sure.",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 140),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMood(String emoji, String label, Color color) {
    final isSelected = _selectedMood == label;

    final moodMessages = {
      "Sad":       "Sorry you're feeling down... let's lift your mood together with something calming.",
      "Exhausted": "Feeling drained? A gentle music meditation might help you recharge slowly.",
      "Normal":    "Feeling steady? Perfect moment to center yourself — what calls to you today?",
      "Good":      "Solid vibes! Great time to build on that with a quick meditation session.",
      "Excited":   "Love that spark! Let's channel it — movement to energize or music to flow?",
    };

    return GestureDetector(
      onTap: () {
        setState(() => _selectedMood = label);
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(moodMessages[label] ?? "Nice choice!", style: const TextStyle(color: Colors.white, fontSize: 14)),
            backgroundColor: color.withOpacity(0.92),
            duration: const Duration(seconds: 3, milliseconds: 500),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 80),
            elevation: 6,
          ),
        );
      },
      child: AnimatedScale(
        scale: isSelected ? 1.14 : 1.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withOpacity(0.65), blurRadius: 18, spreadRadius: 6, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.26), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(emoji, style: const TextStyle(fontSize: 44, height: 1.0, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 280),
              style: TextStyle(
                color: isSelected ? color : Colors.white70,
                fontSize: isSelected ? 14.5 : 13.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}