import 'package:flutter/material.dart';
import 'package:fitmetrics/models/exercise_model.dart';
import 'package:fitmetrics/services/firestore_service.dart';

const _catAccent = {
  'stretching': Color(0xFF2ECC71),
  'bodyweight': Color(0xFF3B82F6),
  'dumbbell':   Color(0xFFFF9F43),
};

const _catBg = {
  'stretching': [Color(0xFF2ECC71), Color(0xFF1aad61)],
  'bodyweight': [Color(0xFF3B82F6), Color(0xFF1A56C4)],
  'dumbbell':   [Color(0xFFFF9F43), Color(0xFFE06800)],
};

const _diffColors = {
  'beginner':     Color(0xFF2ECC71),
  'intermediate': Color(0xFFFF9F43),
  'advanced':     Color(0xFFFF4757),
};

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final _setsCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  bool _loading = false;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    _setsCtrl.text = widget.exercise.sets.toString();
    _repsCtrl.text = '12';
  }

  @override
  void dispose() {
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  int get _estCalories {
    final sets = int.tryParse(_setsCtrl.text) ?? widget.exercise.sets;
    return (widget.exercise.caloriesPerSession * sets / widget.exercise.sets).round();
  }

  Color get _accent => _catAccent[widget.exercise.category] ?? const Color(0xFF3B82F6);
  List<Color> get _gradient => (_catBg[widget.exercise.category] ?? [const Color(0xFF3B82F6), const Color(0xFF1A56C4)]);

  Future<void> _logWorkout() async {
    final sets = int.tryParse(_setsCtrl.text);
    final reps = int.tryParse(_repsCtrl.text);
    if (sets == null || reps == null || sets <= 0 || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter valid sets and reps'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _loading = true);
    try {
      await FirestoreService.logWorkout(
        exerciseId:     widget.exercise.id,
        exerciseName:   widget.exercise.name,
        category:       widget.exercise.category,
        setsCompleted:  sets,
        repsCompleted:  reps,
        caloriesBurned: _estCalories,
      );
      if (mounted) setState(() { _loading = false; _logged = true; });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final diffColor = _diffColors[ex.difficulty] ?? const Color(0xFF2ECC71);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: _logged ? _buildSuccess() : Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(ex, diffColor),
                    _buildSection('How to do it', _buildDescription(ex)),
                    _buildSection('Recommended', _buildStats(ex)),
                    _buildSection('Log This Workout', _buildLogCard()),
                    _buildLogButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: _gradient),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Workout Logged! 💪', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('${widget.exercise.name} completed!\n~$_estCalories kcal burned',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 15, height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
          const Expanded(child: Center(
            child: Text('Exercise', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          )),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildHero(Exercise ex, Color diffColor) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(ex.emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 10),
          Text(ex.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                child: Text(ex.category[0].toUpperCase() + ex.category.substring(1),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: diffColor.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                child: Text(ex.difficulty, style: TextStyle(color: diffColor, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(ex.muscleGroup, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildDescription(Exercise ex) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF151F30), borderRadius: BorderRadius.circular(16)),
      child: Text(ex.description, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
    );
  }

  Widget _buildStats(Exercise ex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF151F30), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('${ex.sets}', 'Sets', _accent),
          Container(width: 1, height: 40, color: const Color(0xFF1E2A3A)),
          _statItem(ex.reps, 'Reps / Duration', _accent),
          Container(width: 1, height: 40, color: const Color(0xFF1E2A3A)),
          _statItem('~${ex.caloriesPerSession}', 'Cal burned', const Color(0xFFFF9F43)),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildLogCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF151F30), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _inputField('Sets completed', _setsCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _inputField('Reps per set', _repsCtrl)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF1E2A3A)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimated calories burned', style: TextStyle(color: Colors.white54, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFF3D2A12), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Color(0xFFFF9F43), size: 14),
                      const SizedBox(width: 4),
                      Text('$_estCalories kcal', style: const TextStyle(color: Color(0xFFFF9F43), fontSize: 14, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F1624),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E2A3A), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E2A3A), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildLogButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: GestureDetector(
        onTap: _loading ? null : _logWorkout,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _gradient),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text('Mark as Complete 💪', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}