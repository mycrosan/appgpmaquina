import 'dart:convert';
import '../../domain/entities/auth_token.dart';

/// Modelo de dados para AuthToken que estende a entidade
/// Adiciona funcionalidades de serialização JSON
class AuthTokenModel extends AuthToken {
  const AuthTokenModel({
    required super.accessToken,
    super.refreshToken,
    super.tokenType,
    required super.expiresAt,
  });

  /// Cria um AuthTokenModel a partir de JSON
  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : DateTime.now().add(const Duration(hours: 1)), // Default 1 hora
    );
  }

  /// Cria um AuthTokenModel a partir de JSON de resposta de login
  factory AuthTokenModel.fromLoginResponse(Map<String, dynamic> json) {
    // Mapeia a resposta real da API GP
    // Formato: {"token": "...", "tipo": "Bearer", "status": true}
    
    // Extrai informações do JWT para determinar expiração
    DateTime expiresAt;
    try {
      final token = json['token'] as String;
      final parts = token.split('.');
      if (parts.length == 3) {
        // Decodifica o payload do JWT
        final payload = parts[1];
        // Adiciona padding se necessário
        final normalizedPayload = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
        final decodedBytes = base64Url.decode(normalizedPayload);
        final decodedPayload = utf8.decode(decodedBytes);
        final payloadJson = jsonDecode(decodedPayload) as Map<String, dynamic>;
        
        // Extrai o timestamp de expiração (exp)
        final exp = payloadJson['exp'] as int?;
        if (exp != null) {
          expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        } else {
          // Fallback: 1 hora a partir de agora
          expiresAt = DateTime.now().add(const Duration(hours: 1));
        }
      } else {
        // Fallback: 1 hora a partir de agora
        expiresAt = DateTime.now().add(const Duration(hours: 1));
      }
    } catch (e) {
      // Fallback: 1 hora a partir de agora
      expiresAt = DateTime.now().add(const Duration(hours: 1));
    }

    return AuthTokenModel(
      accessToken: json['token'] as String,
      refreshToken: null, // A API não retorna refresh token
      tokenType: json['tipo'] as String? ?? 'Bearer',
      expiresAt: expiresAt,
    );
  }

  /// Converte o AuthTokenModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  /// Cria um AuthTokenModel a partir de uma entidade AuthToken
  factory AuthTokenModel.fromEntity(AuthToken token) {
    return AuthTokenModel(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      tokenType: token.tokenType,
      expiresAt: token.expiresAt,
    );
  }

  /// Converte para entidade AuthToken
  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresAt: expiresAt,
    );
  }

  /// Cria uma cópia do AuthTokenModel com campos atualizados
  AuthTokenModel copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    DateTime? expiresAt,
  }) {
    return AuthTokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'AuthTokenModel(tokenType: $tokenType, expiresAt: $expiresAt, hasRefreshToken: ${refreshToken != null})';
  }
}