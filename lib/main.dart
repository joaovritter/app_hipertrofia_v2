import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: HyperTrackApp()));
}

class HyperTrackApp extends ConsumerWidget {
  const HyperTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'BalaTrofia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E676),
          brightness: Brightness.dark,
          surface: const Color(0xFF121212),
          primary: const Color(0xFF00E676),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),

      // Adicionado por Fares Mahmud
      // Enquanto o app verifica o token salvo, mostra uma tela de loading
      // com a cor principal do app. Evita o usuário ver a tela de login
      // por um segundo mesmo já estando autenticado.
      home: authState.isCheckingAuth
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00E676),
                ),
              ),
            )
          : authState.user == null
              ? const LoginScreen()
              : const HomeScreen(),
    );
  }
}