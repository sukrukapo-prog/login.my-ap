// lib/screens/meditation/widgets/meditation_card.dart
// FIXED: pixel overflow on small screens.
// Root cause: fixed height (190) + all(22) padding + two-line title + button
// Fix: use IntrinsicHeight / let content drive height, add minHeight constraint.

import 'package:flutter/material.dart';

class MeditationCard extends StatefulWidget {
  final String title;
  final String instructor;
  final String subtitle;
  final String buttonText;
  final Color buttonColor;
  final String imagePath;
  final VoidCallback onStartPressed;
  final bool isFeatured;
  final String? avatarImagePath;
  final Color usernameColor;

  const MeditationCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.subtitle,
    required this.buttonText,
    required this.buttonColor,
    required this.imagePath,
    required this.onStartPressed,
    required this.usernameColor,
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
    // Screen-adaptive padding: tighter on small screens
    final screenH = MediaQuery.of(context).size.height;
    final cardPad = screenH < 700 ? 16.0 : 20.0;
    final titleFs = screenH < 700 ? 19.0 : 22.0;

    return GestureDetector(
      onTapDown:  (_) => setState(() => _scale = 0.97),
      onTapUp:    (_) => setState(() => _scale = 1.0),
      onTapCancel:()  => setState(() => _scale = 1.0),
      onTap: widget.onStartPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          // ── KEY FIX: remove fixed height, use constraints instead ──────
          constraints: const BoxConstraints(minHeight: 160),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(widget.imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withAlpha(140),
                BlendMode.darken,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Content — drives the card's height
                Padding(
                  padding: EdgeInsets.all(cardPad),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // ← shrink-wrap
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructor name
                      Text(
                        widget.instructor,
                        style: TextStyle(
                          color: widget.usernameColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Title — ellipsis after 2 lines
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFs,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Subtitle
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // ── Spacing before button ────────────────────────────
                      SizedBox(height: screenH < 700 ? 12 : 18),
                      // Start button — right-aligned
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: widget.onStartPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.buttonColor,
                            foregroundColor: Colors.white,
                            // ── KEY FIX: use fixed size not minimumSize ──
                            fixedSize: const Size(110, 40),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(widget.buttonText),
                        ),
                      ),
                    ],
                  ),
                ),

                // Featured badge
                if (widget.isFeatured)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(230),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Featured',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          )),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
