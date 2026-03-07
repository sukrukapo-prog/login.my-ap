import 'dart:math' as math;
import 'package:flutter/material.dart';

class MovementWaveAnimation extends StatefulWidget {
  final Color color;
  final double height;
  final bool isPlaying;

  const MovementWaveAnimation({
    super.key,
    required this.color,
    required this.isPlaying,
    this.height = 36,
  });

  @override
  State<MovementWaveAnimation> createState() => _MovementWaveAnimationState();
}

class _MovementWaveAnimationState extends State<MovementWaveAnimation>
    with TickerProviderStateMixin {
  late AnimationController _c1, _c2, _c3;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
    _c2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    _c3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
  }

  @override
  void dispose() {
    _c1.dispose(); _c2.dispose(); _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_c1, _c2, _c3]),
      builder: (_, __) => SizedBox(
        height: widget.height,
        child: CustomPaint(
          painter: _WavePainter(
            p1: _c1.value * 2 * math.pi,
            p2: _c2.value * 2 * math.pi,
            p3: _c3.value * 2 * math.pi,
            color: widget.color,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double p1, p2, p3;
  final Color color;
  _WavePainter({required this.p1, required this.p2, required this.p3, required this.color});

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
    _draw(canvas, size, p1, size.height * 0.35, 2.0, color.withAlpha(55));
    _draw(canvas, size, p2, size.height * 0.25, 2.5, color.withAlpha(40));
    _draw(canvas, size, p3, size.height * 0.18, 3.0, color.withAlpha(28));
  }

  @override
  bool shouldRepaint(_WavePainter old) => true;
}
