import 'dart:math' as math;
import 'package:flutter/material.dart';

class MovementCircularTimer extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final Color accentColor;
  final double size;

  const MovementCircularTimer({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.accentColor,
    this.size = 100,
  });

  double get _progress =>
      totalSeconds > 0 ? remainingSeconds / totalSeconds : 1.0;

  String _format(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(
              progress: _progress,
              accentColor: accentColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _format(remainingSeconds),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Session Time',
                style: TextStyle(
                  color: Colors.white.withAlpha(110),
                  fontSize: size * 0.09,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  _ArcPainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const sw = 6.0;

    // Track
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = Colors.white.withAlpha(20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );

    if (progress > 0) {
      // Arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );

      // Glowing leading dot
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 5,
          Paint()
            ..color = accentColor
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      canvas.drawCircle(Offset(dx, dy), 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.accentColor != accentColor;
}
