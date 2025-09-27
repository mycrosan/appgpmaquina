/// Exceção base para todas as exceções customizadas da aplicação
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exceção para erros de servidor/API
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required String message,
    this.statusCode,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exceção para erros de rede/conectividade
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exceção para erros de cache/armazenamento local
class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exceção para erros de autenticação
class AuthenticationException extends AppException {
  const AuthenticationException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exceção para erros de validação
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required String message,
    this.fieldErrors,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() {
    String base = 'ValidationException: $message';
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      base += '\nField errors: ${fieldErrors.toString()}';
    }
    return base;
  }
}

/// Exceção para erros de dispositivo (biometria, permissões, etc.)
class DeviceException extends AppException {
  const DeviceException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exceção para erros de hardware (Tasmota, válvulas, etc.)
class HardwareException extends AppException {
  const HardwareException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}