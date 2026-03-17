import 'package:flutter/material.dart';
import 'package:fitmetrics/models/exercise_model.dart';
import 'package:fitmetrics/screens/workout/exercise_detail_screen.dart';

class _Category {
  final String key;
  final String label;
  final String emoji;
  final Color accent;
  final Color bg;
  const _Category({required this.key, required this.label, required this.emoji, required this.accent, required this.bg});
}

const _categories = [
  _Category(key: 'stretching', label: 'Stretching', emoji: '🤸', accent: Color(0xFF2ECC71), bg: Color(0xFF1A3D2B)),
  _Category(key: 'bodyweight', label: 'Bodyweight', emoji: '💪', accent: Color(0xFF3B82F6), bg: Color(0xFF1A2744)),
  _Category(key: 'dumbbell',   label: 'Dumbbell',   emoji: '🏋️', accent: Color(0xFFFF9F43), bg: Color(0xFF3D2A12)),
];

const _diffColors = {
  'beginner':     Color(0xFF2ECC71),
  'intermediate': Color(0xFFFF9F43),
  'advanced':     Color(0xFFFF4757),
};

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with SingleTickerProviderStateMixin {
  String _activeCategory = 'stretching';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _activeCategory = _categories[_tabController.index].key);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = kExercises.where((e) => e.category == _activeCategory).toList();
    final cat = _categories.firstWhere((c) => c.key == _activeCategory);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(filtered.length),
            _buildTabs(),
            _buildBanner(cat),
            Expanded(child: _buildList(filtered, cat)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Workout', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('$count exercises available', style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1E2A3A), width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (i) => setState(() => _activeCategory = _categories[i].key),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 3,
            color: _categories.firstWhere((c) => c.key == _activeCategory).accent,
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        tabs: _categories.map((c) => Tab(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(c.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(c.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildBanner(_Category cat) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cat.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cat.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(cat.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${cat.label} Exercises', style: TextStyle(color: cat.accent, fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              const Text('Tap an exercise to see details & log', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Exercise> exercises, _Category cat) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: exercises.length,
      itemBuilder: (ctx, i) {
        final ex = exercises[i];
        final diffColor = _diffColors[ex.difficulty] ?? const Color(0xFF2ECC71);
        return GestureDetector(
          onTap: () => Navigator.push(ctx, MaterialPageRoute(
            builder: (_) => ExerciseDetailScreen(exercise: ex),
          )),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF151F30),
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: cat.accent, width: 4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: cat.bg, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(ex.emoji, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(ex.muscleGroup, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: diffColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(ex.difficulty, style: TextStyle(color: diffColor, fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),
                            Text('${ex.sets} sets · ${ex.reps}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text('~${ex.caloriesPerSession}', style: TextStyle(color: cat.accent, fontSize: 16, fontWeight: FontWeight.w800)),
                      const Text('kcal', style: TextStyle(color: Colors.white38, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}