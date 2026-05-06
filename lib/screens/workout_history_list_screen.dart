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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Histórico', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_outlined, color: Colors.blue), // Highlight active tab
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              // Logout logic usually involves AuthProvider
              // Since this is a simple screen, we can just pop to home and let it handle logout
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white)))
              : _history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey[800]),
                          const SizedBox(height: 16),
                          Text('Nenhum treino registrado ainda.', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final session = _history[index];
                        final date = DateTime.parse(session['date']);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.grey[900],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary, size: 20),
                            ),
                            title: Text(
                              session['session_name'],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(date),
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryDetailScreen(sessionId: session['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
