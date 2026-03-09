import 'package:flutter/material.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/core/haptic_service.dart';

// ── Achievement model ──────────────────────────────────────────────────────────
class Achievement {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final String category; // 'meditation' | 'streak' | 'session' | 'time'
  final int requiredValue;
  final Color color;

  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.category,
    required this.requiredValue,
    required this.color,
  });
}

final List<Achievement> allAchievements = [
  // Welcome
  const Achievement(id: 'first_login', emoji: '🎉', title: 'Welcome!',
      description: 'Open FitMetrics for the first time', category: 'session',
      requiredValue: 0, color: Color(0xFF10B981)),

  // Sessions
  const Achievement(id: 'first_session', emoji: '🌱', title: 'First Step',
      description: 'Complete your first session', category: 'session',
      requiredValue: 1, color: Color(0xFF10B981)),
  const Achievement(id: 'sessions_5', emoji: '⭐', title: 'Getting Started',
      description: 'Complete 5 sessions', category: 'session',
      requiredValue: 5, color: Color(0xFF3B82F6)),
  const Achievement(id: 'sessions_10', emoji: '🌟', title: 'Dedicated',
      description: 'Complete 10 sessions', category: 'session',
      requiredValue: 10, color: Color(0xFF8B5CF6)),
  const Achievement(id: 'sessions_25', emoji: '💫', title: 'Committed',
      description: 'Complete 25 sessions', category: 'session',
      requiredValue: 25, color: Color(0xFFF59E0B)),
  const Achievement(id: 'sessions_50', emoji: '🏆', title: 'Champion',
      description: 'Complete 50 sessions', category: 'session',
      requiredValue: 50, color: Color(0xFFFFD700)),
  const Achievement(id: 'sessions_100', emoji: '👑', title: 'Legend',
      description: 'Complete 100 sessions', category: 'session',
      requiredValue: 100, color: Color(0xFFFF6B6B)),

  // Streaks
  const Achievement(id: 'streak_3', emoji: '🔥', title: 'On Fire',
      description: '3 day streak', category: 'streak',
      requiredValue: 3, color: Color(0xFFF59E0B)),
  const Achievement(id: 'streak_7', emoji: '🗓️', title: 'Week Warrior',
      description: '7 day streak', category: 'streak',
      requiredValue: 7, color: Color(0xFFFF6B35)),
  const Achievement(id: 'streak_14', emoji: '💪', title: 'Fortnight Force',
      description: '14 day streak', category: 'streak',
      requiredValue: 14, color: Color(0xFFEF4444)),
  const Achievement(id: 'streak_30', emoji: '🌙', title: 'Month Master',
      description: '30 day streak', category: 'streak',
      requiredValue: 30, color: Color(0xFF8B5CF6)),
  const Achievement(id: 'streak_100', emoji: '⚡', title: 'Unstoppable',
      description: '100 day streak', category: 'streak',
      requiredValue: 100, color: Color(0xFF06B6D4)),

  // Total minutes
  const Achievement(id: 'time_60', emoji: '⏰', title: 'Hour In',
      description: 'Meditate for 60 minutes total', category: 'time',
      requiredValue: 60, color: Color(0xFF10B981)),
  const Achievement(id: 'time_300', emoji: '🧘', title: 'Calm Seeker',
      description: 'Meditate for 5 hours total', category: 'time',
      requiredValue: 300, color: Color(0xFF3B82F6)),
  const Achievement(id: 'time_600', emoji: '🌊', title: 'Deep Diver',
      description: 'Meditate for 10 hours total', category: 'time',
      requiredValue: 600, color: Color(0xFF8B5CF6)),
  const Achievement(id: 'time_1800', emoji: '🌈', title: 'Zen Master',
      description: 'Meditate for 30 hours total', category: 'time',
      requiredValue: 1800, color: Color(0xFFFFD700)),
];

// ── Screen ─────────────────────────────────────────────────────────────────────
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  Map<String, int> _stats = {};
  bool _firstLogin = false;
  bool _isLoading = true;
  String _filter = 'All';
  late AnimationController _animCtrl;

  final _filters = ['All', 'Sessions', 'Streaks', 'Time'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _loadStats();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final stats = await LocalStorage.getAllTimeStats();
    final alreadyOpened = !(await LocalStorage.isFirstLogin());
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
    _animCtrl.forward(from: 0);
  }

  bool _isUnlocked(Achievement a) {
    final sessions = _stats['totalSessions'] ?? 0;
    final streak = _stats['streakDays'] ?? 0;
    final minutes = _stats['totalMinutes'] ?? 0;

    switch (a.category) {
      case 'session': return a.id == 'first_login' ? _firstLogin : sessions >= a.requiredValue;
      case 'streak':  return streak  >= a.requiredValue;
      case 'time':    return minutes >= a.requiredValue;
      default:        return false;
    }
  }

  double _progress(Achievement a) {
    final sessions = _stats['totalSessions'] ?? 0;
    final streak = _stats['streakDays'] ?? 0;
    final minutes = _stats['totalMinutes'] ?? 0;

    int current;
    switch (a.category) {
      case 'session': current = sessions; break;
      case 'streak':  current = streak;   break;
      case 'time':    current = minutes;  break;
      default:        current = 0;
    }
    return (current / a.requiredValue).clamp(0.0, 1.0);
  }

  List<Achievement> get _filtered {
    if (_filter == 'All') return allAchievements;
    if (_filter == 'Sessions') return allAchievements.where((a) => a.category == 'session').toList();
    if (_filter == 'Streaks')  return allAchievements.where((a) => a.category == 'streak').toList();
    if (_filter == 'Time')     return allAchievements.where((a) => a.category == 'time').toList();
    return allAchievements;
  }

  int get _unlockedCount => allAchievements.where(_isUnlocked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () { HapticService.light(); Navigator.pop(context); },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('Achievements',
                        style: TextStyle(color: Colors.white, fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ),
                  if (!_isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFD700).withAlpha(60)),
                      ),
                      child: Text('$_unlockedCount / ${allAchievements.length}',
                          style: const TextStyle(
                              color: Color(0xFFFFD700), fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Overall progress bar
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Overall Progress',
                            style: TextStyle(color: Colors.white.withAlpha(130),
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('${((_unlockedCount / allAchievements.length) * 100).round()}%',
                            style: const TextStyle(color: Color(0xFFFFD700),
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _unlockedCount / allAchievements.length,
                        minHeight: 6,
                        backgroundColor: Colors.white.withAlpha(15),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Filter tabs
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _filters.map((f) {
                  final sel = f == _filter;
                  return GestureDetector(
                    onTap: () {
                      HapticService.selection();
                      setState(() => _filter = f);
                      _animCtrl.forward(from: 0);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFF3B82F6) : Colors.white.withAlpha(12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? const Color(0xFF3B82F6) : Colors.white.withAlpha(20),
                        ),
                      ),
                      child: Center(
                        child: Text(f,
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.white54,
                              fontSize: 12,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Achievement grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(
                  color: Color(0xFF3B82F6)))
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final a = _filtered[i];
                  final unlocked = _isUnlocked(a);
                  final prog = _progress(a);
                  return AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (_, child) {
                      final delay = (i * 0.05).clamp(0.0, 0.8);
                      final t = (((_animCtrl.value - delay) / (1 - delay))
                          .clamp(0.0, 1.0));
                      return Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - t)),
                          child: child,
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        HapticService.light();
                        _showDetail(context, a, unlocked, prog);
                      },
                      child: _AchievementCard(
                        achievement: a,
                        unlocked: unlocked,
                        progress: prog,
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

  void _showDetail(BuildContext context, Achievement a, bool unlocked, double prog) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2540),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(a.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(a.title,
                style: const TextStyle(color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(a.description,
                style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 20),
            if (!unlocked) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: prog,
                  minHeight: 8,
                  backgroundColor: Colors.white.withAlpha(15),
                  valueColor: AlwaysStoppedAnimation<Color>(a.color),
                ),
              ),
              const SizedBox(height: 8),
              Text('${(prog * 100).round()}% complete',
                  style: TextStyle(color: a.color, fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ] else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 6),
                    Text('Unlocked!',
                        style: TextStyle(color: Color(0xFF10B981),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  final double progress;

  const _AchievementCard({
    required this.achievement,
    required this.unlocked,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked
            ? a.color.withAlpha(25)
            : Colors.white.withAlpha(6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked ? a.color.withAlpha(80) : Colors.white.withAlpha(15),
          width: unlocked ? 1.5 : 1,
        ),
        boxShadow: unlocked
            ? [BoxShadow(color: a.color.withAlpha(40), blurRadius: 12, spreadRadius: 1)]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(unlocked ? a.emoji : '🔒',
                  style: TextStyle(
                      fontSize: 32,
                      color: unlocked ? null : Colors.white.withAlpha(60))),
              if (unlocked)
                Container(
                  width: 22, height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 13),
                ),
            ],
          ),
          const Spacer(),
          Text(a.title,
              style: TextStyle(
                color: unlocked ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 3),
          Text(a.description,
              style: TextStyle(
                  color: unlocked ? Colors.white38 : Colors.white24,
                  fontSize: 10),
              maxLines: 2),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.white.withAlpha(15),
              valueColor: AlwaysStoppedAnimation<Color>(
                  unlocked ? a.color : Colors.white.withAlpha(60)),
            ),
          ),
        ],
      ),
    );
  }
}
