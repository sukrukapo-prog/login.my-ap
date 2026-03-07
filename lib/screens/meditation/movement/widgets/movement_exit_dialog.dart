import 'package:flutter/material.dart';

/// "Are you sure you want to leave?" dialog for movement player.
/// Returns true if user confirmed exit, false if they want to stay.
class MovementExitDialog extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onStay;
  final VoidCallback onExit;

  const MovementExitDialog({
    super.key,
    required this.accentColor,
    required this.onStay,
    required this.onExit,
  });

  static Future<bool> show(
      BuildContext context, {
        required Color accentColor,
        required VoidCallback onStay,
        required VoidCallback onExit,
      }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(180),
      builder: (_) => MovementExitDialog(
        accentColor: accentColor,
        onStay: onStay,
        onExit: onExit,
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      title: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_run,
              color: accentColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Leave Session?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        'Your meditation time will be saved.\nAre you sure you want to stop?',
        style: TextStyle(
          color: Colors.white.withAlpha(150),
          fontSize: 14,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      actions: [
        Row(
          children: [
            // Stay button
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onStay();
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withAlpha(25)),
                  ),
                  child: const Center(
                    child: Text(
                      'Keep Going',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Exit button
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onExit();
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Yes, Leave',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
