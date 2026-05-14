import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  // Adicionado por Fares Mahmud
  // Flag que indica se o app ainda está verificando o token salvo.
  // Evita jogar o usuário pra tela de login antes de checar se ele já estava logado.
  final bool isCheckingAuth;

  AuthState({this.user, this.isLoading = false, this.error, this.isCheckingAuth = true});

  AuthState copyWith({User? user, bool? isLoading, String? error, bool? isCheckingAuth}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCheckingAuth: isCheckingAuth ?? this.isCheckingAuth,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState()) {
    _checkInitialAuth();
  }

  // Adicionado por Fares Mahmud
  // Verifica se existe um token salvo ao abrir o app.
  // Se existir, marca o usuário como autenticado sem precisar logar de novo.
  // Ao terminar, desativa o isCheckingAuth pra o app decidir qual tela mostrar.
  Future<void> _checkInitialAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      state = state.copyWith(
        user: User(id: 0, name: '', email: ''),
        isCheckingAuth: false,
      );
    } else {
      state = state.copyWith(isCheckingAuth: false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiService.register(name, email, password);
      return await login(email, password);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is ApiException ? e.message : 'Erro ao criar conta. E-mail já pode estar em uso.',
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
      // Adicionado por Fares Mahmud
      // Agora usa ApiException diretamente, sem precisar checar strings de erro.
      state = state.copyWith(
        isLoading: false,
        error: e is ApiException ? e.message : 'Login falhou. Verifique suas credenciais.',
      );
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