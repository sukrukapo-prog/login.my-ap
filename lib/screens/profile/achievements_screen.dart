import 'package:flutter/material.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/services/firestore_service.dart';
import 'package:fitmetrics/core/haptic_service.dart';

// ── Achievement model ──────────────────────────────────────────────────────────
class Achievement {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final String category;
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
  const Achievement(id: 'first_login', emoji: '🎉', title: 'Welcome!',
      description: 'Open FitMetrics for the first time', category: 'session',
      requiredValue: 0, color: Color(0xFF10B981)),
  const Achievement(id: 'first_session', emoji: '🌱', title: 'First Step',
      description: 'Complete your first meditation session', category: 'session',
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
  // ── Streak achievements ───────────────────────────────────────────────────
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
  // ── Time achievements ─────────────────────────────────────────────────────
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
  // ── Workout achievements ──────────────────────────────────────────────────
  const Achievement(id: 'first_workout', emoji: '🏋️', title: 'First Lift',
      description: 'Complete your first workout', category: 'workout',
      requiredValue: 1, color: Color(0xFF3B82F6)),
  const Achievement(id: 'workouts_5', emoji: '💥', title: 'Getting Fit',
      description: 'Complete 5 workouts', category: 'workout',
      requiredValue: 5, color: Color(0xFFFF6B35)),
  const Achievement(id: 'workouts_10', emoji: '🦾', title: 'Workout Warrior',
      description: 'Complete 10 workouts', category: 'workout',
      requiredValue: 10, color: Color(0xFFEF4444)),
  const Achievement(id: 'workouts_25', emoji: '🥇', title: 'Iron Will',
      description: 'Complete 25 workouts', category: 'workout',
      requiredValue: 25, color: Color(0xFFFFD700)),
  const Achievement(id: 'workouts_50', emoji: '🏅', title: 'Gym Legend',
      description: 'Complete 50 workouts', category: 'workout',
      requiredValue: 50, color: Color(0xFF10B981)),
  // ── Zen / time-of-day ─────────────────────────────────────────────────────
  const Achievement(id: 'time_30min', emoji: '🌅', title: 'Zen Beginner',
      description: 'Meditate for 30 minutes total', category: 'time',
      requiredValue: 30, color: Color(0xFF06B6D4)),
];

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  Map<String, int> _stats = {};
  bool _isLoading = true;
  String _filter = 'All';
  late AnimationController _animCtrl;
  final _filters = ['All', 'Sessions', 'Streaks', 'Time', 'Workouts'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _loadStats();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  Future<void> _loadStats() async {
    final stats = await LocalStorage.getAllTimeStats();
    // Merge Firestore workout count (more accurate than local)
    final workoutCount = await FirestoreService.getTotalWorkoutCount();
    final merged = {
      ...stats,
      'totalWorkouts': workoutCount > (stats['totalWorkouts'] ?? 0)
          ? workoutCount
          : (stats['totalWorkouts'] ?? 0),
    };
    setState(() { _stats = merged; _isLoading = false; });
    _animCtrl.forward(from: 0);
  }

  bool _isUnlocked(Achievement a) {
    final sessions = _stats['totalSessions'] ?? 0;
    final streak   = _stats['streakDays']    ?? 0;
    final minutes  = _stats['totalMinutes']  ?? 0;
    final workouts = _stats['totalWorkouts'] ?? 0;

    switch (a.category) {
      case 'app':     return true; // first_login is always unlocked once you're in
      case 'session': return sessions >= a.requiredValue;
      case 'streak':  return streak   >= a.requiredValue;
      case 'time':    return minutes  >= a.requiredValue;
      case 'workout': return workouts >= a.requiredValue;
      default:        return false;
    }
  }

  double _progress(Achievement a) {
    final sessions = _stats['totalSessions'] ?? 0;
    final streak   = _stats['streakDays']    ?? 0;
    final minutes  = _stats['totalMinutes']  ?? 0;
    final workouts = _stats['totalWorkouts'] ?? 0;
    if (a.requiredValue == 0 || a.category == 'app') return 1.0;
    int current;
    switch (a.category) {
      case 'session': current = sessions; break;
      case 'streak':  current = streak;   break;
      case 'time':    current = minutes;  break;
      case 'workout': current = workouts; break;
      default:        current = 0;
    }
    return (current / a.requiredValue).clamp(0.0, 1.0);
  }

  String _progressLabel(Achievement a) {
    final sessions = _stats['totalSessions'] ?? 0;
    final streak   = _stats['streakDays']    ?? 0;
    final minutes  = _stats['totalMinutes']  ?? 0;
    final workouts = _stats['totalWorkouts'] ?? 0;
    switch (a.category) {
      case 'app':     return 'Unlocked ✓';
      case 'session': return '$sessions / ${a.requiredValue} sessions';
      case 'streak':  return '$streak / ${a.requiredValue} days';
      case 'time':    return '$minutes / ${a.requiredValue} minutes';
      case 'workout': return '$workouts / ${a.requiredValue} workouts';
      default:        return '';
    }
  }

  List<Achievement> get _filtered {
    List<Achievement> list;
    if (_filter == 'Sessions')  list = allAchievements.where((a) => a.category == 'session').toList();
    else if (_filter == 'Streaks')  list = allAchievements.where((a) => a.category == 'streak').toList();
    else if (_filter == 'Time')     list = allAchievements.where((a) => a.category == 'time').toList();
    else if (_filter == 'Workouts') list = allAchievements.where((a) => a.category == 'workout').toList();
    else list = allAchievements.toList();
    list.sort((a, b) {
      final au = _isUnlocked(a) ? 0 : 1;
      final bu = _isUnlocked(b) ? 0 : 1;
      return au.compareTo(bu);
    });
    return list;
  }

  int get _unlockedCount => allAchievements.where(_isUnlocked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () { HapticService.light(); Navigator.pop(context); },
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha(30))),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Achievements',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
              if (!_isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFD700).withAlpha(60))),
                  child: Text('$_unlockedCount / ${allAchievements.length}',
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w700)),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Overall Progress', style: TextStyle(color: Colors.white.withAlpha(130), fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('${((_unlockedCount / allAchievements.length) * 100).round()}%',
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                        value: _unlockedCount / allAchievements.length,
                        minHeight: 6,
                        backgroundColor: Colors.white.withAlpha(15),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)))),
              ]),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 34,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _filters.map((f) {
                  final sel = f == _filter;
                  return GestureDetector(
                    onTap: () { HapticService.selection(); setState(() => _filter = f); _animCtrl.forward(from: 0); },
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            color: sel ? const Color(0xFF3B82F6) : Colors.white.withAlpha(12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: sel ? const Color(0xFF3B82F6) : Colors.white.withAlpha(20))),
                        child: Center(child: Text(f,
                            style: TextStyle(color: sel ? Colors.white : Colors.white54,
                                fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.normal)))),
                  );
                }).toList()),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                : GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.95),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final a = _filtered[i];
                  final unlocked = _isUnlocked(a);
                  final prog     = _progress(a);
                  return AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (_, child) {
                      final delay = (i * 0.04).clamp(0.0, 0.8);
                      final t = ((_animCtrl.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                      return Opacity(opacity: t,
                          child: Transform.translate(offset: Offset(0, 20 * (1 - t)), child: child));
                    },
                    child: GestureDetector(
                        onTap: () {
                          HapticService.light();
                          if (unlocked) {
                            _showUnlockedDetail(context, a);
                          } else {
                            _showLockedDetail(context, a, prog);
                          }
                        },
                        child: _AchievementCard(achievement: a, unlocked: unlocked, progress: prog)),
                  );
                }),
          ),
        ]),
      ),
    );
  }

  void _showUnlockedDetail(BuildContext context, Achievement a) {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1A2540),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        builder: (_) => _UnlockedDetailSheet(achievement: a));
  }

  void _showLockedDetail(BuildContext context, Achievement a, double prog) {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1A2540),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        builder: (_) => _LockedDetailSheet(achievement: a, progress: prog, progressLabel: _progressLabel(a)));
  }
}

// ── Unlocked sheet ─────────────────────────────────────────────────────────────
class _UnlockedDetailSheet extends StatefulWidget {
  final Achievement achievement;
  const _UnlockedDetailSheet({required this.achievement});
  @override
  State<_UnlockedDetailSheet> createState() => _UnlockedDetailSheetState();
}

class _UnlockedDetailSheetState extends State<_UnlockedDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim, _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 24),
        ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: a.color.withAlpha(30),
                border: Border.all(color: a.color.withAlpha(80), width: 2),
                boxShadow: [BoxShadow(color: a.color.withAlpha(60), blurRadius: 24, spreadRadius: 4)]),
            child: Center(child: Text(a.emoji, style: const TextStyle(fontSize: 46))),
          ),
        ),
        const SizedBox(height: 20),
        FadeTransition(
          opacity: _fadeAnim,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981).withAlpha(80))),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.lock_open_rounded, color: Color(0xFF10B981), size: 14),
                SizedBox(width: 6),
                Text('Achievement Unlocked',
                    style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 14),
            Text(a.title, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(a.description, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 15, height: 1.5)),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Progress', style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12)),
              Text('100% Complete', style: TextStyle(color: a.color, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: 1.0, minHeight: 8,
                    backgroundColor: Colors.white.withAlpha(15),
                    valueColor: AlwaysStoppedAnimation<Color>(a.color))),
          ]),
        ),
        const SizedBox(height: 4),
      ]),
    );
  }
}

// ── Locked sheet ───────────────────────────────────────────────────────────────
class _LockedDetailSheet extends StatelessWidget {
  final Achievement achievement;
  final double progress;
  final String progressLabel;
  const _LockedDetailSheet({required this.achievement, required this.progress, required this.progressLabel});

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 24),
        Stack(alignment: Alignment.center, children: [
          Container(width: 100, height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(8),
                  border: Border.all(color: Colors.white.withAlpha(20))),
              child: Center(child: Text(a.emoji, style: TextStyle(fontSize: 46, color: Colors.white.withAlpha(40))))),
          Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withAlpha(100))),
          const Icon(Icons.lock_rounded, color: Colors.white54, size: 32),
        ]),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: Colors.white.withAlpha(10), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(25))),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.lock_rounded, color: Colors.white38, size: 14),
            SizedBox(width: 6),
            Text('Locked', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: 14),
        Text(a.title, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(a.description, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 14, height: 1.5)),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Progress to unlock', style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12)),
          Text('${(progress * 100).round()}%', style: TextStyle(color: a.color, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: progress, minHeight: 8,
                backgroundColor: Colors.white.withAlpha(15),
                valueColor: AlwaysStoppedAnimation<Color>(a.color))),
        const SizedBox(height: 8),
        Text(progressLabel, style: TextStyle(color: Colors.white.withAlpha(80), fontSize: 12)),
        const SizedBox(height: 4),
      ]),
    );
  }
}

// ── Card ───────────────────────────────────────────────────────────────────────
class _AchievementCard extends StatefulWidget {
  final Achievement achievement;
  final bool unlocked;
  final double progress;
  const _AchievementCard({required this.achievement, required this.unlocked, required this.progress});
  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _flipAnim;
  late Animation<double> _progressAnim;
  bool _wasUnlocked = false;

  @override
  void initState() {
    super.initState();
    _wasUnlocked = widget.unlocked;
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _flipAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _progressAnim = CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic));
    // Small delay so grid entrance finishes first
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void didUpdateWidget(_AchievementCard old) {
    super.didUpdateWidget(old);
    // Flip animation when newly unlocked
    if (!_wasUnlocked && widget.unlocked) {
      _wasUnlocked = true;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final unlocked = widget.unlocked;
    final progress = widget.progress;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        // Flip: first half shows locked face, second half shows unlocked
        final flip = _flipAnim.value;
        final showFront = flip < 0.5;
        final rotateY = unlocked
            ? (flip < 0.5 ? flip * 3.14159 : (flip - 0.5) * 3.14159)
            : 0.0;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(unlocked && _wasUnlocked ? 0 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: unlocked ? a.color.withAlpha(25) : Colors.white.withAlpha(6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: unlocked ? a.color.withAlpha(80) : Colors.white.withAlpha(15),
                    width: unlocked ? 1.5 : 1),
                boxShadow: unlocked
                    ? [BoxShadow(color: a.color.withAlpha(40), blurRadius: 12, spreadRadius: 1)]
                    : []),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                unlocked
                    ? Text(a.emoji, style: const TextStyle(fontSize: 32))
                    : Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withAlpha(8), shape: BoxShape.circle),
                    child: const Icon(Icons.lock_rounded, color: Colors.white24, size: 20)),
                if (unlocked)
                  ScaleTransition(
                    scale: _flipAnim,
                    child: Container(
                        width: 22, height: 22,
                        decoration: const BoxDecoration(
                            color: Color(0xFF10B981), shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 13)),
                  ),
              ]),
              const Spacer(),
              Text(unlocked ? a.title : '???',
                  style: TextStyle(
                      color: unlocked ? Colors.white : Colors.white24,
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(unlocked ? a.description : 'Keep going to unlock',
                  style: TextStyle(
                      color: unlocked ? Colors.white38 : Colors.white12,
                      fontSize: 10),
                  maxLines: 2),
              const SizedBox(height: 8),
              // Progress bar animates from 0 to actual value on load
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress * _progressAnim.value,
                  minHeight: 4,
                  backgroundColor: Colors.white.withAlpha(15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      unlocked ? a.color : Colors.white.withAlpha(40)),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}