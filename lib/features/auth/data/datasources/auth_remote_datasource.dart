import '../models/auth_token_model.dart';
import '../models/user_model.dart';

/// Data source abstrato para operações remotas de autenticação
abstract class AuthRemoteDataSource {
  /// Realiza login com username e password
  Future<AuthTokenModel> login({
    required String username,
    required String password,
  });

  /// Obtém o usuário atual autenticado
  Future<UserModel> getCurrentUser(String token);

  /// Atualiza o token de acesso usando refresh token
  Future<AuthTokenModel> refreshToken(String refreshToken);

  /// Realiza logout no servidor
  Future<void> logout(String token);
}