import 'exercise.dart';

class WorkoutSession {
  final int id;
  final String name;
  final List<String> muscles;
  final List<Exercise> exercises;
  final bool restDay;

  WorkoutSession({
    required this.id,
    required this.name,
    required this.muscles,
    required this.exercises,
    this.restDay = false,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    if (json['restDay'] == true) {
      return WorkoutSession(
        id: -1,
        name: 'Descanso',
        muscles: [],
        exercises: [],
        restDay: true,
      );
    }

    return WorkoutSession(
      id: json['id'],
      name: json['name'],
      muscles: List<String>.from(json['muscles'] ?? []),
      exercises: (json['exercises'] as List?)
              ?.map((e) => Exercise.fromJson(e))
              .toList() ??
          [],
      restDay: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscles': muscles,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'restDay': restDay,
    };
  }
}
