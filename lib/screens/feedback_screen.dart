import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_provider.dart';
import 'workout_history_list_screen.dart';

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(workoutProvider);
    final feedback = workoutState.aiFeedback;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'BalaTrofia',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Histórico',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WorkoutHistoryListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF10B981).withOpacity(0.12),
              const Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 38,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'TREINO CONCLUÍDO!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ótimo trabalho, continue assim.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
                const SizedBox(height: 28),
                if (feedback != null) ...[
                  _buildScoreCard(context, feedback['sessionScore'] ?? 0, feedback['sessionLabel']),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildAnalysisCard(context, feedback),
                          const SizedBox(height: 16),
                          if (feedback['nextSession']?['recommendations'] != null)
                            _buildNextStepsCard(context, feedback['nextSession']['recommendations']),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ] else
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'VOLTAR PARA A HOME',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, dynamic score, String? label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Text(
            'SUA PERFORMANCE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              height: 1,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, Map<String, dynamic> feedback) {
    final insights = (feedback['insights'] as List? ?? []);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Text(
                  'ANÁLISE DA IA',
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
              feedback['summary'] ?? 'Análise concluída com sucesso.',
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            if (insights.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.white12),
              ),
              ...insights.map(
                (insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _getInsightIcon(insight['type']),
                        color: _getInsightColor(insight['type']),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              insight['body'] ?? '',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNextStepsCard(BuildContext context, List recommendations) {
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
              const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Text(
                'PRÓXIMOS PASSOS',
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
          ...recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
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
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13),
                        children: [
                          TextSpan(
                            text: '${rec['exercise']}: ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          TextSpan(
                            text: rec['target'],
                            style: const TextStyle(color: Color(0xFF10B981)),
                          ),
                        ],
                      ),
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

  IconData _getInsightIcon(String? type) {
    switch (type) {
      case 'positive': return Icons.check_circle_outline;
      case 'warning': return Icons.error_outline;
      default: return Icons.lightbulb_outline;
    }
  }

  Color _getInsightColor(String? type) {
    switch (type) {
      case 'positive': return Colors.greenAccent;
      case 'warning': return Colors.amberAccent;
      default: return Colors.blueAccent;
    }
  }
}