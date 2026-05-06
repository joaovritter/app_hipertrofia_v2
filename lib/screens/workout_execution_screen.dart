import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_set.dart';
import '../models/workout_session.dart';
import '../models/exercise.dart';
import '../providers/workout_provider.dart';
import 'feedback_screen.dart';

class WorkoutExecutionScreen extends ConsumerStatefulWidget {
  const WorkoutExecutionScreen({super.key});

  @override
  ConsumerState<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends ConsumerState<WorkoutExecutionScreen> {
  final Map<String, List<WorkoutSet>> _localSets = {};
  bool _initialized = false;

  void _initializeSets(WorkoutSession session) {
    if (_initialized) return;
    for (var exercise in session.exercises) {
      _localSets[exercise.id] = List.generate(
        4,
        (index) => WorkoutSet(
          exerciseId: exercise.id,
          weight: 0,
          reps: 0,
          rir: 0,
          type: 'work',
        ),
      );
    }
    _initialized = true;
  }

  void _addSet(String exerciseId) {
    setState(() {
      if (!_localSets.containsKey(exerciseId)) {
        _localSets[exerciseId] = [];
      }
      _localSets[exerciseId]!.add(WorkoutSet(
        exerciseId: exerciseId,
        weight: 0,
        reps: 0,
        rir: 0,
        type: 'work',
      ));
    });
  }

  void _removeSet(String exerciseId, int index) {
    setState(() {
      if (_localSets.containsKey(exerciseId) && _localSets[exerciseId]!.length > index) {
        _localSets[exerciseId]!.removeAt(index);
      }
    });
  }

  void _updateSet(String exerciseId, int setIndex, WorkoutSet updatedSet) {
    setState(() {
      _localSets[exerciseId]![setIndex] = updatedSet;
    });
  }

  Future<void> _finishWorkout() async {
    // Collect all sets
    final allSets = _localSets.values.expand((element) => element).toList();
    
    if (allSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registre pelo menos uma série.')),
      );
      return;
    }

    // Update sets in provider
    ref.read(workoutProvider.notifier).setSets(allSets);

    final success = await ref.read(workoutProvider.notifier).finishWorkout();
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FeedbackScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(workoutProvider).error ?? 'Erro ao finalizar treino. Verifique sua conexão.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutProvider);
    final session = workoutState.session;

    if (session == null) return const Scaffold(body: Center(child: Text('Erro ao carregar treino.')));

    // Initialize sets if not already done
    if (!_initialized) {
      _initializeSets(session);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(session.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: workoutState.isLoading ? null : _finishWorkout,
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: workoutState.isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    'FINALIZAR',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2
                    ),
                  ),
            ),
          ),
        ],
      ),
      body: workoutState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: session.exercises.length,
              itemBuilder: (context, index) {
                final exercise = session.exercises[index];
                final sets = _localSets[exercise.id] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey[800]!, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    exercise.tip.isNotEmpty ? exercise.tip : 'Foco na execução',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${sets.length} SÉRIES',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: exercise.aiTarget != null 
                                ? const Color(0xFF10B981).withOpacity(0.1)
                                : Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: exercise.aiTarget != null 
                                  ? const Color(0xFF10B981).withOpacity(0.3)
                                  : Colors.grey[800]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(exercise.aiTarget != null ? '🧠' : '🤖', style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: exercise.aiTarget != null 
                                  ? RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
                                        children: [
                                          const TextSpan(text: 'Meta IA: ', style: TextStyle(fontWeight: FontWeight.normal)),
                                          TextSpan(text: '${exercise.aiTarget!.weight.toStringAsFixed(1)}kg'),
                                          const TextSpan(text: ' - '),
                                          TextSpan(text: '${exercise.aiTarget!.reps} reps'),
                                          if (exercise.aiTarget!.rir != null) ...[
                                            const TextSpan(text: ' - '),
                                            TextSpan(text: 'RIR ${exercise.aiTarget!.rir}'),
                                          ],
                                        ],
                                      ),
                                    )
                                  : Text(
                                      'Meta IA: Analisando seu progresso...',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (sets.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text('Nenhuma série registrada', style: TextStyle(color: Colors.grey[600])),
                            ),
                          )
                        else
                          Column(
                            children: [
                              // Header
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, left: 40),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text('TIPO', style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 8),
                                    Expanded(flex: 2, child: Text('PESO (KG)', style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 8),
                                    Expanded(flex: 2, child: Text('REPS', style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 8),
                                    Expanded(flex: 2, child: Text('RIR', style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 32), // space for delete button
                                  ],
                                ),
                              ),
                              ...sets.asMap().entries.map((entry) {
                                final setIdx = entry.key;
                                final set = entry.value;
                                final isWork = set.type == 'work';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: isWork 
                                          ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1)
                                          : Border.all(color: Colors.transparent),
                                      color: isWork 
                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                                          : Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Icon(
                                            isWork ? Icons.flash_on : Icons.fitness_center,
                                            size: 16,
                                            color: isWork ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: GestureDetector(
                                            onTap: () {
                                              _updateSet(exercise.id, setIdx, set.copyWith(type: isWork ? 'warmup' : 'work'));
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              decoration: BoxDecoration(
                                                color: isWork ? Theme.of(context).colorScheme.primary : Colors.grey[800],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                isWork ? 'TRABALHO' : 'AQUEC.',
                                                style: TextStyle(
                                                  color: isWork ? Colors.black : Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(flex: 2, child: _buildInputField(null, (v) => _updateSet(exercise.id, setIdx, set.copyWith(weight: double.tryParse(v) ?? 0)))),
                                        const SizedBox(width: 8),
                                        Expanded(flex: 2, child: _buildInputField(null, (v) => _updateSet(exercise.id, setIdx, set.copyWith(reps: int.tryParse(v) ?? 0)))),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2, 
                                          child: _buildInputField(
                                            null, 
                                            (v) => _updateSet(exercise.id, setIdx, set.copyWith(rir: int.tryParse(v))),
                                            highlight: isWork,
                                          )
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                                          onPressed: () => _removeSet(exercise.id, setIdx),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _addSet(exercise.id),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('ADICIONAR SÉRIE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                  side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInputField(String? label, Function(String) onChanged, {bool highlight = false}) {
    return TextField(
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        isDense: true,
        hintText: label ?? '0',
        hintStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: highlight ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: highlight ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      ),
    );
  }
}

