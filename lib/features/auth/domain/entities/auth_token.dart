import 'package:equatable/equatable.dart';

/// Entidade que representa um token de autenticação
class AuthToken extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final DateTime expiresAt;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresAt,
  });

  /// Verifica se o token está expirado
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Verifica se o token está válido (não expirado)
  bool get isValid {
    return !isExpired;
  }

  /// Retorna o token formatado para uso em headers HTTP
  String get authorizationHeader {
    return '$tokenType $accessToken';
  }

  /// Cria uma cópia do token com campos atualizados
  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    DateTime? expiresAt,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType, expiresAt];

  @override
  String toString() {
    return 'AuthToken(tokenType: $tokenType, expiresAt: $expiresAt, hasRefreshToken: ${refreshToken != null})';
  }
}