import 'package:flutter/material.dart';
import 'package:fitmetrics/services/local_storage.dart';

/// Shows today's meditation minutes + current streak on the home screen.
/// Call MeditationStreakCard.load() to get data, then pass to widget.
class MeditationStreakCard extends StatelessWidget {
  final int minutesToday;
  final int streakDays;
  final VoidCallback onTap;

  const MeditationStreakCard({
    super.key,
    required this.minutesToday,
    required this.streakDays,
    required this.onTap,
  });

  /// Loads both minutesToday and streakDays from LocalStorage.
  static Future<Map<String, int>> load() async {
    final today = DateTime.now();
    final minutesToday = await LocalStorage.getMeditationMinutes(today);

    // Calculate streak — count back consecutive days with > 0 minutes
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = today.subtract(Duration(days: i));
      final mins = await LocalStorage.getMeditationMinutes(day);
      if (mins > 0) {
        streak++;
      } else if (i > 0) {
        // Allow today to be 0 without breaking streak
        break;
      }
    }

    return {'minutes': minutesToday, 'streak': streak};
  }

  @override
  Widget build(BuildContext context) {
    final hasActivity = minutesToday > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: hasActivity
                ? [const Color(0xFF1A3A4A), const Color(0xFF0F2030)]
                : [const Color(0xFF1A1F2E), const Color(0xFF0F1320)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: hasActivity
                ? const Color(0xFF3B82F6).withAlpha(80)
                : Colors.white.withAlpha(15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.self_improvement,
                color: Color(0xFF3B82F6),
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            // Minutes + label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    minutesToday > 0
                        ? '$minutesToday min today'
                        : 'No session yet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Meditation',
                    style: TextStyle(
                      color: Colors.white.withAlpha(100),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Streak badge
            if (streakDays > 0)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withAlpha(80),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      '$streakDays',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
