import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/login_with_biometrics.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/errors/failures.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC responsável por gerenciar o estado de autenticação
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final Login loginUseCase;
  final LoginWithBiometrics loginWithBiometricsUseCase;

  AuthBloc({
    required this.authRepository,
    required this.loginUseCase,
    required this.loginWithBiometricsUseCase,
  })
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthBiometricLoginRequested>(_onAuthBiometricLoginRequested);
    on<AuthSetBiometricEnabled>(_onAuthSetBiometricEnabled);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await authRepository.isAuthenticated();
      await result.fold(
        (failure) async =>
            emit(AuthUnauthenticated(message: _getFailureMessage(failure))),
        (isAuthenticated) async {
          if (isAuthenticated) {
            await _loadCurrentUser(emit);
          } else {
            // Tenta login automático se não há token válido
            await _tryAutoLogin(emit);
          }
        },
      );
    } catch (e) {
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await loginUseCase(
        LoginParams(username: event.username, password: event.password),
      );

      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null);
        emit(AuthUnauthenticated(message: _getFailureMessage(failure)));
      } else {
        // Login bem-sucedido, salva as credenciais para login automático
        await authRepository.saveUserCredentials(
          username: event.username,
          password: event.password,
        );
        await _loadCurrentUser(emit);
      }
    } catch (e) {
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await authRepository.logout();
      result.fold(
        (failure) =>
            emit(AuthUnauthenticated(message: _getFailureMessage(failure))),
        (_) => emit(const AuthUnauthenticated()),
      );
    } catch (e) {
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }

  Future<void> _onAuthBiometricLoginRequested(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.auth('Evento recebido: AuthBiometricLoginRequested', name: 'Biometric');
    emit(AuthLoading());

    try {
      final result = await loginWithBiometricsUseCase();
      result.fold(
        (failure) {
          final message = _getFailureMessage(failure);
          AppLogger.error('Falha no login biométrico: $message', name: 'Biometric');
          emit(AuthUnauthenticated(message: message));
        },
        (user) {
          final display = user.username ?? user.name ?? user.email ?? user.id?.toString() ?? 'desconhecido';
          AppLogger.success('Login biométrico bem-sucedido para $display', name: 'Biometric');
          emit(AuthAuthenticated(user: user));
        },
      );
    } catch (e) {
      AppLogger.error('Exceção ao processar login biométrico', name: 'Biometric', error: e);
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }

  Future<void> _onAuthSetBiometricEnabled(
    AuthSetBiometricEnabled event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.auth('Atualizando preferência de biometria para: ${event.enabled}', name: 'Biometric');
      await authRepository.setBiometricEnabled(event.enabled);
      AppLogger.success('Preferência de biometria atualizada: ${event.enabled}', name: 'Biometric');
      // Não altera estado de autenticação; apenas persiste preferência
    } catch (_) {
      AppLogger.error('Erro ao atualizar preferência de biometria', name: 'Biometric');
      // Ignora erros silenciosamente para não quebrar fluxo de login
    }
  }

  Future<void> _loadCurrentUser(Emitter<AuthState> emit) async {
    try {
      final result = await authRepository.getCurrentUser();
      result.fold(
        (failure) =>
            emit(AuthUnauthenticated(message: _getFailureMessage(failure))),
        (user) => emit(AuthAuthenticated(user: user)),
      );
    } catch (e) {
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }

  Future<void> _tryAutoLogin(Emitter<AuthState> emit) async {
    try {
      final result = await authRepository.tryAutoLogin();
      await result.fold(
        (failure) async {
          // Se falhar o login automático, emite estado não autenticado sem mensagem de erro
          emit(const AuthUnauthenticated());
        },
        (token) async {
          if (token != null) {
            // Login automático bem-sucedido, carrega o usuário atual
            await _loadCurrentUser(emit);
          } else {
            // Não há credenciais salvas
            emit(const AuthUnauthenticated());
          }
        },
      );
    } catch (e) {
      // Em caso de erro, emite estado não autenticado sem mensagem
      emit(const AuthUnauthenticated());
    }
  }

  String _getFailureMessage(dynamic failure) {
    // Prioriza mensagens detalhadas vindas dos Failures para exibir o body do servidor
    if (failure is AuthenticationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return failure.message;
    } else if (failure is AuthorizationFailure) {
      return failure.message;
    } else {
      // Fallback genérico
      return failure?.toString() ?? 'Erro inesperado';
    }
  }
}