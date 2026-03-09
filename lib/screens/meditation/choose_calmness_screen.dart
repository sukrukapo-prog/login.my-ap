import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/core/haptic_service.dart';
import 'package:fitmetrics/screens/meditation/meditation_player_screen.dart';
import 'package:fitmetrics/core/audio_service.dart';

class ChooseCalmnessScreen extends StatefulWidget {
  const ChooseCalmnessScreen({Key? key}) : super(key: key);

  @override
  State<ChooseCalmnessScreen> createState() => _ChooseCalmnessScreenState();
}

class _ChooseCalmnessScreenState extends State<ChooseCalmnessScreen> {

  @override
  void initState() {
    super.initState();
    AudioService().pauseMusic();
  }

  @override
  void dispose() {
    AudioService().resumeMusic();
    super.dispose();
  }

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
              // Back Button — YOUR original colors kept
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A233E), Color(0xEFB87A09)],
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

              // Title — YOUR original text kept
              const Text(
                'Find Your Calmness',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6.0),

              // Subtitle — YOUR original text kept
              const Text(
                'Choose a sound that soothes your mind',
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
                  children: [
                    // ← Only change: added scene + onTap, kept all visuals
                    _CalmnessCard(
                      title: 'Rain',
                      imagePath: 'assets/images/meditation/calmness/rain.png',
                      icon: Icons.cloud,
                      scene: calmnessScenes[0],
                    ),
                    _CalmnessCard(
                      title: 'Ocean',
                      imagePath: 'assets/images/meditation/calmness/ocean.png',
                      icon: Icons.waves,
                      scene: calmnessScenes[1],
                    ),
                    _CalmnessCard(
                      title: 'Night',
                      imagePath: 'assets/images/meditation/calmness/night.png',
                      icon: Icons.nightlight_round,
                      scene: calmnessScenes[2],
                    ),
                    _CalmnessCard(
                      title: 'Birds',
                      imagePath: 'assets/images/meditation/calmness/birds.png',
                      icon: Icons.flutter_dash,
                      scene: calmnessScenes[3],
                    ),
                    _CalmnessCard(
                      title: 'Morning',
                      imagePath: 'assets/images/meditation/calmness/morning.png',
                      icon: Icons.wb_sunny,
                      scene: calmnessScenes[4],
                    ),
                    _CalmnessCard(
                      title: 'Nature',
                      imagePath: 'assets/images/meditation/calmness/nature.png',
                      icon: Icons.eco,
                      scene: calmnessScenes[5],
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

class _CalmnessCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final IconData icon;
  final CalmnessScene scene;

  const _CalmnessCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.icon,
    required this.scene,
  }) : super(key: key);

  @override
  State<_CalmnessCard> createState() => _CalmnessCardState();
}

class _CalmnessCardState extends State<_CalmnessCard> {
  bool _isFav = false;
  bool _isPreviewing = false;
  final AudioPlayer _previewPlayer = AudioPlayer();

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    LocalStorage.isFavorite(widget.title).then((v) {
      if (mounted) setState(() => _isFav = v);
    });
  }

  Future<void> _startPreview() async {
    setState(() => _isPreviewing = true);
    try {
      final path = widget.scene.audioPath.replaceFirst('assets/', '');
      await _previewPlayer.play(AssetSource(path));
      await Future.delayed(const Duration(seconds: 5));
      await _stopPreview();
    } catch (_) {
      setState(() => _isPreviewing = false);
    }
  }

  Future<void> _stopPreview() async {
    await _previewPlayer.stop();
    if (mounted) setState(() => _isPreviewing = false);
  }

  Future<void> _toggleFav() async {
    HapticService.medium();
    await LocalStorage.toggleFavorite(widget.title);
    setState(() => _isFav = !_isFav);
  }

  @override
  Widget build(BuildContext context) {
    // ← Wrapped in GestureDetector — only addition to your build method
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MeditationPlayerScreen(scene: widget.scene),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Preview overlay
            if (_isPreviewing)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withAlpha(120),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.music_note, color: Colors.white, size: 30),
                        SizedBox(height: 6),
                        Text('Hold to preview', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            // Fav heart
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: _toggleFav,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(120),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFav ? Icons.favorite : Icons.favorite_border,
                    color: _isFav ? Colors.redAccent : Colors.white70,
                    size: 17,
                  ),
                ),
              ),
            ),
            // YOUR original image + fallback — unchanged
            Image.asset(
              widget.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _gradientForTitle(widget.title),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: Colors.white.withOpacity(0.5),
                      size: 48.0,
                    ),
                  ),
                );
              },
            ),

            // YOUR original overlay — unchanged
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

            // YOUR original title — unchanged
            Positioned(
              top: 12.0,
              left: 12.0,
              child: Text(
                widget.title,
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

            // YOUR original select button — unchanged
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
      ),
    );
  }

  // YOUR original gradients — unchanged
  List<Color> _gradientForTitle(String title) {
    switch (widget.title) {
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