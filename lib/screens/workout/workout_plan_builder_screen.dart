import 'package:flutter/material.dart';
import 'package:fitmetrics/models/exercise_model.dart';
import 'package:fitmetrics/models/workout_plan_model.dart';
import 'package:fitmetrics/services/firestore_service.dart';

const _planEmojis = ['💪', '🔥', '⚡', '🏋️', '🤸', '🦵', '🧘', '🏃', '⭐', '🎯'];

const _catAccent = {
  'stretching': Color(0xFF2ECC71),
  'bodyweight': Color(0xFF3B82F6),
  'dumbbell':   Color(0xFFFF9F43),
};
const _catBg = {
  'stretching': Color(0xFF1A3D2B),
  'bodyweight': Color(0xFF1A2744),
  'dumbbell':   Color(0xFF3D2A12),
};
const _diffColors = {
  'beginner':     Color(0xFF2ECC71),
  'intermediate': Color(0xFFFF9F43),
  'advanced':     Color(0xFFFF4757),
};

class WorkoutPlanBuilderScreen extends StatefulWidget {
  final WorkoutPlan? existing; // null = new plan
  const WorkoutPlanBuilderScreen({super.key, this.existing});

  @override
  State<WorkoutPlanBuilderScreen> createState() => _WorkoutPlanBuilderScreenState();
}

class _WorkoutPlanBuilderScreenState extends State<WorkoutPlanBuilderScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  String _emoji = '💪';
  List<PlanExercise> _selected = [];
  bool _saving = false;
  late TabController _tabCtrl;
  String _activeCategory = 'stretching';
  String _search = '';

  static const _categories = ['stretching', 'bodyweight', 'dumbbell'];
  static const _catLabels  = {'stretching': '🤸 Stretch', 'bodyweight': '💪 Body', 'dumbbell': '🏋️ Dumbbell'};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _activeCategory = _categories[_tabCtrl.index]);
      }
    });
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _emoji = widget.existing!.emoji;
      _selected = List.from(widget.existing!.exercises);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  bool _isSelected(Exercise ex) => _selected.any((e) => e.exerciseId == ex.id);

  void _toggle(Exercise ex) {
    setState(() {
      if (_isSelected(ex)) {
        _selected.removeWhere((e) => e.exerciseId == ex.id);
      } else {
        _selected.add(PlanExercise(
          exerciseId: ex.id,
          exerciseName: ex.name,
          emoji: ex.emoji,
          sets: ex.sets,
          reps: ex.reps,
          caloriesPerSession: ex.caloriesPerSession,
        ));
      }
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please give your plan a name'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Add at least one exercise'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _saving = true);
    try {
      final plan = WorkoutPlan(
        id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameCtrl.text.trim(),
        emoji: _emoji,
        exercises: _selected,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
      );
      await FirestoreService.savePlan(plan.toJson());
      if (mounted) {
        Navigator.pop(context, plan);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
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
    final totalCal = _selected.fold(0, (s, e) => s + e.caloriesPerSession);
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildNameRow(),
            _buildSummaryBar(totalCal),
            _buildCategoryTabs(),
            _buildSearchBar(),
            Expanded(child: _buildExerciseList()),
            _buildSelectedBar(),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
          const SizedBox(width: 12),
          Text(
            widget.existing == null ? 'Create Plan' : 'Edit Plan',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildNameRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          // Emoji picker
          GestureDetector(
            onTap: _pickEmoji,
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(_emoji, style: const TextStyle(fontSize: 26))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Plan name (e.g. Morning Blast)',
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFF1E2A3A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(int totalCal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          _chip(Icons.fitness_center, '${_selected.length} exercises', const Color(0xFF3B82F6)),
          const SizedBox(width: 8),
          _chip(Icons.local_fire_department, '~$totalCal kcal', const Color(0xFFFF9F43)),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF1E2A3A)))),
      child: TabBar(
        controller: _tabCtrl,
        onTap: (i) => setState(() => _activeCategory = _categories[i]),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 2, color: Color(0xFF3B82F6)),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        tabs: _categories.map((c) => Tab(
          child: Text(_catLabels[c]!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        )).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: TextField(
        onChanged: (v) => setState(() => _search = v.toLowerCase()),
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.white24, size: 18),
          filled: true,
          fillColor: const Color(0xFF1E2A3A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    final exercises = kExercises.where((e) {
      final matchCat = e.category == _activeCategory;
      final matchSearch = _search.isEmpty ||
          e.name.toLowerCase().contains(_search) ||
          e.muscleGroup.toLowerCase().contains(_search);
      return matchCat && matchSearch;
    }).toList();

    final accent = _catAccent[_activeCategory] ?? const Color(0xFF3B82F6);
    final bg     = _catBg[_activeCategory]     ?? const Color(0xFF1A2744);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      itemCount: exercises.length,
      itemBuilder: (ctx, i) {
        final ex = exercises[i];
        final selected = _isSelected(ex);
        final diffColor = _diffColors[ex.difficulty] ?? const Color(0xFF2ECC71);

        return GestureDetector(
          onTap: () => _toggle(ex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: selected ? accent.withOpacity(0.15) : const Color(0xFF151F30),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(ex.emoji, style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(ex.muscleGroup, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: diffColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                            child: Text(ex.difficulty, style: TextStyle(color: diffColor, fontSize: 9, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 6),
                          Text('${ex.sets} sets · ${ex.reps}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        ]),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: selected ? accent : const Color(0xFF1E2A3A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          selected ? Icons.check : Icons.add,
                          color: selected ? Colors.white : Colors.white38,
                          size: 16,
                        ),
                      ),
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

  Widget _buildSelectedBar() {
    if (_selected.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(14)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: _selected.length,
        itemBuilder: (ctx, i) {
          final ex = _selected[i];
          return GestureDetector(
            onTap: () => setState(() => _selected.removeAt(i)),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Text(ex.emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(ex.exerciseName, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 5),
                  const Icon(Icons.close, color: Colors.white38, size: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: GestureDetector(
        onTap: _saving ? null : _save,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: _saving
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                : Text(
              widget.existing == null ? 'Save Plan (${_selected.length} exercises)' : 'Update Plan',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  void _pickEmoji() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2540),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose an emoji', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: _planEmojis.map((e) => GestureDetector(
                onTap: () { setState(() => _emoji = e); Navigator.pop(context); },
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: _emoji == e ? const Color(0xFF3B82F6).withOpacity(0.3) : const Color(0xFF0F1624),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _emoji == e ? const Color(0xFF3B82F6) : Colors.transparent),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 26))),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}