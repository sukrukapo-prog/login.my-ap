import 'package:flutter/material.dart';

/// Vertical volume slider that pops up when volume icon is tapped.
class MovementVolumeSlider extends StatelessWidget {
  final double volume; // 0.0 to 1.0
  final Color accentColor;
  final ValueChanged<double> onChanged;
  final bool visible;

  const MovementVolumeSlider({
    super.key,
    required this.volume,
    required this.accentColor,
    required this.onChanged,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: IgnorePointer(
        ignoring: !visible,
        child: Container(
          width: 44,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E).withAlpha(240),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withAlpha(30)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withAlpha(40),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                volume == 0
                    ? Icons.volume_off
                    : volume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
                color: accentColor,
                size: 16,
              ),
              const SizedBox(height: 6),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: accentColor,
                      inactiveTrackColor: Colors.white.withAlpha(30),
                      thumbColor: Colors.white,
                      overlayColor: accentColor.withAlpha(40),
                    ),
                    child: Slider(
                      value: volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(volume * 100).round()}',
                style: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
