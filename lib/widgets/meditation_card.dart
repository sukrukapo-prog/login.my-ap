import 'package:flutter/material.dart';
import 'mood_emoji.dart';           // adjust path if needed
import 'enhanced_yellow_line.dart';  // adjust path if needed

class MeditationCard extends StatelessWidget {
  final String type;        // 'movement' or 'music'
  final String userName;    // e.g. "YT"
  final VoidCallback? onStart;

  const MeditationCard({
    super.key,
    required this.type,
    required this.userName,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isMovement = type.toLowerCase().contains('movement');
    final emoji = isMovement ? '🏃‍♂️' : '🎶';
    final moodColor = isMovement ? Colors.teal : Colors.deepPurple;
    final cardBg = isMovement ? Colors.teal.shade50 : Colors.deepPurple.shade50;

    final title = isMovement ? 'Movement Meditation' : 'Music Meditation';
    final startText = 'Start $userName $title';

    return SizedBox(
      width: 168,     // compact – two cards fit nicely on most phones
      height: 148,    // smaller overall card
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardBg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      "$userName's $title",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  MoodEmoji(
                    emoji: emoji,
                    moodColor: moodColor,
                    onTap: onStart,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                startText,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const EnhancedYellowLine(),
            ],
          ),
        ),
      ),
    );
  }
}