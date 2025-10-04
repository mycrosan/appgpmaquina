part of 'auth_bloc.dart';

/// Eventos do BLoC de autenticação
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para verificar o status de autenticação
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Evento para realizar login com usuário e senha
class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

/// Evento para realizar logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Evento para realizar login via biometria
class AuthBiometricLoginRequested extends AuthEvent {
  const AuthBiometricLoginRequested();
}

/// Evento para habilitar/desabilitar biometria neste dispositivo
class AuthSetBiometricEnabled extends AuthEvent {
  final bool enabled;

  const AuthSetBiometricEnabled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}