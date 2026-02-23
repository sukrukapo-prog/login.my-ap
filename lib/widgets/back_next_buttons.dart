import 'package:flutter/material.dart';

class BackNextButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool isNextEnabled;

  const BackNextButtons({
    super.key,
    this.onBack,
    required this.onNext,
    this.isNextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: onBack ?? () => Navigator.pop(context),
        ),
        const Spacer(),
        SizedBox(
          width: 140,
          height: 56,
          child: ElevatedButton(
            onPressed: isNextEnabled ? onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Next', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}