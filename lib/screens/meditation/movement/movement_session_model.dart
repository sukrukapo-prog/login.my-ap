import 'package:flutter/material.dart';

class MovementSession {
  final String id;
  final String title;
  final String imagePath;
  final String introVideoPath;
  final String loopVideoPath;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;
  final List<String> bulletPoints;
  final String duration;
  final String difficulty;

  const MovementSession({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.introVideoPath,
    required this.loopVideoPath,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
    required this.bulletPoints,
    required this.duration,
    required this.difficulty,
  });

  /// Always the 2nd bullet point (index 1)
  String get purpose => bulletPoints[1];
}

String _img(String name) =>
    'assets/images/meditation/movement_meditation/$name';
String _vid(String name) =>
    'assets/images/meditation/movement_meditation/videos/$name';

final List<MovementSession> movementSessions = [
  MovementSession(
    id: 'walking_turtle',
    title: 'Walking Turtle',
    imagePath: _img('walking_turtle.jpg'),
    introVideoPath: _vid('walking_turtle_intro.mp4'),
    loopVideoPath: _vid('walking_turtle_loop.mp4'),
    icon: Icons.directions_walk,
    gradientColors: const [Color(0xFF1A3A2A), Color(0xFF0F1F16)],
    accentColor: const Color(0xFF4CAF50),
    duration: '10 min',
    difficulty: 'Beginner',
    bulletPoints: const [
      'Move slowly and breathe deeply with each step',
      'Grounds your mind in the present moment',
      'Perfect for releasing built-up tension',
    ],
  ),
  MovementSession(
    id: 'the_fountain',
    title: 'The Fountain',
    imagePath: _img('the_fountain.jpg'),
    introVideoPath: _vid('the_fountain_intro.mp4'),
    loopVideoPath: _vid('the_fountain_loop.mp4'),
    icon: Icons.water,
    gradientColors: const [Color(0xFF0D2137), Color(0xFF0A1520)],
    accentColor: const Color(0xFF29B6F6),
    duration: '12 min',
    difficulty: 'Beginner',
    bulletPoints: const [
      'Flow through gentle rising and falling movements',
      'Clears mental fog and restores calm energy',
      'Inspired by the natural rhythm of water',
    ],
  ),
  MovementSession(
    id: 'rising_tide',
    title: 'Rising Tide',
    imagePath: _img('rising_tide.jpg'),
    introVideoPath: _vid('rising_tide_intro.mp4'),
    loopVideoPath: _vid('rising_tide_loop.mp4'),
    icon: Icons.waves,
    gradientColors: const [Color(0xFF0A2340), Color(0xFF061525)],
    accentColor: const Color(0xFF1E88E5),
    duration: '15 min',
    difficulty: 'Intermediate',
    bulletPoints: const [
      'Build strength through steady rising movements',
      'Awakens confidence and inner resilience',
      'Let each breath lift you higher',
    ],
  ),
  MovementSession(
    id: 'flowing_water',
    title: 'Flowing Water',
    imagePath: _img('flowing_water.jpg'),
    introVideoPath: _vid('flowing_water_intro.mp4'),
    loopVideoPath: _vid('flowing_water_loop.mp4'),
    icon: Icons.stream,
    gradientColors: const [Color(0xFF0D2B3E), Color(0xFF091A26)],
    accentColor: const Color(0xFF26C6DA),
    duration: '14 min',
    difficulty: 'Beginner',
    bulletPoints: const [
      'Fluid movements that follow your breath',
      'Releases stiffness and restores flexibility',
      'Feel yourself flow with effortless grace',
    ],
  ),
  MovementSession(
    id: 'falling_rain',
    title: 'Falling Rain',
    imagePath: _img('falling_rain.jpg'),
    introVideoPath: _vid('falling_rain_intro.mp4'),
    loopVideoPath: _vid('falling_rain_loop.mp4'),
    icon: Icons.grain,
    gradientColors: const [Color(0xFF1A2535), Color(0xFF0F1825)],
    accentColor: const Color(0xFF7986CB),
    duration: '10 min',
    difficulty: 'Beginner',
    bulletPoints: const [
      'Calm yourself with falling rain meditation',
      'Feel relief and complete ease in each breath',
      'Let go — breathe in, breathe out',
    ],
  ),
  MovementSession(
    id: 'gentle_breeze',
    title: 'Gentle Breeze',
    imagePath: _img('gentle_breeze.jpg'),
    introVideoPath: _vid('gentle_breeze_intro.mp4'),
    loopVideoPath: _vid('gentle_breeze_loop.mp4'),
    icon: Icons.air,
    gradientColors: const [Color(0xFF1A2E1F), Color(0xFF0F1D13)],
    accentColor: const Color(0xFF66BB6A),
    duration: '8 min',
    difficulty: 'Beginner',
    bulletPoints: const [
      'Light swaying movements like leaves in the wind',
      'Soothes anxiety and quiets a busy mind',
      'The gentlest way to begin your practice',
    ],
  ),
  MovementSession(
    id: 'cresting_waves',
    title: 'Cresting Waves',
    imagePath: _img('cresting_waves.jpg'),
    introVideoPath: _vid('cresting_waves_intro.mp4'),
    loopVideoPath: _vid('cresting_waves_loop.mp4'),
    icon: Icons.waves_outlined,
    gradientColors: const [Color(0xFF0D2040), Color(0xFF081428)],
    accentColor: const Color(0xFF42A5F5),
    duration: '18 min',
    difficulty: 'Advanced',
    bulletPoints: const [
      'Dynamic movements that build and release tension',
      'Deepens body awareness and full presence',
      'Ride the wave of each breath to its peak',
    ],
  ),
];
