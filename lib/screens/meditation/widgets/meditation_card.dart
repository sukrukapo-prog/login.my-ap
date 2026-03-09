import 'package:flutter/material.dart';

class MeditationCard extends StatefulWidget {
  final String title;
  final String instructor; // kept for compatibility but no longer shown
  final String subtitle;
  final String buttonText;
  final Color buttonColor;
  final String imagePath;
  final VoidCallback onStartPressed;
  final bool isFeatured;
  final String? avatarImagePath; // kept for compatibility

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
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onStartPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          height: 190,
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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title + subtitle only — no guide/avatar row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    // Start button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: widget.onStartPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.buttonColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 38),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
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
                  top: 16, right: 16,
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
    );
  }
}
