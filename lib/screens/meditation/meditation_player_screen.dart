import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

// ── Scene model ────────────────────────────────────────────────────────────────
class CalmnessScene {
  final String name;
  final String videoPath;
  final String audioPath;
  final String figurePath;
  final IconData sceneIcon;
  final List<Color> gradientColors;
  final Color accentColor;

  const CalmnessScene({
    required this.name,
    required this.videoPath,
    required this.audioPath,
    required this.figurePath,
    required this.sceneIcon,
    required this.gradientColors,
    required this.accentColor,
  });
}

// ── Scene definitions ──────────────────────────────────────────────────────────
const List<CalmnessScene> calmnessScenes = [
  CalmnessScene(
    name: 'Rainy Vibe',
    videoPath: 'assets/images/meditation/videos/rain.mp4',
    audioPath: 'meditation/audio/rain.mp3',
    figurePath: 'assets/images/meditation/figures/rain.png',
    sceneIcon: Icons.cloud,
    gradientColors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
    accentColor: Color(0xFF4CA1AF),
  ),
  CalmnessScene(
    name: 'Ocean',
    videoPath: 'assets/images/meditation/videos/ocean.mp4',
    audioPath: 'meditation/audio/ocean.mp3',
    figurePath: 'assets/images/meditation/figures/ocean.png',
    sceneIcon: Icons.waves,
    gradientColors: [Color(0xFF1A6B8A), Color(0xFF0D3D56)],
    accentColor: Color(0xFF1A9ED9),
  ),
  CalmnessScene(
    name: 'Night',
    videoPath: 'assets/images/meditation/videos/night.mp4',
    audioPath: 'meditation/audio/night.mp3',
    figurePath: 'assets/images/meditation/figures/night.png',
    sceneIcon: Icons.nightlight_round,
    gradientColors: [Color(0xFF0F0C29), Color(0xFF302B63)],
    accentColor: Color(0xFF7B68EE),
  ),
  CalmnessScene(
    name: 'Birds',
    videoPath: 'assets/images/meditation/videos/birds.mp4',
    audioPath: 'meditation/audio/birds.mp3',
    figurePath: 'assets/images/meditation/figures/birds.png',
    sceneIcon: Icons.flutter_dash,
    gradientColors: [Color(0xFF5B7A8E), Color(0xFFB0C4DE)],
    accentColor: Color(0xFF87CEEB),
  ),
  CalmnessScene(
    name: 'Morning',
    videoPath: 'assets/images/meditation/videos/morning.mp4',
    audioPath: 'meditation/audio/morning.mp3',
    figurePath: 'assets/images/meditation/figures/morning.png',
    sceneIcon: Icons.wb_sunny,
    gradientColors: [Color(0xFFf7971e), Color(0xFFffd200)],
    accentColor: Color(0xFFf7971e),
  ),
  CalmnessScene(
    name: 'Nature',
    videoPath: 'assets/images/meditation/videos/nature.mp4',
    audioPath: 'meditation/audio/nature.mp3',
    figurePath: 'assets/images/meditation/figures/nature.png',
    sceneIcon: Icons.eco,
    gradientColors: [Color(0xFF134E5E), Color(0xFF71B280)],
    accentColor: Color(0xFF71B280),
  ),
];

// ── Player Screen ──────────────────────────────────────────────────────────────
class MeditationPlayerScreen extends StatefulWidget {
  final CalmnessScene scene;

  const MeditationPlayerScreen({Key? key, required this.scene}) : super(key: key);

  @override
  State<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends State<MeditationPlayerScreen>
    with TickerProviderStateMixin {

  int _totalSeconds = 10 * 60;
  int _remainingSeconds = 10 * 60;
  Timer? _countdownTimer;
  bool _isPlaying = false;

  double _volume = 0.8;
  bool _showVolumePanel = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? _videoController;
  bool _videoReady = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _totalSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _initVideo();
    _initAudio();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  Future<void> _initVideo() async {
    try {
      _videoController = VideoPlayerController.asset(widget.scene.videoPath);
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(0);
      if (mounted) setState(() => _videoReady = true);
    } catch (_) {}
  }

  Future<void> _initAudio() async {
    await _audioPlayer.setVolume(_volume);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _togglePlay() async {
    if (_isPlaying) {
      _countdownTimer?.cancel();
      await _audioPlayer.pause();
      _videoController?.pause();
    } else {
      _startCountdown();
      try {
        print('Trying to play: ${widget.scene.audioPath}');
        await _audioPlayer.stop();
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.play(AssetSource(widget.scene.audioPath));
        print('Playing successfully');
      } catch (e) {
        print('Audio error: $e');
      }
      if (_videoReady) _videoController?.play();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
        _audioPlayer.stop();
        _videoController?.pause();
        setState(() { _isPlaying = false; _remainingSeconds = 0; });
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _adjustTime(int minutes) {
    setState(() {
      _totalSeconds = (_totalSeconds + minutes * 60).clamp(60, 3600);
      _remainingSeconds = (_remainingSeconds + minutes * 60).clamp(0, _totalSeconds);
    });
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  double get _progress => _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;
  int get _displayMinutes => _totalSeconds ~/ 60;

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1624),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Leave Session?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center),
        content: const Text(
            'Are you sure you want to stop your meditation session?',
            style: TextStyle(color: Colors.white60, fontSize: 14),
            textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('No', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextButton(
                onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
                style: TextButton.styleFrom(
                  backgroundColor: widget.scene.accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Yes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    _videoController?.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          fit: StackFit.expand,
          children: [

            // Video or gradient background
            _videoReady && _videoController != null
                ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            )
                : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: scene.gradientColors,
                ),
              ),
            ),

            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.88),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // UI
            SafeArea(
              child: Column(
                children: [

                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _showExitDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Color(0xFFD4A017), Color(0xFFF0C040)]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('Back', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _showVolumePanel = !_showVolumePanel),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 1),
                            ),
                            child: Icon(
                              _volume == 0 ? Icons.volume_off : _volume < 0.5 ? Icons.volume_down : Icons.volume_up,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Volume slider
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    height: _showVolumePanel ? 52 : 0,
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    child: _showVolumePanel
                        ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.volume_mute, color: Colors.white54, size: 18),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: scene.accentColor,
                                inactiveTrackColor: Colors.white24,
                                thumbColor: Colors.white,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                overlayShape: SliderComponentShape.noOverlay,
                                trackHeight: 3,
                              ),
                              child: Slider(
                                value: _volume,
                                min: 0,
                                max: 1,
                                onChanged: (v) async {
                                  setState(() => _volume = v);
                                  await _audioPlayer.setVolume(v);
                                },
                              ),
                            ),
                          ),
                          const Icon(Icons.volume_up, color: Colors.white54, size: 18),
                        ],
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),

                  // Scene name
                  const SizedBox(height: 8),
                  Text(
                    scene.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
                    ),
                  ),

                  // Meditating figure
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (_, child) => Transform.scale(scale: _pulseAnimation.value, child: child),
                        child: Image.asset(
                          scene.figurePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.self_improvement,
                            size: 160,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom controls
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                    child: Column(
                      children: [

                        // Timer
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 4,
                            shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            height: 6,
                            color: Colors.white12,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progress,
                              child: Container(color: scene.accentColor),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Icons below bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(scene.sceneIcon, color: scene.accentColor, size: 18),
                            Icon(Icons.volume_up, color: Colors.white38, size: 18),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Time adjust row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _timeBtn('− 5 min', () => _adjustTime(-5)),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$_displayMinutes mins',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _timeBtn('+5 min ›', () => _adjustTime(5)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Play/Pause button
                        GestureDetector(
                          onTap: _togglePlay,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color: scene.accentColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: scene.accentColor.withOpacity(0.45),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }
}