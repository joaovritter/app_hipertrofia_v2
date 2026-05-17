import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'history_detail_screen.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryListScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryListScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryListScreen> createState() => _WorkoutHistoryListScreenState();
}

class _WorkoutHistoryListScreenState extends ConsumerState<WorkoutHistoryListScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final history = await ref.read(apiServiceProvider).getWorkoutHistory();
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar histórico.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Histórico',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_outlined, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          setState(() => _isLoading = true);
                          _fetchHistory();
                        },
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center_outlined, size: 64, color: Colors.grey[700]),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum treino registrado ainda.',
                            style: TextStyle(color: Colors.grey[500], fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete seu primeiro treino para ver o histórico.',
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      onRefresh: () async {
                        setState(() => _isLoading = true);
                        await _fetchHistory();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final session = _history[index];
                          final date = DateTime.parse(session['date']);

                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistoryDetailScreen(sessionId: session['id']),
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.fitness_center,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          session['session_name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat("dd 'de' MMMM 'às' HH:mm", 'pt_BR').format(date),
                                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}