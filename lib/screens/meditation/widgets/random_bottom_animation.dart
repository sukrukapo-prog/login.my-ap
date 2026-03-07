import 'dart:math' as math;
import 'package:flutter/material.dart';

enum _Style { waves, particles, bars, circles }

/// Picks one of 4 animation styles randomly each time it is created.
/// Only runs animation when [isPlaying] is true.
class RandomBottomAnimation extends StatefulWidget {
  final Color color;
  final double height;
  final bool isPlaying;

  const RandomBottomAnimation({
    super.key,
    required this.color,
    required this.isPlaying,
    this.height = 48,
  });

  @override
  State<RandomBottomAnimation> createState() => _RandomBottomAnimationState();
}

class _RandomBottomAnimationState extends State<RandomBottomAnimation>
    with TickerProviderStateMixin {

  late final _Style _style =
  _Style.values[math.Random().nextInt(_Style.values.length)];

  late AnimationController _c1, _c2, _c3;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2200));
    _c2 = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1700));
    _c3 = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2600));

    if (widget.isPlaying) _startAll();
  }

  void _startAll() {
    _c1.repeat(); _c2.repeat(); _c3.repeat();
  }

  void _stopAll() {
    _c1.stop(); _c2.stop(); _c3.stop();
  }

  @override
  void didUpdateWidget(RandomBottomAnimation old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !old.isPlaying) _startAll();
    if (!widget.isPlaying && old.isPlaying) _stopAll();
  }

  @override
  void dispose() {
    _c1.dispose(); _c2.dispose(); _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isPlaying ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: AnimatedBuilder(
        animation: Listenable.merge([_c1, _c2, _c3]),
        builder: (_, __) => SizedBox(
          height: widget.height,
          child: CustomPaint(
            painter: _makePainter(),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  CustomPainter _makePainter() {
    switch (_style) {
      case _Style.waves:
        return _WavesPainter(
            p1: _c1.value * 2 * math.pi,
            p2: _c2.value * 2 * math.pi,
            p3: _c3.value * 2 * math.pi,
            color: widget.color);
      case _Style.particles:
        return _ParticlesPainter(t: _c1.value, color: widget.color);
      case _Style.bars:
        return _BarsPainter(
            t1: _c1.value, t2: _c2.value, t3: _c3.value, color: widget.color);
      case _Style.circles:
        return _CirclesPainter(
            t1: _c1.value, t2: _c2.value, t3: _c3.value, color: widget.color);
    }
  }
}

// ── 1. Waves ───────────────────────────────────────────────────────────────────
class _WavesPainter extends CustomPainter {
  final double p1, p2, p3;
  final Color color;
  _WavesPainter(
      {required this.p1, required this.p2, required this.p3, required this.color});

  void _draw(Canvas c, Size s, double phase, double amp, double freq, Color col) {
    final path = Path();
    final mid = s.height * 0.5;
    path.moveTo(0, mid);
    for (double x = 0; x <= s.width; x++) {
      path.lineTo(x, mid + amp * math.sin(x / s.width * freq * 2 * math.pi + phase));
    }
    path.lineTo(s.width, s.height);
    path.lineTo(0, s.height);
    path.close();
    c.drawPath(path, Paint()..color = col..style = PaintingStyle.fill);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _draw(canvas, size, p1, size.height * 0.38, 2.0, color.withAlpha(55));
    _draw(canvas, size, p2, size.height * 0.28, 2.5, color.withAlpha(38));
    _draw(canvas, size, p3, size.height * 0.18, 3.2, color.withAlpha(22));
  }

  @override
  bool shouldRepaint(_WavesPainter o) => true;
}

// ── 2. Particles ───────────────────────────────────────────────────────────────
class _ParticlesPainter extends CustomPainter {
  final double t;
  final Color color;
  _ParticlesPainter({required this.t, required this.color});

  static final _rng = math.Random(42);
  static final List<_Particle> _particles = List.generate(
      18,
          (i) => _Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        r: 1.5 + _rng.nextDouble() * 2.5,
        speed: 0.3 + _rng.nextDouble() * 0.7,
        phase: _rng.nextDouble() * 2 * math.pi,
      ));

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final progress = (t * p.speed + p.phase / (2 * math.pi)) % 1.0;
      final x = (p.x + progress * 0.6) % 1.0 * size.width;
      final y = p.y * size.height;
      final alpha = (math.sin(progress * math.pi) * 180).toInt().clamp(0, 255);
      canvas.drawCircle(
        Offset(x, y),
        p.r,
        Paint()..color = color.withAlpha(alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter o) => true;
}

class _Particle {
  final double x, y, r, speed, phase;
  _Particle(
      {required this.x,
        required this.y,
        required this.r,
        required this.speed,
        required this.phase});
}

// ── 3. Bars ────────────────────────────────────────────────────────────────────
class _BarsPainter extends CustomPainter {
  final double t1, t2, t3;
  final Color color;
  _BarsPainter(
      {required this.t1, required this.t2, required this.t3, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 20;
    final barW = size.width / barCount * 0.6;
    final gap = size.width / barCount;
    final phases = [t1, t2, t3];

    for (int i = 0; i < barCount; i++) {
      final phase = phases[i % 3] * 2 * math.pi;
      final h = size.height *
          (0.2 + 0.65 * math.pow(
              math.sin(i / barCount * math.pi * 2 + phase).abs(), 0.5));
      final x = i * gap + gap / 2 - barW / 2;
      final alpha = (80 + 100 * math.sin(i / barCount * math.pi).abs()).toInt()
          .clamp(0, 255);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - h, barW, h),
          const Radius.circular(3),
        ),
        Paint()..color = color.withAlpha(alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter o) => true;
}

// ── 4. Circles ─────────────────────────────────────────────────────────────────
class _CirclesPainter extends CustomPainter {
  final double t1, t2, t3;
  final Color color;
  _CirclesPainter(
      {required this.t1, required this.t2, required this.t3, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final times = [t1, t2, t3];
    for (int i = 0; i < 5; i++) {
      final t = times[i % 3];
      final maxR = size.width * 0.35 * (0.5 + i * 0.12);
      final progress = (t + i * 0.2) % 1.0;
      final r = progress * maxR;
      final alpha = ((1.0 - progress) * 60).toInt().clamp(0, 255);
      canvas.drawCircle(
        Offset(cx + math.sin(i * 1.2) * size.width * 0.2, cy),
        r,
        Paint()
          ..color = color.withAlpha(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_CirclesPainter o) => true;
}
