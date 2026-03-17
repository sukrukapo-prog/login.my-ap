import 'package:flutter/material.dart';
import 'package:fitmetrics/models/workout_plan_model.dart';
import 'package:fitmetrics/services/firestore_service.dart';

class WorkoutPlanDetailScreen extends StatefulWidget {
  final WorkoutPlan plan;
  const WorkoutPlanDetailScreen({super.key, required this.plan});

  @override
  State<WorkoutPlanDetailScreen> createState() => _WorkoutPlanDetailScreenState();
}

class _WorkoutPlanDetailScreenState extends State<WorkoutPlanDetailScreen> {
  int _currentIndex = -1; // -1 = overview, 0+ = active exercise
  bool _logging = false;
  Set<int> _completedIndices = {};

  bool get _isActive => _currentIndex >= 0;
  bool get _isFinished => _completedIndices.length == widget.plan.exercises.length;

  void _startWorkout() => setState(() => _currentIndex = 0);

  void _completeExercise() {
    setState(() {
      _completedIndices.add(_currentIndex);
      if (_currentIndex < widget.plan.exercises.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = widget.plan.exercises.length; // done
      }
    });
  }

  Future<void> _logAll() async {
    setState(() => _logging = true);
    try {
      for (final ex in widget.plan.exercises) {
        await FirestoreService.logWorkout(
          exerciseId: ex.exerciseId,
          exerciseName: ex.exerciseName,
          category: 'bodyweight',
          setsCompleted: ex.sets,
          repsCompleted: 12,
          caloriesBurned: ex.caloriesPerSession,
        );
      }
      if (mounted) {
        setState(() => _logging = false);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _logging = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error logging: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.plan.exercises.length && _isFinished) {
      return _buildFinishScreen();
    }
    if (_isActive) return _buildExercisePlayer();
    return _buildOverview();
  }

  // ── Overview ────────────────────────────────────────────────────────────────
  Widget _buildOverview() {
    final plan = widget.plan;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Hero
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF0F1624)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  Text(plan.emoji, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(plan.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _heroStat('${plan.exercises.length}', 'Exercises', const Color(0xFF3B82F6)),
                      _heroStat('${plan.totalSets}', 'Total Sets', const Color(0xFF8B5CF6)),
                      _heroStat('~${plan.totalCalories}', 'kcal', const Color(0xFFFF9F43)),
                    ],
                  ),
                ],
              ),
            ),

            // Exercise list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                itemCount: plan.exercises.length,
                itemBuilder: (ctx, i) {
                  final ex = plan.exercises[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151F30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(ex.emoji, style: const TextStyle(fontSize: 18))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex.exerciseName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                              Text('${ex.sets} sets · ${ex.reps}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        ),
                        Text('~${ex.caloriesPerSession} kcal', style: const TextStyle(color: Color(0xFFFF9F43), fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: const Color(0xFF0F1624),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: GestureDetector(
          onTap: _startWorkout,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text('Start Workout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  // ── Exercise Player ─────────────────────────────────────────────────────────
  Widget _buildExercisePlayer() {
    final ex = widget.plan.exercises[_currentIndex];
    final total = widget.plan.exercises.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = -1),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exercise ${_currentIndex + 1} of $total',
                            style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFF1E2A3A),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Exercise card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A2744), Color(0xFF0F1624)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(ex.emoji, style: const TextStyle(fontSize: 64)),
                          const SizedBox(height: 12),
                          Text(ex.exerciseName,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _playerStat('${ex.sets}', 'Sets', const Color(0xFF3B82F6)),
                              _playerStat(ex.reps, 'Reps', const Color(0xFF2ECC71)),
                              _playerStat('~${ex.caloriesPerSession}', 'kcal', const Color(0xFFFF9F43)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Completed exercises
                    if (_completedIndices.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Completed', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 8),
                      ...widget.plan.exercises.asMap().entries
                          .where((e) => _completedIndices.contains(e.key))
                          .map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Text(e.value.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(e.value.exerciseName, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                            const Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 18),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),

            // Done button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: GestureDetector(
                onTap: _completeExercise,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      _currentIndex < total - 1 ? 'Done ✓  →  Next' : 'Finish Workout 🎉',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  // ── Finish Screen ───────────────────────────────────────────────────────────
  Widget _buildFinishScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 20),
                const Text('Workout Complete! 🎉',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.plan.exercises.length} exercises done\n~${widget.plan.totalCalories} kcal burned',
                  style: const TextStyle(color: Colors.white54, fontSize: 15, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _logging ? null : _logAll,
                  child: Container(
                    width: double.infinity, height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _logging
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                          : const Text('Save to History 💪',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity, height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2A3A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('Skip & Go Back',
                          style: TextStyle(color: Colors.white54, fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}