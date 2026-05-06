class WorkoutSet {
  final String exerciseId;
  final String type; // 'work', 'warmup', 'failure'
  final double weight;
  final int reps;
  final int? rir;
  final bool completed;

  WorkoutSet({
    required this.exerciseId,
    this.type = 'work',
    required this.weight,
    required this.reps,
    this.rir,
    this.completed = true,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      exerciseId: json['exercise_id'],
      type: json['type'] ?? 'work',
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'],
      rir: json['rir'],
      completed: json['completed'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'type': type,
      'weight': weight,
      'reps': reps,
      'rir': rir,
      'completed': completed,
    };
  }

  WorkoutSet copyWith({
    String? exerciseId,
    String? type,
    double? weight,
    int? reps,
    int? rir,
    bool? completed,
  }) {
    return WorkoutSet(
      exerciseId: exerciseId ?? this.exerciseId,
      type: type ?? this.type,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rir: rir ?? this.rir,
      completed: completed ?? this.completed,
    );
  }
}

