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

  /// Salva as credenciais do usuário para login automático
  Future<void> saveUserCredentials({
    required String username,
    required String password,
  });

  /// Obtém as credenciais salvas do usuário
  Future<Map<String, String>?> getUserCredentials();

  /// Remove as credenciais salvas do usuário
  Future<void> removeUserCredentials();

  /// Verifica se existem credenciais salvas
  Future<bool> hasUserCredentials();

  /// Define se a autenticação biométrica está habilitada neste dispositivo
  Future<void> setBiometricEnabled(bool enabled);

  /// Verifica se a autenticação biométrica está habilitada neste dispositivo
  Future<bool> isBiometricEnabled();
}