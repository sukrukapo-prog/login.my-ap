import 'package:flutter/material.dart';
import 'package:fitmetrics/routes.dart';
import 'package:fitmetrics/core/audio_service.dart';
import 'package:fitmetrics/services/auth_service.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/services/firestore_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    // Single main controller — logo fades in, text slides up together
    _mainCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _mainCtrl,
            curve: const Interval(0.0, 0.7, curve: Curves.easeIn)));

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _mainCtrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeIn)));

    _textSlide = Tween<Offset>(
        begin: const Offset(0, 0.25), end: Offset.zero).animate(
        CurvedAnimation(parent: _mainCtrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    // Subtle pulse glow — starts after main anim
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mainCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    await AudioService().init();
    final isLoggedIn = await AuthService.isLoggedIn();
    final hasSeenOnboarding = await LocalStorage.hasSeenOnboarding();
    if (!mounted) return;

    if (isLoggedIn) {
      // Push latest score to leaderboard so user appears even without new activity
      FirestoreService.updateLeaderboardScore();
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else if (!hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        fit: StackFit.expand,
        children: [

          // Pulsing glow
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Center(
              child: Container(
                width: 260 * _pulse.value,
                height: 260 * _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF3B82F6).withAlpha(30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Logo — simple fade in, no scale bounce
                FadeTransition(
                  opacity: _logoFade,
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withAlpha(80),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 110, height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Center(
                            child: Text('F', style: TextStyle(
                              color: Colors.white, fontSize: 52,
                              fontWeight: FontWeight.w900,
                            )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Text slides up
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        const Text('FitMetrics',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            )),
                        const SizedBox(height: 6),
                        Text('Your wellness journey starts here',
                            style: TextStyle(
                              color: Colors.white.withAlpha(130),
                              fontSize: 14,
                              letterSpacing: 0.3,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading dots at bottom
          Positioned(
            bottom: 56,
            left: 0, right: 0,
            child: FadeTransition(
              opacity: _textFade,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) {
                    final delay = i * 0.33;
                    final val = ((_pulseCtrl.value - delay).abs() % 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3B82F6)
                            .withAlpha((val * 255).toInt().clamp(60, 255)),
                      ),
                    );
                  },
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}