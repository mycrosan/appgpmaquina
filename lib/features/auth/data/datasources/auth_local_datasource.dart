import '../models/auth_token_model.dart';

/// Data source abstrato para operações locais de autenticação
abstract class AuthLocalDataSource {
  /// Salva o token de autenticação localmente
  Future<void> saveAuthToken(AuthTokenModel token);

  /// Obtém o token de autenticação salvo localmente
  Future<AuthTokenModel?> getAuthToken();

  /// Remove o token de autenticação salvo localmente
  Future<void> removeAuthToken();

  /// Verifica se existe um token salvo localmente
  Future<bool> hasAuthToken();
}