class AiTarget {
  final double weight;
  final int reps;
  final int? rir;

  AiTarget({required this.weight, required this.reps, this.rir});

  factory AiTarget.fromJson(Map<String, dynamic> json) {
    return AiTarget(
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'],
      rir: json['rir'],
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String type;
  final String tip;
  final int orderIdx;
  final AiTarget? aiTarget;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.type,
    required this.tip,
    required this.orderIdx,
    this.aiTarget,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      muscleGroup: json['muscle_group_id'],
      equipment: json['equipment'],
      type: json['type'],
      tip: json['tip'] ?? '',
      orderIdx: json['order_idx'] ?? 0,
      aiTarget: json['ai_target'] != null ? AiTarget.fromJson(json['ai_target']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscle_group': muscleGroup,
      'equipment': equipment,
      'type': type,
      'tip': tip,
      'order_idx': orderIdx,
      'ai_target': aiTarget != null ? {
        'weight': aiTarget!.weight,
        'reps': aiTarget!.reps,
        'rir': aiTarget!.rir,
      } : null,
    };
  }
}

