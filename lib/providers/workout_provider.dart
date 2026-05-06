import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_session.dart';
import '../models/workout_set.dart';
import '../services/api_service.dart';

class WorkoutState {
  final WorkoutSession? session;
  final List<WorkoutSet> sets;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? aiFeedback;

  WorkoutState({
    this.session,
    this.sets = const [],
    this.isLoading = false,
    this.error,
    this.aiFeedback,
  });

  WorkoutState copyWith({
    WorkoutSession? session,
    List<WorkoutSet>? sets,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? aiFeedback,
  }) {
    return WorkoutState(
      session: session ?? this.session,
      sets: sets ?? this.sets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      aiFeedback: aiFeedback ?? this.aiFeedback,
    );
  }
}

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final ApiService _apiService;

  WorkoutNotifier(this._apiService) : super(WorkoutState());

  Future<void> fetchDailySession() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _apiService.getDailySession();
      state = state.copyWith(session: session, isLoading: false, sets: []);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar treino do dia.');
    }
  }

  void addSet(WorkoutSet set) {
    state = state.copyWith(sets: [...state.sets, set]);
  }

  void clearSets() {
    state = state.copyWith(sets: []);
  }

  void setSets(List<WorkoutSet> sets) {
    state = state.copyWith(sets: sets);
  }

  void updateSet(int index, WorkoutSet updatedSet) {
    final newSets = List<WorkoutSet>.from(state.sets);
    newSets[index] = updatedSet;
    state = state.copyWith(sets: newSets);
  }

  Future<bool> finishWorkout() async {
    if (state.session == null) return false;
    
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.finishWorkout(
        state.session!.id,
        state.session!.name,
        state.sets,
      );
      state = state.copyWith(isLoading: false, aiFeedback: response['aiFeedback']);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao finalizar treino.');
      return false;
    }
  }
}

final workoutProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier(ref.read(apiServiceProvider));
});
