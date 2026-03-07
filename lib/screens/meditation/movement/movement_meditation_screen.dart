import 'package:flutter/material.dart';
import 'package:fitmetrics/core/audio_service.dart';
import 'package:fitmetrics/screens/meditation/movement/movement_session_model.dart';
import 'package:fitmetrics/screens/meditation/movement/movement_player_screen.dart';
import 'package:fitmetrics/screens/meditation/movement/widgets/movement_card.dart';

class MovementMeditationScreen extends StatefulWidget {
  const MovementMeditationScreen({super.key});

  @override
  State<MovementMeditationScreen> createState() =>
      _MovementMeditationScreenState();
}

class _MovementMeditationScreenState extends State<MovementMeditationScreen>
    with SingleTickerProviderStateMixin {

  int? _expandedIndex;

  late AnimationController _listAnim;
  late List<Animation<Offset>> _slides;
  late List<Animation<double>>  _fades;

  @override
  void initState() {
    super.initState();
    AudioService().pauseMusic();

    final count = movementSessions.length;
    _listAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + count * 80),
    );

    _slides = List.generate(count, (i) {
      final start = (i * 0.09).clamp(0.0, 0.8);
      final end   = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _listAnim,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    _fades = List.generate(count, (i) {
      final start = (i * 0.09).clamp(0.0, 0.8);
      final end   = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _listAnim,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    _listAnim.forward();
  }

  @override
  void dispose() {
    AudioService().resumeMusic();
    _listAnim.dispose();
    super.dispose();
  }

  void _onStart(MovementSession session) {
    AudioService().playClickSound();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) =>
            MovementPlayerScreen(session: session),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      AudioService().playClickSound();
                      // Reverse animation on exit
                      _listAnim.reverse().then((_) {
                        if (mounted) Navigator.pop(context);
                      });
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF22C55E).withAlpha(80)),
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: Color(0xFF22C55E), size: 26),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Movement Meditation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Awaken Your Body & Mind',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Animated card list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                itemCount: movementSessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final session = movementSessions[index];
                  return SlideTransition(
                    position: _slides[index],
                    child: FadeTransition(
                      opacity: _fades[index],
                      child: MovementCard(
                        session: session,
                        isExpanded: _expandedIndex == index,
                        onTap: () => setState(() {
                          _expandedIndex =
                          _expandedIndex == index ? null : index;
                        }),
                        onStart: () => _onStart(session),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
