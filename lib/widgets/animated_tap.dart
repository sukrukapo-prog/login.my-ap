import 'package:flutter/material.dart';
import 'package:fitmetrics/core/audio_service.dart';

/// Wrap any widget to get scale animation + click sound on tap
class AnimatedTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool playSound;
  final double scaleDown;

  const AnimatedTap({
    super.key,
    required this.child,
    this.onTap,
    this.playSound = true,
    this.scaleDown = 0.95,
  });

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    if (widget.playSound) AudioService().playClickSound();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}