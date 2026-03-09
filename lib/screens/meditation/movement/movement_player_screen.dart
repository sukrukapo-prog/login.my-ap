import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:fitmetrics/screens/meditation/movement/movement_session_model.dart';
import 'package:fitmetrics/screens/meditation/movement/widgets/movement_circular_timer.dart';
import 'package:fitmetrics/screens/meditation/movement/widgets/movement_wave_animation.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/core/audio_service.dart';

class MovementPlayerScreen extends StatefulWidget {
  final MovementSession session;
  const MovementPlayerScreen({super.key, required this.session});

  @override
  State<MovementPlayerScreen> createState() => _MovementPlayerScreenState();
}

class _MovementPlayerScreenState extends State<MovementPlayerScreen>
    with TickerProviderStateMixin {

  // ── Video ──────────────────────────────────────────────────────────────────
  VideoPlayerController? _introCtrl;
  VideoPlayerController? _loopCtrl;
  bool _introReady  = false;
  bool _loopReady   = false;
  bool _playingLoop = false;

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isPlaying      = false;
  bool _sessionStarted = false;
  bool _guidedMode     = true;   // ON = play intro first
  bool _showVolume     = false;
  double _volume       = 1.0;

  // ── Timer ──────────────────────────────────────────────────────────────────
  int _totalSeconds     = 10 * 60;
  int _remainingSeconds = 10 * 60;
  Timer? _countdownTimer;

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late ConfettiController _confettiCtrl;
  late Animation<double>   _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();

    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    AudioService().pauseMusic();
    _initVideos();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  // ── Video init ─────────────────────────────────────────────────────────────

  Future<void> _initVideos() async {
    try {
      _introCtrl = VideoPlayerController.asset(widget.session.introVideoPath);
      await _introCtrl!.initialize();
      _introCtrl!.setLooping(false);
      _introCtrl!.setVolume(_volume);
      _introCtrl!.addListener(_watchIntroEnd);
      if (mounted) setState(() => _introReady = true);
    } catch (_) {}

    try {
      _loopCtrl = VideoPlayerController.asset(widget.session.loopVideoPath);
      await _loopCtrl!.initialize();
      _loopCtrl!.setLooping(true);
      _loopCtrl!.setVolume(_volume);
      if (mounted) setState(() => _loopReady = true);
    } catch (_) {}
  }

  void _watchIntroEnd() {
    if (_introCtrl == null || _playingLoop) return;
    final pos = _introCtrl!.value.position;
    final dur = _introCtrl!.value.duration;
    if (dur.inMilliseconds > 0 &&
        pos.inMilliseconds >= dur.inMilliseconds - 400) {
      _switchToLoop();
    }
  }

  void _switchToLoop() {
    if (!mounted || _playingLoop) return;
    setState(() => _playingLoop = true);
    _introCtrl?.pause();
    if (_loopReady) _loopCtrl?.play();
  }

  // ── Playback ───────────────────────────────────────────────────────────────

  void _startSession() {
    setState(() {
      _isPlaying      = true;
      _sessionStarted = true;
    });
    _startCountdown();

    if (_guidedMode) {
      // Play intro first
      setState(() => _playingLoop = false);
      if (_introReady) _introCtrl?.play();
    } else {
      // Skip straight to loop
      setState(() => _playingLoop = true);
      if (_loopReady) _loopCtrl?.play();
    }
  }

  void _togglePause() {
    if (_isPlaying) {
      _countdownTimer?.cancel();
      _activeVideo?.pause();
      setState(() => _isPlaying = false);
    } else {
      _startCountdown();
      _activeVideo?.play();
      setState(() => _isPlaying = true);
    }
  }

  // ── Volume ─────────────────────────────────────────────────────────────────

  void _setVolume(double v) {
    setState(() => _volume = v);
    _introCtrl?.setVolume(v);
    _loopCtrl?.setVolume(v);
  }

  // ── Timer ──────────────────────────────────────────────────────────────────

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_remainingSeconds <= 0) {
        t.cancel();
        _activeVideo?.pause();
        _saveTime();
        setState(() { _isPlaying = false; _remainingSeconds = 0; });
        _confettiCtrl.play();
        _showCompletionDialog();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _adjustTime(int minutes) {
    setState(() {
      _totalSeconds = (_totalSeconds + minutes * 60).clamp(5 * 60, 60 * 60);
      if (!_sessionStarted) {
        _remainingSeconds = _totalSeconds;
      } else {
        _remainingSeconds =
            (_remainingSeconds + minutes * 60).clamp(0, _totalSeconds);
      }
    });
  }

  // ── Back / exit ────────────────────────────────────────────────────────────

  void _onBack() {
    if (!_sessionStarted) {
      Navigator.pop(context);
      return;
    }
    if (_isPlaying) {
      _countdownTimer?.cancel();
      _activeVideo?.pause();
      setState(() => _isPlaying = false);
    }
    _showExitDialog();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(180),
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: widget.session.accentColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_run,
                color: widget.session.accentColor, size: 28),
          ),
          const SizedBox(height: 14),
          const Text('Leave Session?',
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w800, fontSize: 20),
              textAlign: TextAlign.center),
        ]),
        content: Text(
          'Your meditation time will be saved.\nAre you sure you want to stop?',
          style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        actions: [
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _startCountdown();
                  _activeVideo?.play();
                  setState(() => _isPlaying = true);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withAlpha(25)),
                  ),
                  child: const Center(
                    child: Text('Keep Going',
                        style: TextStyle(color: Colors.white70,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await _saveTime();
                  if (mounted) Navigator.pop(context);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.session.accentColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Yes, Leave',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(180),
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: widget.session.accentColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline,
                color: widget.session.accentColor, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Session Complete!',
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w800, fontSize: 20),
              textAlign: TextAlign.center),
        ]),
        content: Text('Great work! Your meditation time has been saved.',
            style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 14),
            textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        actions: [
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.session.accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Done',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTime() async {
    final spent = (_totalSeconds - _remainingSeconds) ~/ 60;
    await LocalStorage.addMeditationMinutes(DateTime.now(), spent);
  }

  VideoPlayerController? get _activeVideo =>
      _playingLoop ? _loopCtrl : _introCtrl;
  bool get _videoReady => _playingLoop ? _loopReady : _introReady;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _introCtrl?.removeListener(_watchIntroEnd);
    _introCtrl?.dispose();
    _loopCtrl?.dispose();
    _confettiCtrl.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    AudioService().resumeMusic();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final size    = MediaQuery.of(context).size;
    final videoH  = size.height * 0.52;

    return WillPopScope(
      onWillPop: () async { _onBack(); return false; },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            child: Column(
              children: [

                // ── TOP — back button ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _onBack,
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withAlpha(35)),
                          ),
                          child: const Icon(Icons.chevron_left,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // ── VIDEO — softly rounded rectangle ──────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: SizedBox(
                      height: videoH,
                      width: double.infinity,
                      child: _videoReady && _activeVideo != null
                          ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _activeVideo!.value.size.width,
                          height: _activeVideo!.value.size.height,
                          child: VideoPlayer(_activeVideo!),
                        ),
                      )
                          : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: session.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(session.icon,
                              color: session.accentColor.withAlpha(100),
                              size: 72),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // ── BOTTOM PANEL ───────────────────────────────────────────
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1624),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28)),
                        border: Border.all(
                            color: session.accentColor.withAlpha(40)),
                      ),
                      child: Stack(
                        children: [

                          // Wave animation at very bottom
                          Positioned(
                            bottom: 0, left: 0, right: 0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(28)),
                              child: MovementWaveAnimation(
                                color: session.accentColor,
                                height: 38,
                                isPlaying: _isPlaying,
                              ),
                            ),
                          ),

                          // Controls
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // Row 1: Session name + icon
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      session.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Icon(session.icon,
                                        color: session.accentColor, size: 20),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Row 2: Circular timer + — Play + + Start Session label
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [

                                    // Circular timer (left)
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text('Session Timer',
                                            style: TextStyle(
                                              color:
                                              Colors.white.withAlpha(130),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            )),
                                        const SizedBox(height: 4),
                                        MovementCircularTimer(
                                          totalSeconds: _totalSeconds,
                                          remainingSeconds: _remainingSeconds,
                                          accentColor: session.accentColor,
                                          size: 88,
                                        ),
                                      ],
                                    ),

                                    const Spacer(),

                                    // — Play + column (center-right)
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            // Minus button
                                            GestureDetector(
                                              onTap: () => _adjustTime(-5),
                                              child: Text(
                                                '−',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withAlpha(200),
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            // Play / Pause button
                                            GestureDetector(
                                              onTap: _sessionStarted
                                                  ? _togglePause
                                                  : _startSession,
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 150),
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: session.accentColor,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: session.accentColor
                                                          .withAlpha(100),
                                                      blurRadius: 16,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  _isPlaying
                                                      ? Icons.pause_rounded
                                                      : Icons
                                                      .play_arrow_rounded,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            // Plus button
                                            GestureDetector(
                                              onTap: () => _adjustTime(5),
                                              child: Text(
                                                '+',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withAlpha(200),
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          _sessionStarted
                                              ? (_isPlaying
                                              ? 'Playing'
                                              : 'Paused')
                                              : 'Start Session',
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(150),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const Spacer(),

                                    // Soundscapes volume (right)
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () => setState(
                                                  () => _showVolume = !_showVolume),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: _showVolume
                                                  ? session.accentColor
                                                  .withAlpha(40)
                                                  : Colors.white.withAlpha(12),
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _showVolume
                                                    ? session.accentColor
                                                    .withAlpha(120)
                                                    : Colors.white
                                                    .withAlpha(20),
                                              ),
                                            ),
                                            child: Icon(
                                              _volume == 0
                                                  ? Icons.volume_off
                                                  : _volume < 0.5
                                                  ? Icons.volume_down
                                                  : Icons.volume_up,
                                              color: _showVolume
                                                  ? session.accentColor
                                                  : Colors.white60,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Soundscapes',
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(100),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Volume slider (inline, shows when tapped)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: _showVolume ? 44 : 0,
                                  child: _showVolume
                                      ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.volume_mute,
                                            color: Colors.white38,
                                            size: 16),
                                        Expanded(
                                          child: SliderTheme(
                                            data: SliderThemeData(
                                              trackHeight: 3,
                                              activeTrackColor:
                                              session.accentColor,
                                              inactiveTrackColor:
                                              Colors.white
                                                  .withAlpha(30),
                                              thumbColor: Colors.white,
                                              thumbShape:
                                              const RoundSliderThumbShape(
                                                  enabledThumbRadius:
                                                  7),
                                              overlayShape:
                                              SliderComponentShape
                                                  .noOverlay,
                                            ),
                                            child: Slider(
                                              value: _volume,
                                              onChanged: _setVolume,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.volume_up,
                                            color: Colors.white38,
                                            size: 16),
                                      ],
                                    ),
                                  )
                                      : const SizedBox.shrink(),
                                ),

                                const SizedBox(height: 4),

                                // Guided Mode toggle row
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome,
                                        color: session.accentColor, size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Guided Mode',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Transform.scale(
                                      scale: 0.85,
                                      child: Switch(
                                        value: _guidedMode,
                                        onChanged: _sessionStarted
                                            ? null
                                            : (v) => setState(
                                                () => _guidedMode = v),
                                        activeColor: session.accentColor,
                                        activeTrackColor: session.accentColor
                                            .withAlpha(80),
                                        inactiveThumbColor: Colors.white38,
                                        inactiveTrackColor:
                                        Colors.white.withAlpha(20),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                // Difficulty + Purpose of meditation
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.loop,
                                        color: session.accentColor
                                            .withAlpha(180),
                                        size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${session.difficulty} Mode',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(150),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.spa_outlined,
                                        color: session.accentColor
                                            .withAlpha(180),
                                        size: 14),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        session.purpose,
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(180),
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
