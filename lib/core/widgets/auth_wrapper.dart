import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';

/// Widget que gerencia o estado de autenticação e navega entre login e home
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authBloc = context.read<AuthBloc>();

    // Configura credenciais padrão se não existirem
    await _setupDefaultCredentials();

    // Verifica o estado de autenticação ao inicializar
    authBloc.add(const AuthCheckRequested());
  }

  Future<void> _setupDefaultCredentials() async {
    try {
      final authBloc = context.read<AuthBloc>();
      final hasCredentials = await authBloc.authRepository.hasUserCredentials();

      await hasCredentials.fold(
        (failure) async {
          // Em caso de erro, configura as credenciais padrão
          await authBloc.authRepository.saveUserCredentials(
            username: 'carlos',
            password: '8950',
          );
        },
        (hasCredentials) async {
          if (!hasCredentials) {
            // Se não há credenciais salvas, configura as padrão
            await authBloc.authRepository.saveUserCredentials(
              username: 'carlos',
              password: '8950',
            );
          }
        },
      );
    } catch (e) {
      // Em caso de erro, ignora e continua
      print('Erro ao configurar credenciais padrão: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthAuthenticated) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}