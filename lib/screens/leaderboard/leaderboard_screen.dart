import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmetrics/core/avatar_data.dart';
import 'package:fitmetrics/core/haptic_service.dart';
import 'package:fitmetrics/screens/profile/achievements_screen.dart' show allAchievements;

// ── Model ──────────────────────────────────────────────────────────────────────
class LeaderboardEntry {
  final String uid;
  final String username;
  final String? avatarId;
  final int totalMinutes;
  final int streakDays;
  final int totalSessions;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.uid,
    required this.username,
    this.avatarId,
    required this.totalMinutes,
    required this.streakDays,
    required this.totalSessions,
    required this.isCurrentUser,
  });

  int get totalScore => totalMinutes + (streakDays * 10) + (totalSessions * 2);
}

// ── Screen ─────────────────────────────────────────────────────────────────────
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  final _db    = FirebaseFirestore.instance;
  final _myUid = FirebaseAuth.instance.currentUser?.uid;

  int _filterIndex = 2;
  final _filters = ['Today', 'This Week', 'All Time'];
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;
  String? _error;

  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _load();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Load leaderboard data ──────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final usersSnap = await _db.collection('users').get();
      final entries   = <LeaderboardEntry>[];

      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final uid  = doc.id;
        int minutes = 0;
        int streak  = 0;
        int sessions = 0;

        try {
          if (_filterIndex == 0) {
            // Today
            final medDoc = await _db.collection('users').doc(uid)
                .collection('meditation').doc(_dateKey(DateTime.now())).get();
            minutes = (medDoc.data()?['minutes'] as int?) ?? 0;
          } else if (_filterIndex == 1) {
            // This week
            final now = DateTime.now();
            for (int i = 0; i < 7; i++) {
              final medDoc = await _db.collection('users').doc(uid)
                  .collection('meditation')
                  .doc(_dateKey(now.subtract(Duration(days: i)))).get();
              minutes += (medDoc.data()?['minutes'] as int?) ?? 0;
            }
          } else {
            // All time
            final statsDoc = await _db.collection('users').doc(uid)
                .collection('stats').doc('summary').get();
            minutes  = (statsDoc.data()?['totalMinutes']  as int?) ?? 0;
            sessions = (statsDoc.data()?['totalSessions'] as int?) ?? 0;
            streak   = await _calcStreak(uid);
          }
        } catch (e) {
          developer.log('[Leaderboard] fetch error $uid: $e');
        }

        entries.add(LeaderboardEntry(
          uid: uid,
          username: (data['name'] as String?)?.isNotEmpty == true
              ? data['name'] as String
              : (data['email'] as String?)?.split('@').first ?? 'User',
          avatarId:     data['avatarId'] as String?,
          totalMinutes: minutes,
          streakDays:   streak,
          totalSessions: sessions,
          isCurrentUser: uid == _myUid,
        ));
      }

      entries.sort((a, b) => b.totalScore.compareTo(a.totalScore));

      if (mounted) {
        setState(() { _entries = entries; _isLoading = false; });
        _fadeCtrl.forward(from: 0);
      }
    } catch (e) {
      developer.log('[Leaderboard] load error: $e');
      if (mounted) setState(() { _error = 'Could not load leaderboard.'; _isLoading = false; });
    }
  }

  Future<int> _calcStreak(String uid) async {
    try {
      final snap = await _db.collection('users').doc(uid)
          .collection('meditation')
          .orderBy('date', descending: true)
          .limit(60).get();
      final dates = <String>{};
      for (final d in snap.docs) {
        if (((d.data()['minutes'] as int?) ?? 0) > 0) dates.add(d.id);
      }
      int streak = 0;
      final today = DateTime.now();
      for (int i = 0; i < 60; i++) {
        if (dates.contains(_dateKey(today.subtract(Duration(days: i))))) {
          streak++;
        } else if (i > 0) break;
      }
      return streak;
    } catch (_) { return 0; }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int? get _myRank {
    for (int i = 0; i < _entries.length; i++) {
      if (_entries[i].isCurrentUser) return i + 1;
    }
    return null;
  }

  // ── User profile sheet ─────────────────────────────────────────────────────
  void _showUserProfile(BuildContext context, LeaderboardEntry entry, int rank) {
    HapticService.light();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2540),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _UserProfileSheet(
        entry: entry,
        rank: rank,
        db: _db,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top3   = _entries.take(3).toList();
    final rest   = _entries.skip(3).toList();
    final myRank = _myRank;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(children: [

          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () { HapticService.light(); Navigator.pop(context); },
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha(30))),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Leaderboard',
                  style: TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.w800))),
              if (myRank != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF3B82F6).withAlpha(60))),
                  child: Text('You #$myRank',
                      style: const TextStyle(color: Color(0xFF3B82F6),
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _load,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.refresh, color: Colors.white54, size: 18),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Filter tabs ──────────────────────────────────────────────────
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final sel = i == _filterIndex;
                return GestureDetector(
                  onTap: () {
                    HapticService.selection();
                    setState(() => _filterIndex = i);
                    _load();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: sel ? const Color(0xFF3B82F6) : Colors.white.withAlpha(12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: sel ? const Color(0xFF3B82F6) : Colors.white.withAlpha(20))),
                    child: Center(child: Text(_filters[i],
                        style: TextStyle(
                            color: sel ? Colors.white : Colors.white54,
                            fontSize: 12,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.normal))),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                : _error != null
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 48),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 16),
              TextButton(onPressed: _load,
                  child: const Text('Retry',
                      style: TextStyle(color: Color(0xFF3B82F6)))),
            ]))
                : _entries.isEmpty
                ? const Center(child: Text('No users yet',
                style: TextStyle(color: Colors.white38)))
                : FadeTransition(
              opacity: _fadeCtrl,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: [
                  if (top3.isNotEmpty)
                    _Podium(
                      entries: top3,
                      onTap: (entry, rank) =>
                          _showUserProfile(context, entry, rank),
                    ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  ...rest.asMap().entries.map((e) => _LeaderRow(
                    entry: e.value,
                    rank: e.key + 4,
                    onTap: () => _showUserProfile(
                        context, e.value, e.key + 4),
                  )),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Podium ─────────────────────────────────────────────────────────────────────
class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final void Function(LeaderboardEntry, int) onTap;
  const _Podium({required this.entries, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors  = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final heights = [110.0, 80.0, 60.0];
    final order   = entries.length == 1 ? [0]
        : entries.length == 2 ? [1, 0]
        : [1, 0, 2];

    return SizedBox(
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: order.map((i) {
          if (i >= entries.length) return const SizedBox(width: 100);
          final e       = entries[i];
          final isFirst = i == 0;
          final rank    = i + 1;
          return GestureDetector(
            onTap: () => onTap(e, rank),
            child: SizedBox(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isFirst) Text('👑', style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.all(isFirst ? 3 : 2),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors[i], width: isFirst ? 3 : 2)),
                    child: AvatarWidget(
                        avatarId: e.avatarId, size: isFirst ? 62 : 50),
                  ),
                  const SizedBox(height: 6),
                  Text(e.username,
                      style: TextStyle(
                          color: e.isCurrentUser
                              ? const Color(0xFF3B82F6)
                              : Colors.white,
                          fontSize: 11, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  Text('${e.totalScore} pts',
                      style: TextStyle(
                          color: colors[i],
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Container(
                    height: heights[i],
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [colors[i].withAlpha(80), colors[i].withAlpha(30)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                        borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                        border: Border.all(color: colors[i].withAlpha(60))),
                    child: Center(
                        child: Text('#$rank',
                            style: TextStyle(
                                color: colors[i],
                                fontSize: 18,
                                fontWeight: FontWeight.w900))),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── List row ───────────────────────────────────────────────────────────────────
class _LeaderRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final VoidCallback onTap;
  const _LeaderRow({required this.entry, required this.rank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMe = entry.isCurrentUser;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: isMe
                ? const Color(0xFF3B82F6).withAlpha(20)
                : Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isMe
                    ? const Color(0xFF3B82F6).withAlpha(80)
                    : Colors.white.withAlpha(15))),
        child: Row(children: [
          SizedBox(
              width: 28,
              child: Text('#$rank',
                  style: TextStyle(
                      color: isMe ? const Color(0xFF3B82F6) : Colors.white54,
                      fontSize: 13, fontWeight: FontWeight.w800))),
          const SizedBox(width: 8),
          AvatarWidget(avatarId: entry.avatarId, size: 40),
          const SizedBox(width: 10),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.username,
                    style: TextStyle(
                        color: isMe ? const Color(0xFF3B82F6) : Colors.white,
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.local_fire_department,
                      color: Color(0xFFF59E0B), size: 12),
                  const SizedBox(width: 2),
                  Text('${entry.streakDays}d streak',
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(width: 10),
                  const Icon(Icons.self_improvement,
                      color: Color(0xFF8B5CF6), size: 12),
                  const SizedBox(width: 2),
                  Text('${entry.totalMinutes}m',
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(width: 10),
                  const Icon(Icons.check_circle_outline,
                      color: Color(0xFF10B981), size: 12),
                  const SizedBox(width: 2),
                  Text('${entry.totalSessions} sessions',
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ]),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${entry.totalScore}',
                style: TextStyle(
                    color: isMe ? const Color(0xFF3B82F6) : Colors.white,
                    fontSize: 16, fontWeight: FontWeight.w900)),
            const Text('pts',
                style: TextStyle(color: Colors.white38, fontSize: 10)),
          ]),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
        ]),
      ),
    );
  }
}

// ── User profile bottom sheet ──────────────────────────────────────────────────
class _UserProfileSheet extends StatefulWidget {
  final LeaderboardEntry entry;
  final int rank;
  final FirebaseFirestore db;
  const _UserProfileSheet({
    required this.entry,
    required this.rank,
    required this.db,
  });

  @override
  State<_UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends State<_UserProfileSheet>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  List<Map<String, String>> _unlockedBadges = [];
  late AnimationController _animCtrl;

  static const _rankColors = [
    Color(0xFFFFD700),
    Color(0xFFC0C0C0),
    Color(0xFFCD7F32),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _loadBadges();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBadges() async {
    try {
      // Load stats for this user from Firestore
      final statsDoc = await widget.db
          .collection('users').doc(widget.entry.uid)
          .collection('stats').doc('summary').get();
      final data     = statsDoc.data() ?? {};
      final sessions = (data['totalSessions'] as int?) ?? 0;
      final minutes  = (data['totalMinutes']  as int?) ?? 0;
      final streak   = widget.entry.streakDays;

      final badges = <Map<String, String>>[];
      for (final a in allAchievements) {
        bool unlocked = false;
        switch (a.category) {
          case 'session': unlocked = sessions >= a.requiredValue; break;
          case 'streak':  unlocked = streak   >= a.requiredValue; break;
          case 'time':    unlocked = minutes  >= a.requiredValue; break;
        }
        if (unlocked) {
          badges.add({'emoji': a.emoji, 'title': a.title, 'id': a.id});
        }
      }

      if (mounted) {
        setState(() { _unlockedBadges = badges; _loading = false; });
        _animCtrl.forward();
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatMinutes(int mins) {
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final e       = widget.entry;
    final rank    = widget.rank;
    final rankColor = rank <= 3 ? _rankColors[rank - 1] : Colors.white54;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A2540),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          children: [

            // Handle
            Center(child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)))),

            const SizedBox(height: 24),

            // Avatar + rank badge
            Center(child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: rankColor, width: 3),
                      boxShadow: [BoxShadow(
                          color: rankColor.withAlpha(80),
                          blurRadius: 20,
                          spreadRadius: 2)]),
                  child: AvatarWidget(avatarId: e.avatarId, size: 80),
                ),
                Positioned(
                  bottom: -6, right: -6,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                        color: rankColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF1A2540), width: 2)),
                    child: Center(child: Text('#$rank',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w900))),
                  ),
                ),
              ],
            )),

            const SizedBox(height: 16),

            // Name
            Center(child: Text(e.username,
                style: TextStyle(
                    color: e.isCurrentUser
                        ? const Color(0xFF3B82F6)
                        : Colors.white,
                    fontSize: 22, fontWeight: FontWeight.w800))),

            if (e.isCurrentUser) ...[
              const SizedBox(height: 4),
              const Center(child: Text('That\'s you! 👋',
                  style: TextStyle(color: Color(0xFF3B82F6), fontSize: 13))),
            ],

            const SizedBox(height: 24),

            // Stats cards
            Row(children: [
              _StatCard(
                  icon: Icons.self_improvement,
                  label: 'Meditated',
                  value: _formatMinutes(e.totalMinutes),
                  color: const Color(0xFF8B5CF6)),
              const SizedBox(width: 10),
              _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${e.streakDays}d',
                  color: const Color(0xFFF59E0B)),
              const SizedBox(width: 10),
              _StatCard(
                  icon: Icons.emoji_events,
                  label: 'Score',
                  value: '${e.totalScore}',
                  color: rankColor),
            ]),

            const SizedBox(height: 10),

            _StatCard(
                icon: Icons.check_circle_outline,
                label: 'Sessions Completed',
                value: '${e.totalSessions}',
                color: const Color(0xFF10B981),
                wide: true),

            const SizedBox(height: 24),

            // Badges section
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Achievements',
                  style: TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w700)),
              if (!_loading)
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withAlpha(30),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('${_unlockedBadges.length} unlocked',
                        style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.w700))),
            ]),

            const SizedBox(height: 12),

            if (_loading)
              const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                      color: Color(0xFF3B82F6), strokeWidth: 2)))
            else if (_unlockedBadges.isEmpty)
              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white.withAlpha(6),
                      borderRadius: BorderRadius.circular(14)),
                  child: const Center(child: Text('No achievements yet',
                      style: TextStyle(color: Colors.white38, fontSize: 13))))
            else
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _unlockedBadges.asMap().entries.map((entry) {
                  final i = entry.key;
                  final b = entry.value;
                  return AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (_, child) {
                      final delay = (i * 0.05).clamp(0.0, 0.8);
                      final t = ((_animCtrl.value - delay) / (1 - delay))
                          .clamp(0.0, 1.0);
                      return Opacity(
                          opacity: t,
                          child: Transform.scale(scale: 0.7 + (0.3 * t), child: child));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.white.withAlpha(8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withAlpha(20))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(b['emoji']!,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(b['title']!,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool wide;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(60))),
      child: wide
          ? Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
              color: color.withAlpha(180),
              fontSize: 11, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        ]),
      ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(
            color: color, fontSize: 17, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(
            color: color.withAlpha(160),
            fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
    );

    return wide ? SizedBox(width: double.infinity, child: inner)
        : Expanded(child: inner);
  }
}