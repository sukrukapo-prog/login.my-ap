import 'package:flutter/material.dart';

// ── Model ──────────────────────────────────────────────────────────────────────
class LeaderboardEntry {
  final int rank;
  final String username;
  final String avatarPath;
  final int meditationMinutes;
  final int movementMinutes;
  final int workoutMinutes;
  final int streakDays;
  final int exercisesDone;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.avatarPath,
    required this.meditationMinutes,
    required this.movementMinutes,
    required this.workoutMinutes,
    required this.streakDays,
    required this.exercisesDone,
    this.isCurrentUser = false,
  });

  int get totalMinutes => meditationMinutes + movementMinutes + workoutMinutes;
  int get totalScore   => totalMinutes + (streakDays * 10) + (exercisesDone * 5);
}

// ── Dummy data sets ────────────────────────────────────────────────────────────
final _allTime = <LeaderboardEntry>[
  LeaderboardEntry(rank: 1, username: 'ZenMaster', avatarPath: 'assets/images/avatars/avatar_1.png', meditationMinutes: 320, movementMinutes: 180, workoutMinutes: 210, streakDays: 14, exercisesDone: 0),
  LeaderboardEntry(rank: 2, username: 'MindfulSoul', avatarPath: 'assets/images/avatars/avatar_2.png', meditationMinutes: 280, movementMinutes: 200, workoutMinutes: 160, streakDays: 10, exercisesDone: 0),
  LeaderboardEntry(rank: 3, username: 'FlowState', avatarPath: 'assets/images/avatars/avatar_3.png', meditationMinutes: 240, movementMinutes: 190, workoutMinutes: 140, streakDays: 8, exercisesDone: 0),
  LeaderboardEntry(rank: 4, username: 'You', avatarPath: 'assets/images/avatars/avatar_4.png', meditationMinutes: 180, movementMinutes: 120, workoutMinutes: 90, streakDays: 5, exercisesDone: 0, isCurrentUser: true),
  LeaderboardEntry(rank: 5, username: 'CalmVibes', avatarPath: 'assets/images/avatars/avatar_5.png', meditationMinutes: 160, movementMinutes: 100, workoutMinutes: 80, streakDays: 4, exercisesDone: 0),
  LeaderboardEntry(rank: 6, username: 'BreathWork', avatarPath: 'assets/images/avatars/avatar_6.png', meditationMinutes: 140, movementMinutes: 90, workoutMinutes: 60, streakDays: 3, exercisesDone: 0),
  LeaderboardEntry(rank: 7, username: 'PeacefulOne', avatarPath: 'assets/images/avatars/avatar_7.png', meditationMinutes: 120, movementMinutes: 80, workoutMinutes: 50, streakDays: 2, exercisesDone: 0),
  LeaderboardEntry(rank: 8, username: 'InnerPeace', avatarPath: 'assets/images/avatars/avatar_8.png', meditationMinutes: 100, movementMinutes: 60, workoutMinutes: 40, streakDays: 1, exercisesDone: 0),
];

final _thisWeek = <LeaderboardEntry>[
  LeaderboardEntry(rank: 1, username: 'FlowState', avatarPath: 'assets/images/avatars/avatar_3.png', meditationMinutes: 90, movementMinutes: 60, workoutMinutes: 50, streakDays: 8, exercisesDone: 0),
  LeaderboardEntry(rank: 2, username: 'You', avatarPath: 'assets/images/avatars/avatar_4.png', meditationMinutes: 80, movementMinutes: 50, workoutMinutes: 40, streakDays: 5, exercisesDone: 0, isCurrentUser: true),
  LeaderboardEntry(rank: 3, username: 'ZenMaster', avatarPath: 'assets/images/avatars/avatar_1.png', meditationMinutes: 70, movementMinutes: 45, workoutMinutes: 35, streakDays: 14, exercisesDone: 0),
  LeaderboardEntry(rank: 4, username: 'CalmVibes', avatarPath: 'assets/images/avatars/avatar_5.png', meditationMinutes: 60, movementMinutes: 40, workoutMinutes: 30, streakDays: 4, exercisesDone: 0),
  LeaderboardEntry(rank: 5, username: 'MindfulSoul', avatarPath: 'assets/images/avatars/avatar_2.png', meditationMinutes: 50, movementMinutes: 30, workoutMinutes: 20, streakDays: 10, exercisesDone: 0),
];

final _today = <LeaderboardEntry>[
  LeaderboardEntry(rank: 1, username: 'You', avatarPath: 'assets/images/avatars/avatar_4.png', meditationMinutes: 30, movementMinutes: 20, workoutMinutes: 15, streakDays: 5, exercisesDone: 0, isCurrentUser: true),
  LeaderboardEntry(rank: 2, username: 'BreathWork', avatarPath: 'assets/images/avatars/avatar_6.png', meditationMinutes: 25, movementMinutes: 15, workoutMinutes: 10, streakDays: 3, exercisesDone: 0),
  LeaderboardEntry(rank: 3, username: 'PeacefulOne', avatarPath: 'assets/images/avatars/avatar_7.png', meditationMinutes: 20, movementMinutes: 10, workoutMinutes: 5, streakDays: 2, exercisesDone: 0),
  LeaderboardEntry(rank: 4, username: 'InnerPeace', avatarPath: 'assets/images/avatars/avatar_8.png', meditationMinutes: 15, movementMinutes: 10, workoutMinutes: 5, streakDays: 1, exercisesDone: 0),
];

// ── Screen ─────────────────────────────────────────────────────────────────────
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  int _filterIndex = 2; // default All Time
  final _filters = ['Today', 'This Week', 'All Time'];

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  List<LeaderboardEntry> get _entries {
    switch (_filterIndex) {
      case 0: return _today;
      case 1: return _thisWeek;
      default: return _allTime;
    }
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  void _switchFilter(int i) {
    setState(() => _filterIndex = i);
    _fadeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final top3   = _entries.take(3).toList();
    final rest   = _entries.skip(3).toList();
    final myRank = _entries.firstWhere((e) => e.isCurrentUser, orElse: () => _entries.first).rank;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [

            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Leaderboard',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      Text('Your rank: #$myRank',
                          style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 26),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Filter tabs ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: List.generate(_filters.length, (i) {
                    final sel = i == _filterIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _switchFilter(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF3B82F6) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Text(_filters[i],
                                style: TextStyle(
                                  color: sel ? Colors.white : Colors.white54,
                                  fontSize: 13,
                                  fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                                )),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── List ─────────────────────────────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [

                      // Podium
                      if (top3.length == 3) _Podium(entries: top3),

                      const SizedBox(height: 16),

                      // Rest of list
                      ...rest.map((e) => _LeaderRow(entry: e)),
                    ],
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

// ── Podium ─────────────────────────────────────────────────────────────────────
class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  const _Podium({required this.entries});

  @override
  Widget build(BuildContext context) {
    // Order: 2nd, 1st, 3rd
    final ordered = [entries[1], entries[0], entries[2]];
    final heights = [90.0, 110.0, 75.0];
    final medals  = ['🥈', '🥇', '🥉'];
    final colors  = [
      const Color(0xFFC0C0C0),
      const Color(0xFFFFD700),
      const Color(0xFFCD7F32),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A2540), const Color(0xFF0F1624)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        children: [
          // Avatars row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (i) {
              final e = ordered[i];
              final isFirst = i == 1;
              return Expanded(
                child: Column(
                  children: [
                    Text(medals[i], style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors[i], width: 2.5),
                        boxShadow: [BoxShadow(color: colors[i].withAlpha(80), blurRadius: 10, spreadRadius: 1)],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          e.avatarPath,
                          width: isFirst ? 64 : 52,
                          height: isFirst ? 64 : 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: isFirst ? 64 : 52,
                            height: isFirst ? 64 : 52,
                            color: colors[i].withAlpha(40),
                            child: Icon(Icons.person, color: colors[i], size: isFirst ? 32 : 26),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(e.username,
                        style: TextStyle(
                          color: e.isCurrentUser ? const Color(0xFF3B82F6) : Colors.white,
                          fontSize: 12, fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${e.totalScore} pts',
                        style: TextStyle(color: colors[i], fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    // Podium block
                    Container(
                      height: heights[i],
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors[i].withAlpha(80), colors[i].withAlpha(30)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        border: Border.all(color: colors[i].withAlpha(60)),
                      ),
                      child: Center(
                        child: Text('#${e.rank}',
                            style: TextStyle(color: colors[i], fontSize: 18, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          // Stats legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip(icon: Icons.self_improvement, label: 'Meditation', color: const Color(0xFF8B5CF6)),
              _StatChip(icon: Icons.directions_walk, label: 'Movement', color: const Color(0xFF3B82F6)),
              _StatChip(icon: Icons.fitness_center, label: 'Workout', color: const Color(0xFF10B981)),
              _StatChip(icon: Icons.local_fire_department, label: 'Streak', color: const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Leaderboard row ────────────────────────────────────────────────────────────
class _LeaderRow extends StatelessWidget {
  final LeaderboardEntry entry;
  const _LeaderRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isMe = entry.isCurrentUser;
    final accent = isMe ? const Color(0xFF3B82F6) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF3B82F6).withAlpha(20) : Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? const Color(0xFF3B82F6).withAlpha(80) : Colors.white.withAlpha(15),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rank
              SizedBox(
                width: 28,
                child: Text('#${entry.rank}',
                    style: TextStyle(
                      color: isMe ? const Color(0xFF3B82F6) : Colors.white54,
                      fontSize: 13, fontWeight: FontWeight.w800,
                    )),
              ),
              const SizedBox(width: 8),
              // Avatar
              ClipOval(
                child: Image.asset(
                  entry.avatarPath,
                  width: 38, height: 38, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 38, height: 38,
                    color: Colors.white.withAlpha(20),
                    child: Icon(Icons.person, color: accent, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Name + streak
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.username,
                        style: TextStyle(
                          color: isMe ? const Color(0xFF3B82F6) : Colors.white,
                          fontSize: 14, fontWeight: FontWeight.w700,
                        )),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Color(0xFFF59E0B), size: 12),
                        const SizedBox(width: 2),
                        Text('${entry.streakDays} day streak',
                            style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              // Total score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${entry.totalScore}',
                      style: TextStyle(
                        color: isMe ? const Color(0xFF3B82F6) : Colors.white,
                        fontSize: 16, fontWeight: FontWeight.w900,
                      )),
                  const Text('pts', style: TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Stats bar
          Row(
            children: [
              _MiniStat(icon: Icons.self_improvement, value: '${entry.meditationMinutes}m', color: const Color(0xFF8B5CF6)),
              _MiniStat(icon: Icons.directions_walk, value: '${entry.movementMinutes}m', color: const Color(0xFF3B82F6)),
              _MiniStat(icon: Icons.fitness_center, value: '${entry.workoutMinutes}m', color: const Color(0xFF10B981)),
              _MiniStat(icon: Icons.sports_gymnastics, value: '${entry.exercisesDone}', color: const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _MiniStat({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 3),
          Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
