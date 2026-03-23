// lib/screens/food/food_history_screen.dart
import 'package:flutter/material.dart';
import 'package:fitmetrics/services/firestore_service.dart';
import 'package:fitmetrics/core/haptic_service.dart';

class FoodHistoryScreen extends StatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final history = await FirestoreService.getFoodHistory();
    if (!mounted) return;
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  // ── Derived stats ─────────────────────────────────────────────────────────
  int get _totalDaysLogged =>
      _history.where((e) => (e['totalCalories'] as int? ?? 0) > 0).length;

  int get _avgCalories {
    final days = _history.where((e) => (e['totalCalories'] as int? ?? 0) > 0).toList();
    if (days.isEmpty) return 0;
    final sum = days.fold<int>(0, (a, b) => a + ((b['totalCalories'] as int?) ?? 0));
    return sum ~/ days.length;
  }

  int get _goalMetDays =>
      _history.where((e) => e['status'] == 'goal_met').length;

  // ── Group by relative date label ─────────────────────────────────────────
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final now = DateTime.now();
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final entry in _history) {
      final dateStr = entry['date'] as String? ?? '';
      final dt = DateTime.tryParse(dateStr) ?? now;
      final diff = now.difference(dt).inDays;
      String label;
      if (diff == 0)      label = 'Today';
      else if (diff == 1) label = 'Yesterday';
      else if (diff < 7)  label = '$diff days ago';
      else                label = dateStr;
      groups.putIfAbsent(label, () => []).add(entry);
    }
    return groups;
  }

  // ── Status helpers ────────────────────────────────────────────────────────
  Color _statusColor(String? status) {
    switch (status) {
      case 'goal_met':   return const Color(0xFF2ECC71);
      case 'under_goal': return const Color(0xFF3B82F6);
      case 'over_goal':  return const Color(0xFFFF4757);
      default:           return Colors.white38;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'goal_met':   return '✅ Goal Met';
      case 'under_goal': return '📉 Under Goal';
      case 'over_goal':  return '📈 Over Goal';
      default:           return '—';
    }
  }

  String _statusEmoji(String? status) {
    switch (status) {
      case 'goal_met':   return '🎯';
      case 'under_goal': return '💧';
      case 'over_goal':  return '🔺';
      default:           return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(children: [
          // ── Header ────────────────────────────────────────────────────────
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
                child: Text('Food History',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Stats chips ───────────────────────────────────────────────────
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                _StatChip(
                  label: 'Days Logged',
                  value: '$_totalDaysLogged',
                  icon: Icons.calendar_today_outlined,
                  color: const Color(0xFFEC4899),
                ),
                const SizedBox(width: 10),
                _StatChip(
                  label: 'Daily Avg',
                  value: '$_avgCalories kcal',
                  icon: Icons.local_fire_department_outlined,
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 10),
                _StatChip(
                  label: 'Goals Hit',
                  value: '$_goalMetDays 🎯',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF2ECC71),
                ),
              ]),
            ),

          const SizedBox(height: 16),

          // ── List ──────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFEC4899)))
                : _history.isEmpty
                ? const _EmptyState()
                : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFEC4899),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: _grouped.entries.map((e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(e.key,
                            style: TextStyle(
                                color: Colors.white.withAlpha(100),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                      ),
                      ...e.value.map((entry) => _FoodHistoryTile(
                        entry: entry,
                        statusColor: _statusColor(
                            entry['status'] as String?),
                        statusLabel: _statusLabel(
                            entry['status'] as String?),
                        statusEmoji: _statusEmoji(
                            entry['status'] as String?),
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
  const _StatChip(
      {required this.label,
        required this.value,
        required this.icon,
        required this.color});

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
        Text(value,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ]),
    ),
  );
}

// ── Food history tile ─────────────────────────────────────────────────────────
class _FoodHistoryTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  final Color statusColor;
  final String statusLabel;
  final String statusEmoji;

  const _FoodHistoryTile({
    required this.entry,
    required this.statusColor,
    required this.statusLabel,
    required this.statusEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final calories = entry['totalCalories'] as int? ?? 0;
    final goal     = entry['goal']          as int? ?? 2000;
    final date     = entry['date']          as String? ?? '';
    final progress = (calories / goal).clamp(0.0, 1.0);
    final over     = calories > goal;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(6),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Status icon
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(statusEmoji,
                    style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          // Date + status label
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ])),
          // Calories
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$calories kcal',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('goal: $goal kcal',
                style:
                const TextStyle(color: Colors.white38, fontSize: 11)),
          ]),
        ]),

        const SizedBox(height: 10),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withAlpha(15),
            valueColor: AlwaysStoppedAnimation(
                over ? const Color(0xFFFF4757) : statusColor),
          ),
        ),

        const SizedBox(height: 6),

        // Over / under label
        Text(
          over
              ? '+${calories - goal} kcal over goal'
              : calories == 0
              ? 'Nothing logged this day'
              : '${goal - calories} kcal remaining',
          style: TextStyle(
            color: over ? const Color(0xFFFF4757) : Colors.white38,
            fontSize: 11,
          ),
        ),
      ]),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text('No food logs yet',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Start logging meals to see your history here',
              style: TextStyle(
                  color: Colors.white.withAlpha(80), fontSize: 13)),
        ]),
  );
}