class Exercise {
  final String id;
  final String name;
  final String category; // 'stretching' | 'bodyweight' | 'dumbbell'
  final String? subcategory;
  final String description;
  final String muscleGroup;
  final int sets;
  final String reps;
  final String difficulty; // 'beginner' | 'intermediate' | 'advanced'
  final int caloriesPerSession;
  final String emoji;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.description,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.difficulty,
    required this.caloriesPerSession,
    required this.emoji,
  });
}

const List<Exercise> kExercises = [
  // ── Stretching – Upper Body ────────────────────────────────────────────────
  Exercise(id: 's1', name: 'Neck Stretch', category: 'stretching', subcategory: 'Upper Body', description: 'Gently tilt your head to one side, hold 15-30 seconds. Repeat on other side.', muscleGroup: 'Neck / Trapezius', sets: 2, reps: '30 sec each side', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🧘'),
  Exercise(id: 's2', name: 'Shoulder Stretch', category: 'stretching', subcategory: 'Upper Body', description: 'Bring one arm across your chest and gently pull it with the opposite hand.', muscleGroup: 'Deltoids', sets: 2, reps: '30 sec each side', difficulty: 'beginner', caloriesPerSession: 5, emoji: '💪'),
  Exercise(id: 's3', name: 'Chest Stretch', category: 'stretching', subcategory: 'Upper Body', description: 'Clasp hands behind back, squeeze shoulder blades and lift arms gently.', muscleGroup: 'Pectorals', sets: 2, reps: '30 sec', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🤸'),
  Exercise(id: 's4', name: 'Triceps Stretch', category: 'stretching', subcategory: 'Upper Body', description: 'Reach one arm overhead, bend it behind your head and gently push the elbow.', muscleGroup: 'Triceps', sets: 2, reps: '30 sec each', difficulty: 'beginner', caloriesPerSession: 5, emoji: '💪'),
  Exercise(id: 's5', name: 'Arm Cross Stretch', category: 'stretching', subcategory: 'Upper Body', description: 'Cross one arm across the chest at shoulder height, hold and pull gently.', muscleGroup: 'Deltoids / Upper Back', sets: 2, reps: '30 sec each', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🤗'),
  Exercise(id: 's6', name: 'Lat Stretch', category: 'stretching', subcategory: 'Upper Body', description: 'Reach both arms overhead, clasp hands and lean to one side slowly.', muscleGroup: 'Latissimus Dorsi', sets: 2, reps: '30 sec each side', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🙆'),
  Exercise(id: 's7', name: 'Wrist Stretch', category: 'stretching', subcategory: 'Upper Body', description: 'Extend one arm, gently pull fingers back with the other hand.', muscleGroup: 'Forearms / Wrists', sets: 2, reps: '20 sec each', difficulty: 'beginner', caloriesPerSession: 3, emoji: '🖐️'),
  Exercise(id: 's8', name: 'Upper Back Stretch', category: 'stretching', subcategory: 'Upper Body', description: 'Round your upper back and reach arms forward, hold and breathe deeply.', muscleGroup: 'Rhomboids / Upper Back', sets: 2, reps: '30 sec', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🧘'),
  // ── Stretching – Lower Body ───────────────────────────────────────────────
  Exercise(id: 's9', name: 'Hamstring Stretch', category: 'stretching', subcategory: 'Lower Body', description: 'Sit on the floor with legs extended, reach forward toward your toes.', muscleGroup: 'Hamstrings', sets: 2, reps: '30 sec', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🦵'),
  Exercise(id: 's10', name: 'Quad Stretch', category: 'stretching', subcategory: 'Lower Body', description: 'Stand on one leg, pull the other foot toward your glutes and hold.', muscleGroup: 'Quadriceps', sets: 2, reps: '30 sec each', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🦵'),
  Exercise(id: 's11', name: 'Calf Stretch', category: 'stretching', subcategory: 'Lower Body', description: 'Place hands on wall, step one foot back, press heel firmly into ground.', muscleGroup: 'Calves', sets: 2, reps: '30 sec each', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🦶'),
  Exercise(id: 's12', name: 'Hip Flexor Stretch', category: 'stretching', subcategory: 'Lower Body', description: 'Kneel on one knee, push hips forward gently until you feel a deep stretch.', muscleGroup: 'Hip Flexors', sets: 2, reps: '30 sec each', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🤸'),
  Exercise(id: 's13', name: 'Butterfly Stretch', category: 'stretching', subcategory: 'Lower Body', description: 'Sit with feet together, gently press knees toward the floor.', muscleGroup: 'Inner Thighs / Groin', sets: 2, reps: '30-60 sec', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🦋'),
  Exercise(id: 's14', name: 'Glute Stretch', category: 'stretching', subcategory: 'Lower Body', description: 'Lie on back, cross one ankle over opposite knee and pull toward chest.', muscleGroup: 'Glutes', sets: 2, reps: '30 sec each', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🧘'),
  Exercise(id: 's15', name: 'Groin Stretch', category: 'stretching', subcategory: 'Lower Body', description: 'Stand with feet wide apart, shift weight to one side and lunge gently.', muscleGroup: 'Adductors / Groin', sets: 2, reps: '30 sec each', difficulty: 'beginner', caloriesPerSession: 5, emoji: '🤸'),
  Exercise(id: 's16', name: 'Ankle Stretch', category: 'stretching', subcategory: 'Lower Body', description: 'Sit on a chair, draw slow circles with your foot, then flex and point.', muscleGroup: 'Ankles / Calves', sets: 2, reps: '20 circles each', difficulty: 'beginner', caloriesPerSession: 3, emoji: '🦶'),
  // ── Bodyweight ────────────────────────────────────────────────────────────
  Exercise(id: 'b1', name: 'Push-ups', category: 'bodyweight', description: 'Classic upper body push. Start in plank, lower chest to floor, push back up with control.', muscleGroup: 'Chest / Triceps / Shoulders', sets: 3, reps: '10-15 reps', difficulty: 'beginner', caloriesPerSession: 50, emoji: '💪'),
  Exercise(id: 'b2', name: 'Squats', category: 'bodyweight', description: 'Stand feet shoulder-width apart, lower hips until thighs are parallel to floor, drive up.', muscleGroup: 'Quads / Glutes / Hamstrings', sets: 3, reps: '15-20 reps', difficulty: 'beginner', caloriesPerSession: 60, emoji: '🏋️'),
  Exercise(id: 'b3', name: 'Jump Squats', category: 'bodyweight', description: 'Perform a squat then explosively jump up, landing softly back into squat position.', muscleGroup: 'Quads / Glutes / Calves', sets: 3, reps: '10-12 reps', difficulty: 'intermediate', caloriesPerSession: 80, emoji: '🦘'),
  Exercise(id: 'b4', name: 'Lunges', category: 'bodyweight', description: 'Step forward with one foot, lower back knee toward ground, push back to standing.', muscleGroup: 'Quads / Glutes / Hamstrings', sets: 3, reps: '10 each leg', difficulty: 'beginner', caloriesPerSession: 55, emoji: '🚶'),
  Exercise(id: 'b5', name: 'Bulgarian Split Squat', category: 'bodyweight', description: 'Rear foot elevated on bench, lower front knee toward ground keeping torso upright.', muscleGroup: 'Quads / Glutes', sets: 3, reps: '8-10 each', difficulty: 'intermediate', caloriesPerSession: 70, emoji: '🦵'),
  Exercise(id: 'b6', name: 'Plank', category: 'bodyweight', description: 'Hold forearm push-up position, maintaining a perfectly straight body from head to toe.', muscleGroup: 'Core / Shoulders', sets: 3, reps: '30-60 sec', difficulty: 'beginner', caloriesPerSession: 40, emoji: '⬛'),
  Exercise(id: 'b7', name: 'Side Plank', category: 'bodyweight', description: 'Support body on one forearm and side of foot, keeping body in a straight line.', muscleGroup: 'Obliques / Core', sets: 2, reps: '30 sec each side', difficulty: 'intermediate', caloriesPerSession: 35, emoji: '↔️'),
  Exercise(id: 'b8', name: 'Burpees', category: 'bodyweight', description: 'Drop to push-up, perform push-up, jump feet forward, jump up with arms raised. Full body!', muscleGroup: 'Full Body / Cardio', sets: 3, reps: '8-10 reps', difficulty: 'advanced', caloriesPerSession: 100, emoji: '🔥'),
  Exercise(id: 'b9', name: 'Mountain Climbers', category: 'bodyweight', description: 'In plank position, rapidly alternate driving knees toward chest like climbing a mountain.', muscleGroup: 'Core / Shoulders / Cardio', sets: 3, reps: '30 sec', difficulty: 'intermediate', caloriesPerSession: 75, emoji: '⛰️'),
  Exercise(id: 'b10', name: 'High Knees', category: 'bodyweight', description: 'Run in place, lifting knees as high as possible with each step, pumping arms.', muscleGroup: 'Quads / Core / Cardio', sets: 3, reps: '30 sec', difficulty: 'beginner', caloriesPerSession: 65, emoji: '🏃'),
  Exercise(id: 'b11', name: 'Jumping Jacks', category: 'bodyweight', description: 'Jump feet wide while raising arms overhead, then jump back together simultaneously.', muscleGroup: 'Full Body / Cardio', sets: 3, reps: '30 reps', difficulty: 'beginner', caloriesPerSession: 50, emoji: '⭐'),
  Exercise(id: 'b12', name: 'Glute Bridge', category: 'bodyweight', description: 'Lie on back with feet flat, lift hips until body forms straight line from shoulders to knees.', muscleGroup: 'Glutes / Hamstrings', sets: 3, reps: '15 reps', difficulty: 'beginner', caloriesPerSession: 40, emoji: '🌉'),
  Exercise(id: 'b13', name: 'Leg Raises', category: 'bodyweight', description: 'Lie flat, keep legs straight and raise them to 90 degrees, lower slowly without touching floor.', muscleGroup: 'Lower Abs / Core', sets: 3, reps: '12-15 reps', difficulty: 'intermediate', caloriesPerSession: 45, emoji: '🦵'),
  Exercise(id: 'b14', name: 'Flutter Kicks', category: 'bodyweight', description: 'Lie flat, raise legs 6 inches off ground, alternate kicking up and down in small pulses.', muscleGroup: 'Core / Hip Flexors', sets: 3, reps: '30 sec', difficulty: 'beginner', caloriesPerSession: 40, emoji: '🏊'),
  Exercise(id: 'b15', name: 'Russian Twists', category: 'bodyweight', description: 'Sit with knees bent, lean back 45°, rotate torso side to side touching ground each time.', muscleGroup: 'Obliques / Core', sets: 3, reps: '20 reps total', difficulty: 'beginner', caloriesPerSession: 45, emoji: '🔄'),
  // ── Dumbbell ──────────────────────────────────────────────────────────────
  Exercise(id: 'd1', name: 'Dumbbell Curl', category: 'dumbbell', description: 'Stand with dumbbells at sides, curl both up to shoulder height, lower slowly and controlled.', muscleGroup: 'Biceps', sets: 3, reps: '10-12 reps', difficulty: 'beginner', caloriesPerSession: 50, emoji: '💪'),
  Exercise(id: 'd2', name: 'Hammer Curl', category: 'dumbbell', description: 'Hold dumbbells with palms facing in, curl up keeping neutral grip throughout the movement.', muscleGroup: 'Biceps / Brachialis', sets: 3, reps: '10-12 reps', difficulty: 'beginner', caloriesPerSession: 50, emoji: '🔨'),
  Exercise(id: 'd3', name: 'Concentration Curl', category: 'dumbbell', description: 'Sit on bench, rest elbow on inner thigh, curl dumbbell toward shoulder for peak contraction.', muscleGroup: 'Biceps Peak', sets: 3, reps: '10 each arm', difficulty: 'beginner', caloriesPerSession: 45, emoji: '🎯'),
  Exercise(id: 'd4', name: 'Dumbbell Shoulder Press', category: 'dumbbell', description: 'Sit or stand, press dumbbells from shoulder level straight overhead, lower with control.', muscleGroup: 'Deltoids / Triceps', sets: 3, reps: '10-12 reps', difficulty: 'intermediate', caloriesPerSession: 60, emoji: '🏋️'),
  Exercise(id: 'd5', name: 'Arnold Press', category: 'dumbbell', description: 'Start with palms facing you at chest, rotate outward as you press the dumbbells overhead.', muscleGroup: 'Full Deltoid', sets: 3, reps: '10-12 reps', difficulty: 'intermediate', caloriesPerSession: 65, emoji: '💪'),
  Exercise(id: 'd6', name: 'Lateral Raise', category: 'dumbbell', description: 'Stand with slight elbow bend, raise dumbbells out to sides to shoulder height, lower slowly.', muscleGroup: 'Medial Deltoid', sets: 3, reps: '12-15 reps', difficulty: 'beginner', caloriesPerSession: 45, emoji: '✈️'),
  Exercise(id: 'd7', name: 'Front Raise', category: 'dumbbell', description: 'Stand with dumbbells in front, raise directly forward to shoulder height, lower with control.', muscleGroup: 'Anterior Deltoid', sets: 3, reps: '12 reps', difficulty: 'beginner', caloriesPerSession: 45, emoji: '⬆️'),
  Exercise(id: 'd8', name: 'Dumbbell Chest Press', category: 'dumbbell', description: 'Lie on bench, press dumbbells from chest level straight up, squeezing chest at top.', muscleGroup: 'Pectorals / Triceps', sets: 3, reps: '10-12 reps', difficulty: 'intermediate', caloriesPerSession: 65, emoji: '🏋️'),
  Exercise(id: 'd9', name: 'Dumbbell Fly', category: 'dumbbell', description: 'Lie on bench, open arms wide like wings, bring dumbbells together overhead in an arc.', muscleGroup: 'Pectorals', sets: 3, reps: '12 reps', difficulty: 'intermediate', caloriesPerSession: 55, emoji: '🦅'),
  Exercise(id: 'd10', name: 'Dumbbell Row', category: 'dumbbell', description: 'Hinge forward with flat back, pull dumbbells toward hips with elbows flaring back.', muscleGroup: 'Upper Back / Lats', sets: 3, reps: '10-12 reps', difficulty: 'intermediate', caloriesPerSession: 60, emoji: '🚣'),
  Exercise(id: 'd11', name: 'Single Arm Row', category: 'dumbbell', description: 'Place knee on bench, pull dumbbell from floor level to hip while keeping back perfectly flat.', muscleGroup: 'Lats / Rhomboids', sets: 3, reps: '10 each side', difficulty: 'intermediate', caloriesPerSession: 55, emoji: '💪'),
  Exercise(id: 'd12', name: 'Dumbbell Deadlift', category: 'dumbbell', description: 'Stand with dumbbells in front, hinge at hips keeping back flat, lower to mid-shin and drive up.', muscleGroup: 'Hamstrings / Glutes / Lower Back', sets: 3, reps: '10-12 reps', difficulty: 'intermediate', caloriesPerSession: 75, emoji: '🏋️'),
  Exercise(id: 'd13', name: 'Goblet Squat', category: 'dumbbell', description: 'Hold dumbbell vertically at chest level, squat down keeping torso upright and core tight.', muscleGroup: 'Quads / Glutes / Core', sets: 3, reps: '12-15 reps', difficulty: 'beginner', caloriesPerSession: 65, emoji: '🥤'),
  Exercise(id: 'd14', name: 'Dumbbell Lunges', category: 'dumbbell', description: 'Hold dumbbells at sides, step forward into lunge position, alternating legs with each rep.', muscleGroup: 'Quads / Glutes', sets: 3, reps: '10 each leg', difficulty: 'intermediate', caloriesPerSession: 65, emoji: '🚶'),
  Exercise(id: 'd15', name: 'Dumbbell Shrugs', category: 'dumbbell', description: 'Hold dumbbells at sides, shrug shoulders up toward ears, hold 1 second, lower slowly.', muscleGroup: 'Trapezius', sets: 3, reps: '15-20 reps', difficulty: 'beginner', caloriesPerSession: 40, emoji: '🤷'),
  Exercise(id: 'd16', name: 'Overhead Triceps Extension', category: 'dumbbell', description: 'Hold one dumbbell overhead with both hands, lower behind head, extend back up fully.', muscleGroup: 'Triceps', sets: 3, reps: '12 reps', difficulty: 'beginner', caloriesPerSession: 50, emoji: '💪'),
  Exercise(id: 'd17', name: 'Triceps Kickbacks', category: 'dumbbell', description: 'Hinge forward, keep upper arm parallel to floor, extend elbow backward until arm is straight.', muscleGroup: 'Triceps', sets: 3, reps: '12 each arm', difficulty: 'beginner', caloriesPerSession: 45, emoji: '💪'),
];