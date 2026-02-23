import 'package:flutter/material.dart';

class ProgressDots extends StatelessWidget {
  final int current;
  final int total;

  const ProgressDots({
    super.key,
    required this.current,
    required this.total = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        bool isActive = i < current;
        bool isCurrent = i == current - 1;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFF3B82F6)
                : isCurrent
                ? const Color(0xFF3B82F6).withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
          ),
        );
      }),
    );
  }
}