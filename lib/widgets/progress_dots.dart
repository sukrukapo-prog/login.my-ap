import 'package:flutter/material.dart';

class ProgressDots extends StatelessWidget {
  final int current;
  final int total;

  const ProgressDots({
    super.key,
    required this.current,
    this.total = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i < current;
        final isCurrent = i == current - 1;

        Color dotColor;
        if (isActive) {
          dotColor = const Color(0xFF3B82F6); // completed
        } else if (isCurrent) {
          dotColor = const Color(0xFF3B82F6).withAlpha(128); // current (50% opacity)
        } else {
          dotColor = Colors.white.withAlpha(51); // inactive (~20% opacity)
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            border: Border.all(
              color: isActive || isCurrent
                  ? const Color(0xFF3B82F6)
                  : Colors.white.withAlpha(40),
              width: 1.5,
            ),
            boxShadow: isCurrent
                ? [
              BoxShadow(
                color: const Color(0xFF3B82F6).withAlpha(100),
                blurRadius: 6,
                spreadRadius: 1,
              )
            ]
                : null,
          ),
        );
      }),
    );
  }
}