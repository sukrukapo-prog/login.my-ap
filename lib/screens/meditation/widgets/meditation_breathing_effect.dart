import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Breathing glow rings + floating particles behind meditation figure.
/// - [isPlaying] — rings and ambient particles only show after session starts
/// - [showParticleBurst] — tap screen to trigger a particle burst
class MeditationBreathingEffect extends StatefulWidget {
  final Color accentColor;
  final bool isPlaying;
  final bool showParticleBurst;

  const MeditationBreathingEffect({
    super.key,
    required this.accentColor,
    required this.isPlaying,
    this.showParticleBurst = false,
  });

  @override
  State<MeditationBreathingEffect> createState() =>
      _MeditationBreathingEffectState();
}

class _MeditationBreathingEffectState extends State<MeditationBreathingEffect>
    with TickerProviderStateMixin {

  late AnimationController _breathCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _burstCtrl;
  late Animation<double> _breathAnim;
  late Animation<double> _burstAnim;

  @override
  void initState() {
    super.initState();

    _breathCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4));
    _breathAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut),
    );

    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6));

    _burstCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _burstAnim =
        CurvedAnimation(parent: _burstCtrl, curve: Curves.easeOut);

    if (widget.isPlaying) {
      _breathCtrl.repeat(reverse: true);
      _particleCtrl.repeat();
    }
  }

  @override
  void didUpdateWidget(MeditationBreathingEffect old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !old.isPlaying) {
      _breathCtrl.repeat(reverse: true);
      _particleCtrl.repeat();
    } else if (!widget.isPlaying && old.isPlaying) {
      _breathCtrl.stop();
      _particleCtrl.stop();
    }
    if (widget.showParticleBurst && !old.showParticleBurst) {
      _burstCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _particleCtrl.dispose();
    _burstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
      Listenable.merge([_breathCtrl, _particleCtrl, _burstCtrl]),
      builder: (_, __) => CustomPaint(
        painter: _BreathingPainter(
          breathScale: _breathAnim.value,
          particleT: _particleCtrl.value,
          burstT: _burstAnim.value,
          color: widget.accentColor,
          isPlaying: widget.isPlaying,
          showBurst:
          widget.showParticleBurst || _burstCtrl.isAnimating,
        ),
      ),
    );
  }
}

class _BreathingPainter extends CustomPainter {
  final double breathScale, particleT, burstT;
  final Color color;
  final bool isPlaying, showBurst;

  _BreathingPainter({
    required this.breathScale,
    required this.particleT,
    required this.burstT,
    required this.color,
    required this.isPlaying,
    required this.showBurst,
  });

  static final _rng = math.Random(7);

  static final List<_P> _ambient = List.generate(20,
          (i) => _P(
        angle: _rng.nextDouble() * 2 * math.pi,
        dist: 0.18 + _rng.nextDouble() * 0.28,
        r: 1.2 + _rng.nextDouble() * 2.2,
        speed: 0.2 + _rng.nextDouble() * 0.5,
        phase: _rng.nextDouble(),
      ));

  static final List<_P> _burst = List.generate(30,
          (i) => _P(
        angle: i / 30 * 2 * math.pi + _rng.nextDouble() * 0.3,
        dist: 0.1 + _rng.nextDouble() * 0.45,
        r: 1.5 + _rng.nextDouble() * 3.0,
        speed: 0.6 + _rng.nextDouble() * 0.8,
        phase: _rng.nextDouble() * 0.3,
      ));

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.45;  // center of figure area
    final baseR = size.width * 0.32;  // bigger glow ring

    // Breathing rings + ambient particles — only when session playing
    if (isPlaying) {
      for (int i = 0; i < 3; i++) {
        final r = baseR * (breathScale - i * 0.08) * (1 + i * 0.22);
        final alpha = ((0.18 - i * 0.05) * 255).toInt().clamp(0, 255);
        canvas.drawCircle(Offset(cx, cy), r,
            Paint()
              ..color = color.withAlpha(alpha)
              ..style = PaintingStyle.fill
              ..maskFilter =
              const MaskFilter.blur(BlurStyle.normal, 18));
      }
      canvas.drawCircle(Offset(cx, cy), baseR * breathScale,
          Paint()
            ..color = color.withAlpha(64)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);

      for (final p in _ambient) {
        final prog = (particleT * p.speed + p.phase) % 1.0;
        final dist = (p.dist + prog * 0.15) * size.width * 0.85;  // spread wider
        final angle = p.angle + prog * math.pi * 0.4;
        canvas.drawCircle(
          Offset(cx + math.cos(angle) * dist,
              cy + math.sin(angle) * dist * 0.6),
          p.r,
          Paint()
            ..color = color.withAlpha(
                (math.sin(prog * math.pi) * 160).toInt().clamp(0, 255)),
        );
      }
    }

    // Burst on tap — works even before session starts
    if (showBurst && burstT > 0) {
      for (final p in _burst) {
        final prog = (burstT * p.speed).clamp(0.0, 1.0);
        final dist = p.dist * size.width * 0.7 * prog;
        canvas.drawCircle(
          Offset(cx + math.cos(p.angle) * dist,
              cy + math.sin(p.angle) * dist * 0.8),
          p.r * (1 - prog * 0.5),
          Paint()
            ..color = color.withAlpha(
                ((1.0 - prog) * 220).toInt().clamp(0, 255)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BreathingPainter o) => true;
}

class _P {
  final double angle, dist, r, speed, phase;
  _P({required this.angle, required this.dist, required this.r,
    required this.speed, required this.phase});
}

