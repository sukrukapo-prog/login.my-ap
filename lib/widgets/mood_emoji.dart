import 'package:flutter/material.dart';

class MoodEmoji extends StatefulWidget {
  final String emoji;
  final Color moodColor;
  final VoidCallback? onTap;

  const MoodEmoji({
    super.key,
    required this.emoji,
    required this.moodColor,
    this.onTap,
  });

  @override
  State<MoodEmoji> createState() => _MoodEmojiState();
}

class _MoodEmojiState extends State<MoodEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) widget.onTap!();
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 38,               // smaller than typical 48–56
          height: 38,
          decoration: BoxDecoration(
            color: widget.moodColor.withOpacity(0.18), // subtle psychological bg
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.moodColor.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.emoji,
            style: const TextStyle(fontSize: 26), // slightly smaller emoji
          ),
        ),
      ),
    );
  }
} 