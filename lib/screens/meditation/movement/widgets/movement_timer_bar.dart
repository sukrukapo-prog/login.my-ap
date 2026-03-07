import 'package:flutter/material.dart';

/// Animated timer bar shown at bottom of movement player.
/// Shows remaining time as a shrinking progress bar + countdown text.
/// Also has +5 / -5 minute adjustment buttons.
class MovementTimerBar extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final Color accentColor;
  final bool isPlaying;
  final VoidCallback onAdjustMinus;
  final VoidCallback onAdjustPlus;

  const MovementTimerBar({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.accentColor,
    required this.isPlaying,
    required this.onAdjustMinus,
    required this.onAdjustPlus,
  });

  double get _progress =>
      totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

  String _format(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(200),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time display row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minus button
              _AdjustButton(
                label: '-5',
                onTap: onAdjustMinus,
                color: accentColor,
              ),

              // Time remaining
              Column(
                children: [
                  Text(
                    _format(remainingSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'remaining',
                    style: TextStyle(
                      color: Colors.white.withAlpha(120),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Plus button
              _AdjustButton(
                label: '+5',
                onTap: onAdjustPlus,
                color: accentColor,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Background track
                Container(
                  height: 6,
                  width: double.infinity,
                  color: Colors.white.withAlpha(30),
                ),
                // Animated fill
                AnimatedFractionallySizedBox(
                  duration: const Duration(seconds: 1),
                  curve: Curves.linear,
                  widthFactor: _progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withAlpha(180),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Total time label
          Text(
            '${(totalSeconds ~/ 60)} min session',
            style: TextStyle(
              color: Colors.white.withAlpha(80),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _AdjustButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(80), width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
