import 'package:flutter/material.dart';

class ChooseCalmnessScreen extends StatelessWidget {
  const ChooseCalmnessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4A017), Color(0xFFF0C040)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 14.0,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // Title
              const Text(
                'Choose Your Calmness',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6.0),

              // Subtitle
              const Text(
                'Find your focus with a curated scene',
                style: TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20.0),

              // Grid of cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 0.85,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    _CalmnessCard(
                      title: 'Rainy Vibe',
                      imagePath: 'assets/images/rainy_vibe.png',
                      icon: Icons.cloud,
                    ),
                    _CalmnessCard(
                      title: 'Ocean',
                      imagePath: 'assets/images/ocean.png',
                      icon: Icons.waves,
                    ),
                    _CalmnessCard(
                      title: 'Night',
                      imagePath: 'assets/images/night.png',
                      icon: Icons.nightlight_round,
                    ),
                    _CalmnessCard(
                      title: 'Birds',
                      imagePath: 'assets/images/birds.png',
                      icon: Icons.flutter_dash,
                    ),
                    _CalmnessCard(
                      title: 'Morning',
                      imagePath: 'assets/images/morning.png',
                      icon: Icons.wb_sunny,
                    ),
                    _CalmnessCard(
                      title: 'Nature',
                      imagePath: 'assets/images/nature.png',
                      icon: Icons.eco,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalmnessCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final IconData icon;

  const _CalmnessCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image (replace imagePath with real assets)
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback gradient background if image not found
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientForTitle(title),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white.withOpacity(0.5),
                    size: 48.0,
                  ),
                ),
              );
            },
          ),

          // Dark overlay gradient at bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),

          // Title at top left
          Positioned(
            top: 12.0,
            left: 12.0,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // Select button at bottom right
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Text(
                'Select',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _gradientForTitle(String title) {
    switch (title) {
      case 'Rainy Vibe':
        return [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)];
      case 'Ocean':
        return [const Color(0xFF1A6B8A), const Color(0xFF0D3D56)];
      case 'Night':
        return [const Color(0xFF0F0C29), const Color(0xFF302B63)];
      case 'Birds':
        return [const Color(0xFF5B7A8E), const Color(0xFFB0C4DE)];
      case 'Morning':
        return [const Color(0xFF614385), const Color(0xFF516395)];
      case 'Nature':
        return [const Color(0xFF134E5E), const Color(0xFF71B280)];
      default:
        return [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)];
    }
  }
}