import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC responsável por gerenciar o estado de autenticação
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final Login loginUseCase;

  AuthBloc({
    required this.authRepository,
    required this.loginUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await authRepository.isAuthenticated();
      await result.fold(
        (failure) async => emit(AuthUnauthenticated(message: _getFailureMessage(failure))),
        (isAuthenticated) async {
          if (isAuthenticated) {
            await _loadCurrentUser(emit);
          } else {
            emit(const AuthUnauthenticated());
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
      final result = await loginUseCase(LoginParams(
        username: event.username,
        password: event.password,
      ));
      
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null);
        emit(AuthUnauthenticated(message: _getFailureMessage(failure)));
      } else {
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
        (failure) => emit(AuthUnauthenticated(message: _getFailureMessage(failure))),
        (_) => emit(const AuthUnauthenticated()),
      );
    } catch (e) {
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }

  Future<void> _loadCurrentUser(Emitter<AuthState> emit) async {
    try {
      final result = await authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(AuthUnauthenticated(message: _getFailureMessage(failure))),
        (user) => emit(AuthAuthenticated(user: user)),
      );
    } catch (e) {
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }

  String _getFailureMessage(dynamic failure) {
    if (failure.toString().contains('AuthenticationFailure')) {
      return 'Credenciais inválidas';
    } else if (failure.toString().contains('NetworkFailure')) {
      return 'Erro de conexão';
    } else if (failure.toString().contains('ServerFailure')) {
      return 'Erro do servidor';
    } else {
      return 'Erro inesperado';
    }
  }
}