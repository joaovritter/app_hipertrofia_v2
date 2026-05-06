class WorkoutHistoryDetail {
  final int id;
  final String sessionName;
  final DateTime date;
  final AiFeedback? aiFeedback;
  final List<ExerciseHistory> details;

  WorkoutHistoryDetail({
    required this.id,
    required this.sessionName,
    required this.date,
    this.aiFeedback,
    required this.details,
  });

  factory WorkoutHistoryDetail.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryDetail(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      sessionName: json['session_name'] ?? 'Treino sem nome',
      date: DateTime.parse(json['date']),
      aiFeedback: json['ai_feedback'] != null ? AiFeedback.fromJson(json['ai_feedback']) : null,
      details: (json['details'] as List? ?? []).map((e) => ExerciseHistory.fromJson(e)).toList(),
    );
  }
}

class AiFeedback {
  final int sessionScore;
  final String? sessionLabel;
  final String summary;
  final List<AiInsight> insights;
  final List<AiRecommendation> nextSessionRecommendations;

  AiFeedback({
    required this.sessionScore,
    this.sessionLabel,
    required this.summary,
    required this.insights,
    required this.nextSessionRecommendations,
  });

  factory AiFeedback.fromJson(Map<String, dynamic> json) {
    return AiFeedback(
      sessionScore: int.tryParse(json['sessionScore']?.toString() ?? '') ?? 0,
      sessionLabel: json['sessionLabel'],
      summary: json['summary'] ?? '',
      insights: (json['insights'] as List? ?? []).map((e) => AiInsight.fromJson(e)).toList(),
      nextSessionRecommendations: (json['nextSession']?['recommendations'] as List? ?? [])
          .map((e) => AiRecommendation.fromJson(e))
          .toList(),
    );
  }
}

class AiInsight {
  final String type; // positive, warning, info
  final String title;
  final String body;

  AiInsight({required this.type, required this.title, required this.body});

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      type: json['type'] ?? 'info',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
    );
  }
}

class AiRecommendation {
  final String exercise;
  final String target;
  final int? rir;

  AiRecommendation({required this.exercise, required this.target, this.rir});

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      exercise: json['exercise'] ?? '',
      target: json['target'] ?? '',
      rir: json['rir'],
    );
  }
}

class ExerciseHistory {
  final String name;
  final String? muscleGroup;
  final String? equipment;
  final List<WorkoutSetHistory> sets;

  ExerciseHistory({
    required this.name,
    this.muscleGroup,
    this.equipment,
    required this.sets,
  });

  factory ExerciseHistory.fromJson(Map<String, dynamic> json) {
    return ExerciseHistory(
      name: json['name'] ?? '',
      muscleGroup: json['muscle_group'],
      equipment: json['equipment'],
      sets: (json['sets'] as List? ?? []).map((e) => WorkoutSetHistory.fromJson(e)).toList(),
    );
  }
}

class WorkoutSetHistory {
  final double weight;
  final int reps;
  final int? rir;
  final String type;

  WorkoutSetHistory({required this.weight, required this.reps, this.rir, required this.type});

  factory WorkoutSetHistory.fromJson(Map<String, dynamic> json) {
    return WorkoutSetHistory(
      weight: double.tryParse(json['weight']?.toString() ?? '') ?? 0.0,
      reps: int.tryParse(json['reps']?.toString() ?? '') ?? 0,
      rir: json['rir'] != null ? int.tryParse(json['rir'].toString()) : null,
      type: json['type'] ?? 'work',
    );
  }
}
