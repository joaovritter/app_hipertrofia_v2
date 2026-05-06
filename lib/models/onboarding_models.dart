class MuscleGroup {
  final String id;
  final String name;

  MuscleGroup({required this.id, required this.name});

  factory MuscleGroup.fromJson(Map<String, dynamic> json) {
    return MuscleGroup(id: json['id'], name: json['name']);
  }
}

class TrainingDivision {
  int dayOfWeek; // 0 = Segunda, 6 = Domingo
  String name;
  List<String> muscles;
  List<String> exercises;
  bool isRest;

  TrainingDivision({
    required this.dayOfWeek,
    this.name = '',
    this.muscles = const [],
    this.exercises = const [],
    this.isRest = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek == 7
          ? 0
          : dayOfWeek, // Convert 7 (Domingo) para 0 para a API
      'name': name,
      'muscles': muscles,
      'exercises': exercises,
    };
  }
}
