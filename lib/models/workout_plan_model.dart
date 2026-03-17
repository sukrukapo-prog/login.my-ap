class PlanExercise {
  final String exerciseId;
  final String exerciseName;
  final String emoji;
  final int sets;
  final String reps;
  final int caloriesPerSession;

  const PlanExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.emoji,
    required this.sets,
    required this.reps,
    required this.caloriesPerSession,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'emoji': emoji,
    'sets': sets,
    'reps': reps,
    'caloriesPerSession': caloriesPerSession,
  };

  factory PlanExercise.fromJson(Map<String, dynamic> j) => PlanExercise(
    exerciseId: j['exerciseId'] ?? '',
    exerciseName: j['exerciseName'] ?? '',
    emoji: j['emoji'] ?? '💪',
    sets: (j['sets'] as num?)?.toInt() ?? 3,
    reps: j['reps'] ?? '10 reps',
    caloriesPerSession: (j['caloriesPerSession'] as num?)?.toInt() ?? 50,
  );
}

class WorkoutPlan {
  final String id;
  final String name;
  final String emoji;
  final List<PlanExercise> exercises;
  final DateTime createdAt;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.emoji,
    required this.exercises,
    required this.createdAt,
  });

  int get totalCalories => exercises.fold(0, (s, e) => s + e.caloriesPerSession);
  int get totalSets => exercises.fold(0, (s, e) => s + e.sets);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory WorkoutPlan.fromJson(Map<String, dynamic> j) => WorkoutPlan(
    id: j['id'] ?? '',
    name: j['name'] ?? 'My Plan',
    emoji: j['emoji'] ?? '💪',
    exercises: (j['exercises'] as List<dynamic>? ?? [])
        .map((e) => PlanExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );
}