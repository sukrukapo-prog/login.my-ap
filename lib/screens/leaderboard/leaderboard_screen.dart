 import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmetrics/core/avatar_data.dart';
import 'package:fitmetrics/core/haptic_service.dart';
import 'package:fitmetrics/services/firestore_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {

  final _myUid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;

  late AnimationController _listCtrl;

  @override
  void initState() {
    super.initState();
    _listCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _load();
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      setState(() => _isRefreshing = true);
    } else {
      setState(() { _isLoading = true; _error = null; });
    }
    try {
      await FirestoreService.updateLeaderboardScore();
      final data = await FirestoreService.getLeaderboard();
      if (mounted) {
        setState(() {
          _entries = data;
          _isLoading = false;
          _isRefreshing = false;
        });
        _listCtrl.forward(from: 0);
      }
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  int? get _myRank {
    for (int i = 0; i < _entries.length; i++) {
      if (_entries[i]['uid'] == _myUid) return i + 1;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (!_isLoading && _entries.isNotEmpty) _buildMyRankBanner(),
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : _error != null
                  ? _buildError()
                  : _entries.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    child: Row(children: [
      GestureDetector(
        onTap: () { HapticService.light(); Navigator.pop(context); },
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Leaderboard', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          Text('Global ranking · All users', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ]),
      ),
      GestureDetector(
        onTap: _load,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.refresh, color: Colors.white54, size: 18),
        ),
      ),
    ]),
  );

  Widget _buildMyRankBanner() {
    final rank = _myRank;
    if (rank == null) return const SizedBox.shrink();
    final me = _entries.firstWhere((e) => e['uid'] == _myUid, orElse: () => {});
    final score = (me['score'] as int?) ?? 0;
    return _PulseWidget(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF1A2540)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5), width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text('#$rank', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your Rank', style: TextStyle(color: Colors.white54, fontSize: 11)),
            Text('Keep going to climb up!', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$score pts', style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 16, fontWeight: FontWeight.w800)),
            const Text('your score', style: TextStyle(color: Colors.white38, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildShimmer() {
    return _ShimmerLoader(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2A3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF2A3A4A), borderRadius: BorderRadius.circular(8))),
              const SizedBox(width: 10),
              Container(width: 44, height: 44, decoration: const BoxDecoration(color: Color(0xFF2A3A4A), shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(height: 12, width: 120, decoration: BoxDecoration(color: const Color(0xFF2A3A4A), borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 8),
                Container(height: 10, width: 180, decoration: BoxDecoration(color: const Color(0xFF2A3A4A), borderRadius: BorderRadius.circular(6))),
              ])),
              Container(height: 24, width: 50, decoration: BoxDecoration(color: const Color(0xFF2A3A4A), borderRadius: BorderRadius.circular(8))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: const Color(0xFF3B82F6),
      backgroundColor: const Color(0xFF1A2540),
      onRefresh: () => _load(refresh: true),
      child: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: _entries.length,
            itemBuilder: (ctx, i) {
              final delay = i * 0.06;
              final entry = _entries[i];
              final isMe = entry['uid'] == _myUid;
              return AnimatedBuilder(
                animation: _listCtrl,
                builder: (_, child) {
                  final t = ((_listCtrl.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
                  final anim = CurvedAnimation(parent: AlwaysStoppedAnimation(t), curve: Curves.easeOut);
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(anim),
                      child: child,
                    ),
                  );
                },
                child: _buildCard(entry, i + 1, isMe),
              );
            },
          ),
          if (_isRefreshing)
            Positioned.fill(child: _buildShimmer()),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> entry, int rank, bool isMe) {
    final name      = (entry['name'] as String?)?.trim() ?? 'User';
    final avatarId  = entry['avatarId'] as String?;
    final score     = (entry['score'] as int?) ?? 0;
    final medMins   = (entry['totalMinutes'] as int?) ?? 0;
    final workoutCal = (entry['totalCaloriesBurned'] as int?) ?? 0;
    final streak    = (entry['streakDays'] as int?) ?? 0;

    final avatar = avatarId != null
        ? allAvatars.cast<AppAvatar?>().firstWhere((a) => a?.id == avatarId, orElse: () => null)
        : null;

    Color rankColor = Colors.white38;
    Widget rankWidget;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
      rankWidget = const Text('🥇', style: TextStyle(fontSize: 24));
    } else if (rank == 2) {
      rankColor = const Color(0xFFB0C4DE);
      rankWidget = const Text('🥈', style: TextStyle(fontSize: 22));
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankWidget = const Text('🥉', style: TextStyle(fontSize: 22));
    } else {
      rankWidget = Text('#$rank', style: TextStyle(color: rankColor, fontSize: 13, fontWeight: FontWeight.w700));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF1E3A5F) : const Color(0xFF151F30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? const Color(0xFF3B82F6).withOpacity(0.5) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          SizedBox(width: 36, child: Center(child: rankWidget)),
          const SizedBox(width: 10),
          // Avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: avatar != null ? avatar.primaryColor.withOpacity(0.2) : const Color(0xFF1E2A3A),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: avatar != null
                  ? Image.asset(avatar.imagePath, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(avatar.fallbackIcon, color: avatar.primaryColor, size: 22))
                  : const Icon(Icons.person, color: Colors.white38, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(
                  isMe ? '$name (You)' : name,
                  style: TextStyle(
                    color: isMe ? const Color(0xFF3B82F6) : Colors.white,
                    fontSize: 14, fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                )),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                _pill('🧘 ${medMins}m',    const Color(0xFF8B5CF6)),
                const SizedBox(width: 5),
                _pill('🔥 ${streak}d',     const Color(0xFFF59E0B)),
                const SizedBox(width: 5),
                _pill('💪 ${workoutCal}', const Color(0xFF2ECC71)),
              ]),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            score == 0
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(8)),
              child: const Text('Just joined! 👋', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600)),
            )
                : Text('$score', style: TextStyle(color: rankColor, fontSize: 18, fontWeight: FontWeight.w900)),
            if (score > 0) const Text('pts', style: TextStyle(color: Colors.white38, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
  );

  Widget _buildEmpty() => const Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('🏆', style: TextStyle(fontSize: 56)),
      SizedBox(height: 16),
      Text('No users yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      SizedBox(height: 8),
      Text('Complete sessions to appear here', style: TextStyle(color: Colors.white38, fontSize: 14)),
    ]),
  );

  Widget _buildError() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off, color: Colors.white38, size: 48),
      const SizedBox(height: 16),
      const Text('Could not load leaderboard', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _load,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(12)),
          child: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
    ]),
  );
}

// ── Shimmer loader ─────────────────────────────────────────────────────────────
class _ShimmerLoader extends StatefulWidget {
  final Widget child;
  const _ShimmerLoader({required this.child});
  @override
  State<_ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<_ShimmerLoader> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.8).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, child) => Opacity(opacity: _anim.value, child: child),
    child: widget.child,
  );
}
class _PulseWidget extends StatefulWidget {
  final Widget child;
  const _PulseWidget({required this.child});
  @override
  State<_PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<_PulseWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, child) => Transform.scale(scale: _anim.value, child: child),
    child: widget.child,
  );
}