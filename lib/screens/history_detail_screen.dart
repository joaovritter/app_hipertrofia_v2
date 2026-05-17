import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_history.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class HistoryDetailScreen extends ConsumerStatefulWidget {
  final int sessionId;
  const HistoryDetailScreen({super.key, required this.sessionId});

  @override
  ConsumerState<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  WorkoutHistoryDetail? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final detail = await ref.read(apiServiceProvider).getWorkoutHistoryDetail(widget.sessionId);
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar detalhes do treino.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _detail == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Detalhe', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(_error ?? 'Sessão não encontrada', style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadDetails();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;
    final aiFeedback = detail.aiFeedback;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detalhe do Treino', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.sessionName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(detail.date),
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 28),

            if (aiFeedback != null) ...[
              _buildScoreHeader(aiFeedback),
              const SizedBox(height: 24),
              _buildAiAnalysis(aiFeedback),
              const SizedBox(height: 24),
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'A análise de IA está disponível apenas para treinos recentes.',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'REGISTRO DO TREINO',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${detail.details.length} exercícios',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...detail.details.map((ex) => _buildExerciseHistoryCard(ex)),

            if (aiFeedback != null && aiFeedback.nextSessionRecommendations.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildNextSessionCard(aiFeedback),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHeader(AiFeedback feedback) {
    final scoreColor = _getScoreColor(feedback.sessionScore);
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scoreColor.withOpacity(0.2), width: 8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: feedback.sessionScore / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${feedback.sessionScore}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'SCORE',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scoreColor.withOpacity(0.3)),
            ),
            child: Text(
              feedback.sessionLabel?.toUpperCase() ?? 'CONCLUÍDO',
              style: TextStyle(
                color: scoreColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAnalysis(AiFeedback feedback) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                'ANÁLISE GEMINI IA',
                style: TextStyle(
                  color: Colors.amber[200],
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            feedback.summary,
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          ...feedback.insights.map((insight) => _buildInsightTile(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightTile(AiInsight insight) {
    IconData icon;
    Color color;
    switch (insight.type) {
      case 'positive':
        icon = Icons.check_circle_outline;
        color = Colors.greenAccent;
        break;
      case 'warning':
        icon = Icons.error_outline;
        color = Colors.amberAccent;
        break;
      default:
        icon = Icons.lightbulb_outline;
        color = Colors.blueAccent;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.body,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseHistoryCard(ExerciseHistory ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                        ex.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ex.muscleGroup?.toUpperCase() ?? 'GERAL'} • ${ex.equipment?.toUpperCase() ?? ''}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
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
                    '${ex.sets.length} séries',
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 40),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text('TIPO', style: _headerStyle())),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: Text('PESO', style: _headerStyle())),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: Text('REPS', style: _headerStyle())),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: Text('RIR', style: _headerStyle())),
                ],
              ),
            ),
            ...ex.sets.asMap().entries.map((entry) {
              final set = entry.value;
              final isWork = set.type == 'work';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isWork
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                        : Colors.transparent,
                    border: Border.all(
                      color: isWork
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                          : Colors.transparent,
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
                        child: Text(
                          isWork ? 'WORK' : 'WARMUP',
                          style: TextStyle(
                            color: isWork ? Colors.white : Colors.grey[500],
                            fontSize: 11,
                            fontWeight: isWork ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${set.weight}kg',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text('${set.reps}', style: const TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text('${set.rir ?? '-'}', style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSessionCard(AiFeedback feedback) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Text(
                'PRÓXIMO TREINO',
                style: TextStyle(
                  color: Colors.green[300],
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...feedback.nextSessionRecommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.exercise,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey[400], fontSize: 13),
                            children: [
                              const TextSpan(text: 'Meta: '),
                              TextSpan(
                                text: rec.target,
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (rec.rir != null)
                                TextSpan(
                                  text: ' (RIR ${rec.rir})',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(
    color: Colors.grey[600],
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 60) return Colors.amberAccent;
    return Colors.redAccent;
  }
}