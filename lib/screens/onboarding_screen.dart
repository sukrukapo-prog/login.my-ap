import 'package:flutter/material.dart';
import 'package:fitmetrics/routes.dart';
import 'package:fitmetrics/services/local_storage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      icon: Icons.self_improvement,
      color: const Color(0xFF8B5CF6),
      title: 'Meditate Daily',
      subtitle: 'Choose from 7 guided movement sessions and 6 calming music meditations. Track your streak and grow every day.',
      features: ['🧘 Movement Meditation', '🎵 Music Meditation', '🔥 Daily Streaks'],
    ),
    _OnboardPage(
      icon: Icons.fitness_center,
      color: const Color(0xFF3B82F6),
      title: 'Track Workouts',
      subtitle: 'Log your exercises, track calories burned and see your fitness progress over time.',
      features: ['💪 Exercise Logging', '🔥 Calories Burned', '📈 Progress Tracking'],
    ),
    _OnboardPage(
      icon: Icons.emoji_events,
      color: const Color(0xFFF59E0B),
      title: 'Compete & Win',
      subtitle: 'See how you rank against others on the leaderboard. Earn badges and complete weekly challenges.',
      features: ['🏆 Leaderboard', '🏅 Achievements', '👥 Weekly Challenges'],
    ),
    _OnboardPage(
      icon: Icons.restaurant_menu,
      color: const Color(0xFF10B981),
      title: 'Eat Smart',
      subtitle: 'Track your meals, monitor macros and balance your nutrition to reach your fitness goals faster.',
      features: ['🍎 Meal Logging', '📊 Macro Tracking', '⚖️ Calorie Balance'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    await LocalStorage.setSeenOnboarding();
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [

            // Skip button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Row(
                    children: List.generate(_pages.length, (i) =>
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? page.color
                                : Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
                  ),
                  if (!isLast)
                    GestureDetector(
                      onTap: _skip,
                      child: Text('Skip',
                          style: TextStyle(
                              color: Colors.white.withAlpha(130),
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  _fadeCtrl.forward(from: 0);
                },
                itemBuilder: (_, i) => _OnboardingPage(
                  page: _pages[i],
                  fadeAnim: _fadeAnim,
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
              child: GestureDetector(
                onTap: _next,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [page.color, page.color.withAlpha(200)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: page.color.withAlpha(100),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLast ? 'Get Started' : 'Next',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLast ? Icons.rocket_launch : Icons.arrow_forward,
                          color: Colors.white, size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single page ────────────────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _OnboardPage page;
  final Animation<double> fadeAnim;
  const _OnboardingPage({required this.page, required this.fadeAnim});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Icon circle with glow
            Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.color.withAlpha(60),
                    page.color.withAlpha(15),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page.color.withAlpha(30),
                    border: Border.all(color: page.color.withAlpha(80), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: page.color.withAlpha(80),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(page.icon, color: page.color, size: 44),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Title
            Text(page.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center),

            const SizedBox(height: 14),

            // Subtitle
            Text(page.subtitle,
                style: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontSize: 15,
                  height: 1.6,
                ),
                textAlign: TextAlign.center),

            const SizedBox(height: 32),

            // Feature chips
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: page.features.map((f) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: page.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: page.color.withAlpha(60)),
                ),
                child: Text(f,
                    style: TextStyle(
                      color: page.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final List<String> features;
  const _OnboardPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.features,
  });
}
