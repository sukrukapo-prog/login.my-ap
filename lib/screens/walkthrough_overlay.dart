import 'package:flutter/material.dart';
import 'package:fitmetrics/services/local_storage.dart';

// ── Step model ─────────────────────────────────────────────────────────────────
class _WalkthroughStep {
  final int tabIndex;       // which bottom nav tab to highlight
  final String emoji;
  final String title;
  final String description;
  final String tapHint;

  const _WalkthroughStep({
    required this.tabIndex,
    required this.emoji,
    required this.title,
    required this.description,
    required this.tapHint,
  });
}

const _steps = [
  _WalkthroughStep(
    tabIndex: 0,
    emoji: '🏠',
    title: 'Home',
    description: 'Your daily dashboard. See calories, quick access to all features and your leaderboard rank at a glance.',
    tapHint: 'Tap anywhere to continue',
  ),
  _WalkthroughStep(
    tabIndex: 2,
    emoji: '🧘',
    title: 'Meditation',
    description: 'Choose from 7 movement sessions and 6 music meditations. Build your daily streak and earn points.',
    tapHint: 'Tap anywhere to continue',
  ),
  _WalkthroughStep(
    tabIndex: 1,
    emoji: '💪',
    title: 'Workout',
    description: 'Log your exercises, track reps and sets. See calories burned and build your fitness routine.',
    tapHint: 'Tap anywhere to continue',
  ),
  _WalkthroughStep(
    tabIndex: 3,
    emoji: '🍎',
    title: 'Food & Diet',
    description: 'Log your meals, track macros and balance your nutrition to hit your daily calorie goals.',
    tapHint: 'Tap anywhere to continue',
  ),
  _WalkthroughStep(
    tabIndex: 4,
    emoji: '👤',
    title: 'Profile',
    description: 'Update your stats, change your avatar, view notifications and track your all-time achievements.',
    tapHint: 'Tap to finish tour',
  ),
];

// ── Walkthrough overlay widget ─────────────────────────────────────────────────
class WalkthroughOverlay extends StatefulWidget {
  final VoidCallback onDone;
  final Function(int) onTabHighlight;

  const WalkthroughOverlay({
    super.key,
    required this.onDone,
    required this.onTabHighlight,
  });

  @override
  State<WalkthroughOverlay> createState() => _WalkthroughOverlayState();
}

class _WalkthroughOverlayState extends State<WalkthroughOverlay>
    with TickerProviderStateMixin {

  int _stepIndex = 0;

  late AnimationController _cardCtrl;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  late AnimationController _arrowCtrl;
  late Animation<double> _arrow;

  @override
  void initState() {
    super.initState();

    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
        begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _arrowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _arrow = Tween<double>(begin: 0, end: 10)
        .animate(CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut));

    _cardCtrl.forward();
    // Highlight first tab after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onTabHighlight(_steps[0].tabIndex);
    });
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _pulseCtrl.dispose();
    _arrowCtrl.dispose();
    super.dispose();
  }

  void _next() async {
    if (_stepIndex < _steps.length - 1) {
      await _cardCtrl.reverse();
      setState(() => _stepIndex++);
      widget.onTabHighlight(_steps[_stepIndex].tabIndex);
      _cardCtrl.forward(from: 0);
    } else {
      await _cardCtrl.reverse();
      await LocalStorage.setSeenWalkthrough();
      widget.onDone();
    }
  }

  void _skip() async {
    await LocalStorage.setSeenWalkthrough();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_stepIndex];
    final isLast = _stepIndex == _steps.length - 1;
    final size = MediaQuery.of(context).size;

    // Calculate which tab position to highlight (5 tabs evenly spaced)
    final tabWidth = size.width / 5;
    final tabCenterX = tabWidth * step.tabIndex + tabWidth / 2;

    return GestureDetector(
      onTap: _next,
      child: Stack(
        fit: StackFit.expand,
        children: [

          // Dark overlay
          Container(color: Colors.black.withAlpha(160)),

          // Highlight circle around the tab icon
          Positioned(
            bottom: 22,
            left: tabCenterX - 28,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Transform.scale(
                scale: _pulse.value,
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(25),
                    border: Border.all(
                      color: const Color(0xFF3B82F6),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withAlpha(120),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bouncing arrow pointing down to tab
          Positioned(
            bottom: 88,
            left: tabCenterX - 12,
            child: AnimatedBuilder(
              animation: _arrow,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _arrow.value),
                child: Column(
                  children: [
                    Icon(Icons.keyboard_arrow_down,
                        color: const Color(0xFF3B82F6), size: 28),
                    Icon(Icons.keyboard_arrow_down,
                        color: const Color(0xFF3B82F6).withAlpha(120), size: 22),
                  ],
                ),
              ),
            ),
          ),

          // Info card
          Positioned(
            bottom: 140,
            left: 20, right: 20,
            child: SlideTransition(
              position: _cardSlide,
              child: FadeTransition(
                opacity: _cardFade,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2540),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFF3B82F6).withAlpha(80)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(100),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Step counter + skip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(_steps.length, (i) =>
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 5),
                                  width: i == _stepIndex ? 20 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: i == _stepIndex
                                        ? const Color(0xFF3B82F6)
                                        : Colors.white.withAlpha(40),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                )),
                          ),
                          GestureDetector(
                            onTap: _skip,
                            child: Text('Skip tour',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(100),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Emoji + title
                      Row(
                        children: [
                          Text(step.emoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Text(step.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              )),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Description
                      Text(step.description,
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 14,
                            height: 1.55,
                          )),

                      const SizedBox(height: 18),

                      // Tap hint + next button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(step.tapHint,
                              style: TextStyle(
                                color: Colors.white.withAlpha(80),
                                fontSize: 12,
                              )),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isLast ? 'Done! 🚀' : 'Next',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (!isLast) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward,
                                      color: Colors.white, size: 14),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
