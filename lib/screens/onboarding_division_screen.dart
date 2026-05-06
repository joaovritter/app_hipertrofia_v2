import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_models.dart';
import '../services/api_service.dart';
import 'onboarding_exercises_screen.dart';

class OnboardingDivisionScreen extends ConsumerStatefulWidget {
  const OnboardingDivisionScreen({super.key});

  @override
  ConsumerState<OnboardingDivisionScreen> createState() =>
      _OnboardingDivisionScreenState();
}

class _OnboardingDivisionScreenState
    extends ConsumerState<OnboardingDivisionScreen> {
  final List<String> _days = [
    'Domingo',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
  ];
  late List<TrainingDivision> _divisions;
  List<MuscleGroup> _allMuscles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _divisions = List.generate(
      7,
      (index) => TrainingDivision(dayOfWeek: index),
    );
    _loadMuscles();
  }

  Future<void> _loadMuscles() async {
    try {
      final muscles = await ref.read(apiServiceProvider).getMuscleGroups();
      setState(() {
        _allMuscles = muscles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleMuscle(int dayIdx, String muscleId) {
    setState(() {
      final muscles = List<String>.from(_divisions[dayIdx].muscles);
      if (muscles.contains(muscleId)) {
        muscles.remove(muscleId);
      } else {
        muscles.add(muscleId);
      }
      _divisions[dayIdx].muscles = muscles;
      _divisions[dayIdx].isRest = muscles.isEmpty;

      // Auto-generate name based on muscles
      if (muscles.isNotEmpty) {
        _divisions[dayIdx].name = muscles
            .map((id) => _allMuscles.firstWhere((m) => m.id == id).name)
            .join(' & ');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Divisão'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Quais dias e o que você treina?',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final div = _divisions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: div.isRest
                          ? Colors.blueGrey
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      child: Text(_days[index][0]),
                    ),
                    title: Text(
                      _days[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      div.isRest ? 'Descanso' : div.name,
                      style: TextStyle(
                        color: div.isRest
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _allMuscles.map((muscle) {
                            final isSelected = div.muscles.contains(muscle.id);
                            return FilterChip(
                              label: Text(muscle.name),
                              selected: isSelected,
                              onSelected: (_) =>
                                  _toggleMuscle(index, muscle.id),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OnboardingExercisesScreen(divisions: _divisions),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'PRÓXIMO: ESCOLHER EXERCÍCIOS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
