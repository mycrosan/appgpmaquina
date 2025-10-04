import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../entities/auth_token.dart';

/// Repositório abstrato para operações de autenticação
abstract class AuthRepository {
  /// Realiza login com username e password
  Future<Either<Failure, AuthToken>> login({
    required String username,
    required String password,
  });

  /// Realiza logout do usuário atual
  Future<Either<Failure, void>> logout();

  /// Obtém o usuário atual autenticado
  Future<Either<Failure, User>> getCurrentUser();

  /// Verifica se o usuário está autenticado
  Future<Either<Failure, bool>> isAuthenticated();

  /// Atualiza o token de acesso usando refresh token
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken);

  /// Salva o token de autenticação localmente
  Future<Either<Failure, void>> saveAuthToken(AuthToken token);

  /// Obtém o token de autenticação salvo localmente
  Future<Either<Failure, AuthToken?>> getAuthToken();

  /// Remove o token de autenticação salvo localmente
  Future<Either<Failure, void>> removeAuthToken();

  /// Salva as credenciais do usuário para login automático
  Future<Either<Failure, void>> saveUserCredentials({
    required String username,
    required String password,
  });

  /// Obtém as credenciais salvas do usuário
  Future<Either<Failure, Map<String, String>?>> getUserCredentials();

  /// Remove as credenciais salvas do usuário
  Future<Either<Failure, void>> removeUserCredentials();

  /// Verifica se existem credenciais salvas
  Future<Either<Failure, bool>> hasUserCredentials();

  /// Tenta fazer login automático com credenciais salvas
  Future<Either<Failure, AuthToken?>> tryAutoLogin();

  /// Verifica se a autenticação biométrica está disponível no dispositivo
  Future<Either<Failure, bool>> isBiometricAvailable();

  /// Verifica se a autenticação biométrica está habilitada pelo usuário
  Future<Either<Failure, bool>> isBiometricEnabled();

  /// Define se a autenticação biométrica está habilitada pelo usuário
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled);

  /// Realiza login utilizando autenticação biométrica
  Future<Either<Failure, User>> loginWithBiometrics();
}