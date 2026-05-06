import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState()) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    // In a real app, we might want to fetch user data here if we have a token
    // For now, if there's a token, we could assume we are logged in or wait for a fetch
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiService.register(name, email, password);
      // Auto login after register
      return await login(email, password);
    } catch (e) {
      print('ERRO NO REGISTRO: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao criar conta. E-mail já pode estar em uso.',
      );
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService.login(email, password);
      final user = User.fromJson(data['user']);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      print('ERRO NO LOGIN: $e');
      String errorMessage = 'Login falhou. Verifique suas credenciais.';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('connection timeout')) {
        errorMessage =
            'Erro de conexão: Verifique se o servidor está rodando e se o IP 10.0.2.2 está correto.';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});
