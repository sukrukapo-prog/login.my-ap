import 'package:flutter/material.dart';

class EnhancedYellowLine extends StatelessWidget {
  const EnhancedYellowLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4, // thicker & more prominent
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.amber.shade300,
            Colors.orange.shade400,
            Colors.amber.shade300,
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}