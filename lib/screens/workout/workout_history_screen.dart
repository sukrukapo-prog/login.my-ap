import 'package:flutter/material.dart';
import 'package:fitmetrics/services/firestore_service.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  static const _catColors = {
    'stretching': Color(0xFF2ECC71),
    'bodyweight': Color(0xFF3B82F6),
    'dumbbell':   Color(0xFFFF9F43),
  };

  static const _catEmojis = {
    'stretching': '🤸',
    'bodyweight': '💪',
    'dumbbell':   '🏋️',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await FirestoreService.getWorkoutHistory();
    if (mounted) setState(() { _history = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1624),
        elevation: 0,
        title: const Text('Workout History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : _history.isEmpty
          ? _buildEmpty()
          : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏋️', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text('No workouts logged yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Start a workout to see your history here', style: TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildList() {
    // Group by date
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final w in _history) {
      final date = w['date'] as String? ?? 'Unknown';
      grouped.putIfAbsent(date, () => []).add(w);
    }

    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: dates.length,
      itemBuilder: (ctx, i) {
        final date = dates[i];
        final workouts = grouped[date]!;
        final totalCal = workouts.fold(0, (sum, w) => sum + (w['caloriesBurned'] as int? ?? 0));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF3D2A12), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(Icons.local_fire_department, color: Color(0xFFFF9F43), size: 12),
                      const SizedBox(width: 4),
                      Text('$totalCal kcal', style: const TextStyle(color: Color(0xFFFF9F43), fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ],
              ),
            ),
            ...workouts.map((w) {
              final cat = w['category'] as String? ?? 'bodyweight';
              final color = _catColors[cat] ?? const Color(0xFF3B82F6);
              final emoji = _catEmojis[cat] ?? '💪';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF151F30),
                  borderRadius: BorderRadius.circular(14),
                  border: Border(left: BorderSide(color: color, width: 3)),
                ),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w['exerciseName'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text('${w['setsCompleted']} sets × ${w['repsCompleted']} reps', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${w['caloriesBurned']} kcal', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}