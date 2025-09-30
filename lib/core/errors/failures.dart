import 'package:equatable/equatable.dart';

/// Classe abstrata base para todas as falhas da aplicação
/// Seguindo o padrão de Clean Architecture para tratamento de erros
abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]) : super();

  @override
  List<Object> get props => [];
}

/// Falhas relacionadas ao servidor/API
class ServerFailure extends Failure {
  final String message;
  final int? statusCode;

  const ServerFailure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// Falhas relacionadas à conectividade
class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

/// Falhas relacionadas ao cache/armazenamento local
class CacheFailure extends Failure {
  final String message;

  const CacheFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

/// Falhas relacionadas à autenticação
class AuthenticationFailure extends Failure {
  final String message;

  const AuthenticationFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

/// Falhas relacionadas à validação de dados
class ValidationFailure extends Failure {
  final String message;
  final Map<String, String>? errors;

  const ValidationFailure({
    required this.message,
    this.errors,
  });

  @override
  List<Object> get props => [message, errors ?? {}];
}

/// Falhas relacionadas à autorização
class AuthorizationFailure extends Failure {
  final String message;

  const AuthorizationFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

/// Falhas relacionadas a recursos não encontrados
class NotFoundFailure extends Failure {
  final String message;

  const NotFoundFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

/// Falhas relacionadas ao dispositivo (biometria, permissões, etc.)
class DeviceFailure extends Failure {
  final String message;

  const DeviceFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

/// Falhas relacionadas ao controle de hardware (Tasmota)
class HardwareFailure extends Failure {
  final String message;

  const HardwareFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}