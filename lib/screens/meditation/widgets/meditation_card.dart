import 'package:flutter/material.dart';

class MeditationCard extends StatefulWidget {
  final String title;
  final String instructor;          // now using user's name (from onboarding)
  final String subtitle;
  final String buttonText;
  final Color buttonColor;
  final String imagePath;
  final VoidCallback onStartPressed;
  final bool isFeatured;            // optional – show badge
  final String? avatarImagePath;    // optional – real instructor/user photo

  const MeditationCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.subtitle,
    required this.buttonText,
    required this.buttonColor,
    required this.imagePath,
    required this.onStartPressed,
    this.isFeatured = false,
    this.avatarImagePath,
  });

  @override
  State<MeditationCard> createState() => _MeditationCardState();
}

class _MeditationCardState extends State<MeditationCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onStartPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          height: 200,  // taller for better look
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(widget.imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.58), // stronger for readability
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Instructor + title + subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF3B82F6).withOpacity(0.5),
                              backgroundImage: widget.avatarImagePath != null
                                  ? AssetImage(widget.avatarImagePath!)
                                  : null,
                              child: widget.avatarImagePath == null
                                  ? Text(
                                widget.instructor.isNotEmpty
                                    ? widget.instructor[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.instructor,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.subtitle,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Start button – SMALLER VERSION
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: widget.onStartPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.buttonColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(110, 38),           // ← smaller base size
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), // reduced padding
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontSize: 15,                             // slightly smaller text
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(widget.buttonText),
                      ),
                    ),
                  ],
                ),
              ),

              // Featured badge (top-right corner)
              if (widget.isFeatured)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Featured",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}