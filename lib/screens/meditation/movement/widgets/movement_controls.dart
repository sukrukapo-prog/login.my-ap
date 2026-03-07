import 'package:flutter/material.dart';

/// Bottom controls for movement player.
/// Contains the big play/pause button and the time selector chips.
class MovementControls extends StatelessWidget {
  final bool isPlaying;
  final bool sessionStarted;
  final Color accentColor;
  final VoidCallback onPlayPause;
  final List<int> timeOptions;
  final int selectedMinutes;
  final bool showTimePicker;
  final VoidCallback onToggleTimePicker;
  final Function(int) onSelectTime;

  const MovementControls({
    super.key,
    required this.isPlaying,
    required this.sessionStarted,
    required this.accentColor,
    required this.onPlayPause,
    required this.timeOptions,
    required this.selectedMinutes,
    required this.showTimePicker,
    required this.onToggleTimePicker,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time picker chips — only show before session starts
        if (!sessionStarted) ...[
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: showTimePicker
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: timeOptions.map((min) {
                  final isSelected = selectedMinutes == min;
                  return GestureDetector(
                    onTap: () => onSelectTime(min),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor
                            : Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? accentColor
                              : Colors.white.withAlpha(30),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${min}m',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Duration selector row
          GestureDetector(
            onTap: onToggleTimePicker,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withAlpha(25), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined,
                      color: accentColor, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    '${selectedMinutes} min session',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    showTimePicker
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white38,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],

        // Big play/pause button
        GestureDetector(
          onTap: onPlayPause,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withAlpha(100),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          isPlaying
              ? 'Tap to pause'
              : sessionStarted
              ? 'Tap to resume'
              : 'Tap to start',
          style: TextStyle(
            color: Colors.white.withAlpha(100),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
