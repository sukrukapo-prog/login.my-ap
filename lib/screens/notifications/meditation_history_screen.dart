import 'package:flutter/material.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/core/haptic_service.dart';

class MeditationHistoryScreen extends StatefulWidget {
  const MeditationHistoryScreen({super.key});

  @override
  State<MeditationHistoryScreen> createState() => _MeditationHistoryScreenState();
}

class _MeditationHistoryScreenState extends State<MeditationHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final history = await LocalStorage.getMeditationHistory();
    final stats = await LocalStorage.getAllTimeStats();
    if (!mounted) return;
    setState(() {
      _history = history;
      _stats = stats;
      _isLoading = false;
    });
  }

  // Group entries by date label
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final now = DateTime.now();
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final entry in _history) {
      final ts = DateTime.tryParse(entry['timestamp'] ?? '') ?? now;
      final diff = now.difference(ts).inDays;
      String label;
      if (diff == 0) {
        label = 'Today';
      } else if (diff == 1) {
        label = 'Yesterday';
      } else if (diff < 7) {
        label = '$diff days ago';
      } else {
        final y = ts.year; final m = ts.month.toString().padLeft(2, '0'); final d = ts.day.toString().padLeft(2, '0');
        label = '$y-$m-$d';
      }
      groups.putIfAbsent(label, () => []).add(entry);
    }
    return groups;
  }

  String _timeLabel(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _typeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'movement': return const Color(0xFF8B5CF6);
      case 'calmness': return const Color(0xFF10B981);
      default:         return const Color(0xFF3B82F6);
    }
  }

  String _typeEmoji(String? type) {
    switch (type?.toLowerCase()) {
      case 'movement': return '🏃';
      case 'calmness': return '🧘';
      default:         return '🌿';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(children: [
          // Header
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
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Session History',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // Stats row
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                _StatChip(label: 'Sessions', value: '${_stats['totalSessions'] ?? 0}', icon: Icons.check_circle_outline, color: const Color(0xFF10B981)),
                const SizedBox(width: 10),
                _StatChip(label: 'Total Time', value: '${_stats['totalMinutes'] ?? 0} min', icon: Icons.timer_outlined, color: const Color(0xFF3B82F6)),
                const SizedBox(width: 10),
                _StatChip(label: 'Streak', value: '${_stats['streakDays'] ?? 0}d 🔥', icon: Icons.local_fire_department, color: const Color(0xFFF59E0B)),
              ]),
            ),

          const SizedBox(height: 16),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                : _history.isEmpty
                ? _EmptyState()
                : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFF3B82F6),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: _grouped.entries.map((e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(e.key,
                            style: TextStyle(color: Colors.white.withAlpha(100),
                                fontSize: 12, fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                      ),
                      ...e.value.map((entry) => _HistoryTile(
                        entry: entry,
                        typeColor: _typeColor(entry['type']),
                        typeEmoji: _typeEmoji(entry['type']),
                        timeLabel: _timeLabel(entry['timestamp']),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ]),
    ),
  );
}

// ── History tile ──────────────────────────────────────────────────────────────
class _HistoryTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  final Color typeColor;
  final String typeEmoji;
  final String timeLabel;
  const _HistoryTile({required this.entry, required this.typeColor, required this.typeEmoji, required this.timeLabel});

  @override
  Widget build(BuildContext context) {
    final name    = entry['sessionName'] ?? 'Session';
    final type    = entry['type'] ?? '';
    final minutes = entry['minutes'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(6),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: typeColor, width: 3)),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: typeColor.withAlpha(25), shape: BoxShape.circle),
          child: Center(child: Text(typeEmoji, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(type, style: TextStyle(color: typeColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$minutes min',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(timeLabel, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ]),
      ]),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🧘', style: TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      const Text('No sessions yet',
          style: TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('Complete a meditation to see your history',
          style: TextStyle(color: Colors.white.withAlpha(80), fontSize: 13)),
    ]),
  );
}
