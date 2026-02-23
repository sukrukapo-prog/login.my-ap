import 'package:flutter/material.dart';

class BackNextButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool isNextEnabled;
  final String nextText;

  const BackNextButtons({
    super.key,
    this.onBack,
    required this.onNext,
    this.isNextEnabled = true,
    this.nextText = 'Next',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
            color: Colors.white70,
            onPressed: onBack ?? () => Navigator.pop(context),
          ),

          // Next button
          SizedBox(
            width: 160,
            height: 56,
            child: ElevatedButton(
              onPressed: isNextEnabled ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                nextText,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}