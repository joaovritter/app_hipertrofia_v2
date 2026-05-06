import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_models.dart';
import '../models/exercise.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class OnboardingExercisesScreen extends ConsumerStatefulWidget {
  final List<TrainingDivision> divisions;
  const OnboardingExercisesScreen({super.key, required this.divisions});

  @override
  ConsumerState<OnboardingExercisesScreen> createState() =>
      _OnboardingExercisesScreenState();
}

class _OnboardingExercisesScreenState
    extends ConsumerState<OnboardingExercisesScreen> {
  final List<String> _days = [
    'Domingo',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
  ];
  List<Exercise> _allExercises = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await ref.read(apiServiceProvider).getAllExercises();
      setState(() {
        _allExercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleExercise(int dayIdx, String exerciseId) {
    setState(() {
      final exercises = List<String>.from(widget.divisions[dayIdx].exercises);
      if (exercises.contains(exerciseId)) {
        exercises.remove(exerciseId);
      } else {
        exercises.add(exerciseId);
      }
      widget.divisions[dayIdx].exercises = exercises;
    });
  }

  Future<void> _finishSetup() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(apiServiceProvider).setupTraining(widget.divisions);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar configuração.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final activeDays = widget.divisions.where((d) => !d.isRest).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Exercícios')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeDays.length,
              itemBuilder: (context, index) {
                final div = activeDays[index];
                final dayName = _days[div.dayOfWeek];

                // Filter exercises for this day's muscle groups
                final filteredExercises = _allExercises
                    .where((ex) => div.muscles.contains(ex.muscleGroup))
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Text(
                            dayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${div.name})',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ...filteredExercises.map((ex) {
                      final isSelected = div.exercises.contains(ex.id);
                      return CheckboxListTile(
                        title: Text(ex.name),
                        subtitle: Text(ex.muscleGroup.toUpperCase()),
                        value: isSelected,
                        onChanged: (_) => _toggleExercise(div.dayOfWeek, ex.id),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Theme.of(context).colorScheme.primary,
                        checkColor: Colors.black,
                      );
                    }).toList(),
                    const Divider(height: 32),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _finishSetup,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      'FINALIZAR CONFIGURAÇÃO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
