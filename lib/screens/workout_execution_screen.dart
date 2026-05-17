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
      _localSets[exerciseId] ??= [];
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
    final allSets = _localSets.values.expand((e) => e).toList();

    if (allSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Registre pelo menos uma série.'),
            ],
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

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
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(ref.read(workoutProvider).error ?? 'Erro ao finalizar treino.')),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutProvider);
    final session = workoutState.session;

    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('Erro ao carregar treino.')),
      );
    }

    if (!_initialized) _initializeSets(session);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          session.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: workoutState.isLoading ? null : _finishWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: workoutState.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text(
                      'FINALIZAR',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                    ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: session.exercises.length,
        itemBuilder: (context, index) {
          final exercise = session.exercises[index];
          final sets = _localSets[exercise.id] ?? [];

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${sets.length} séries',
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

                  // Meta IA
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: exercise.aiTarget != null
                          ? const Color(0xFF10B981).withOpacity(0.08)
                          : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: exercise.aiTarget != null
                            ? const Color(0xFF10B981).withOpacity(0.3)
                            : Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          exercise.aiTarget != null ? '🧠' : '🤖',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: exercise.aiTarget != null
                              ? RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 12),
                                    children: [
                                      TextSpan(
                                        text: 'Meta IA: ',
                                        style: TextStyle(color: Colors.grey[400]),
                                      ),
                                      TextSpan(
                                        text: '${exercise.aiTarget!.weight.toStringAsFixed(1)}kg · ${exercise.aiTarget!.reps} reps',
                                        style: const TextStyle(
                                          color: Color(0xFF10B981),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (exercise.aiTarget!.rir != null)
                                        TextSpan(
                                          text: ' · RIR ${exercise.aiTarget!.rir}',
                                          style: const TextStyle(color: Color(0xFF10B981)),
                                        ),
                                    ],
                                  ),
                                )
                              : Text(
                                  'Meta IA: Analisando seu progresso...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (sets.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Nenhuma série registrada',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 40),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text('TIPO', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold))),
                              const SizedBox(width: 8),
                              Expanded(flex: 2, child: Text('PESO (KG)', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold))),
                              const SizedBox(width: 8),
                              Expanded(flex: 2, child: Text('REPS', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold))),
                              const SizedBox(width: 8),
                              Expanded(flex: 2, child: Text('RIR', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold))),
                              const SizedBox(width: 32),
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
                                color: isWork
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                                    : Colors.white.withOpacity(0.02),
                                border: Border.all(
                                  color: isWork
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
                                      : Colors.white.withOpacity(0.05),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Icon(
                                      isWork ? Icons.flash_on : Icons.fitness_center,
                                      size: 16,
                                      color: isWork
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: () => _updateSet(
                                        exercise.id,
                                        setIdx,
                                        set.copyWith(type: isWork ? 'warmup' : 'work'),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isWork
                                              ? Theme.of(context).colorScheme.primary
                                              : Colors.grey[800],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          isWork ? 'WORK' : 'AQUEC.',
                                          style: TextStyle(
                                            color: isWork ? Colors.black : Colors.white70,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: _buildInputField((v) => _updateSet(exercise.id, setIdx, set.copyWith(weight: double.tryParse(v) ?? 0))),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: _buildInputField((v) => _updateSet(exercise.id, setIdx, set.copyWith(reps: int.tryParse(v) ?? 0))),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: _buildInputField(
                                      (v) => _updateSet(exercise.id, setIdx, set.copyWith(rir: int.tryParse(v))),
                                      highlight: isWork,
                                    ),
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

                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _addSet(exercise.id),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'ADICIONAR SÉRIE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(Function(String) onChanged, {bool highlight = false}) {
    return TextField(
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        isDense: true,
        hintText: '0',
        hintStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: highlight
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      ),
    );
  }
}