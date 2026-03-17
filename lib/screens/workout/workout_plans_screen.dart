import 'package:flutter/material.dart';
import 'package:fitmetrics/models/workout_plan_model.dart';
import 'package:fitmetrics/services/firestore_service.dart';
import 'package:fitmetrics/screens/workout/workout_plan_builder_screen.dart';
import 'package:fitmetrics/screens/workout/workout_plan_detail_screen.dart';

class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  List<WorkoutPlan> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await FirestoreService.getPlans();
    setState(() {
      _plans = data.map((j) => WorkoutPlan.fromJson(j)).toList();
      _loading = false;
    });
  }

  Future<void> _openBuilder({WorkoutPlan? existing}) async {
    final result = await Navigator.push<WorkoutPlan>(
      context,
      MaterialPageRoute(builder: (_) => WorkoutPlanBuilderScreen(existing: existing)),
    );
    if (result != null) _load();
  }

  Future<void> _deletePlan(WorkoutPlan plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2540),
        title: const Text('Delete Plan', style: TextStyle(color: Colors.white)),
        content: Text('Delete "${plan.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirestoreService.deletePlan(plan.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Plans', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        Text('Custom workout routines', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openBuilder(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('New', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                  : _plans.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(24)),
            child: const Center(child: Text('📋', style: TextStyle(fontSize: 36))),
          ),
          const SizedBox(height: 16),
          const Text('No plans yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Create your first custom workout plan', style: TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _openBuilder(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('Create a Plan', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: _plans.length,
      itemBuilder: (ctx, i) {
        final plan = _plans[i];
        return GestureDetector(
          onTap: () async {
            await Navigator.push(ctx, MaterialPageRoute(
              builder: (_) => WorkoutPlanDetailScreen(plan: plan),
            ));
            _load();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF151F30),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF1E2A3A)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E2A3A), Color(0xFF0F1624)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(child: Text(plan.emoji, style: const TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Row(children: [
                          _tag('${plan.exercises.length} exercises', const Color(0xFF3B82F6)),
                          const SizedBox(width: 6),
                          _tag('~${plan.totalCalories} kcal', const Color(0xFFFF9F43)),
                        ]),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: const Color(0xFF1A2540),
                    icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
                    onSelected: (v) {
                      if (v == 'edit') _openBuilder(existing: plan);
                      if (v == 'delete') _deletePlan(plan);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [
                        Icon(Icons.edit, color: Colors.white54, size: 16),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: Colors.white)),
                      ])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [
                        Icon(Icons.delete, color: Colors.redAccent, size: 16),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.redAccent)),
                      ])),
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

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}