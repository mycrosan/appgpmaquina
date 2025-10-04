import 'package:dartz/dartz.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_token_model.dart';

/// Implementação do repositório de autenticação
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthToken>> login({
    required String username,
    required String password,
  }) async {
    try {
      final authTokenModel = await remoteDataSource.login(
        username: username,
        password: password,
      );

      // Salva o token localmente
      await localDataSource.saveAuthToken(authTokenModel);

      return Right(authTokenModel.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Remove o token localmente
      await localDataSource.removeAuthToken();

      // Notifica o servidor
      try {
        await remoteDataSource.logout("");
      } catch (e) {
        // Ignora erros do servidor no logout
      }

      return Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthToken?>> getAuthToken() async {
    try {
      final authTokenModel = await localDataSource.getAuthToken();
      return Right(authTokenModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    try {
      final authTokenModel = await remoteDataSource.refreshToken(refreshToken);

      // Salva o novo token localmente
      await localDataSource.saveAuthToken(authTokenModel);

      return Right(authTokenModel.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Primeiro obtém o token salvo localmente
      final tokenResult = await getAuthToken();

      return tokenResult.fold((failure) => Left(failure), (authToken) async {
        if (authToken == null) {
          return Left(AuthenticationFailure(message: 'Token não encontrado'));
        }

        final userModel = await remoteDataSource.getCurrentUser(
          authToken.accessToken,
        );
        return Right(userModel.toEntity());
      });
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTokenLocally(AuthToken token) async {
    try {
      final authTokenModel = AuthTokenModel.fromEntity(token);
      await localDataSource.saveAuthToken(authTokenModel);
      return Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeTokenLocally() async {
    try {
      await localDataSource.removeAuthToken();
      return Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await localDataSource.getAuthToken();
      if (token == null) {
        return Right(false);
      }

      // Verifica se o token não expirou
      final authToken = token.toEntity();
      return Right(!authToken.isExpired);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAuthToken(AuthToken token) async {
    return saveTokenLocally(token);
  }

  @override
  Future<Either<Failure, void>> removeAuthToken() async {
    return removeTokenLocally();
  }

  @override
  Future<Either<Failure, void>> saveUserCredentials({
    required String username,
    required String password,
  }) async {
    try {
      await localDataSource.saveUserCredentials(
        username: username,
        password: password,
      );
      return Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>?>> getUserCredentials() async {
    try {
      final credentials = await localDataSource.getUserCredentials();
      return Right(credentials);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeUserCredentials() async {
    try {
      await localDataSource.removeUserCredentials();
      return Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserCredentials() async {
    try {
      final hasCredentials = await localDataSource.hasUserCredentials();
      return Right(hasCredentials);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthToken?>> tryAutoLogin() async {
    try {
      // Verifica se há credenciais salvas
      final credentials = await localDataSource.getUserCredentials();
      if (credentials == null) {
        return Right(null);
      }

      // Tenta fazer login com as credenciais salvas
      final loginResult = await login(
        username: credentials['username']!,
        password: credentials['password']!,
      );

      return loginResult.fold(
        (failure) => Left(failure),
        (token) => Right(token),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricAvailable() async {
    try {
      AppLogger.auth('Verificando disponibilidade da biometria...', name: 'Biometric');
      final localAuth = LocalAuthentication();
      final canCheck = await localAuth.canCheckBiometrics;
      final isSupported = await localAuth.isDeviceSupported();
      AppLogger.debug('canCheckBiometrics=$canCheck, isDeviceSupported=$isSupported', name: 'Biometric');
      AppLogger.auth('Biometria disponível: ${canCheck && isSupported}', name: 'Biometric');
      return Right(canCheck && isSupported);
    } catch (e) {
      AppLogger.error('Erro ao verificar biometria', name: 'Biometric', error: e);
      return Left(DeviceFailure(message: 'Erro ao verificar biometria: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricEnabled() async {
    try {
      if (AppConstants.biometricsGloballyDisabled) {
        AppLogger.warning('Biometria desativada globalmente', name: 'Biometric');
        return const Right(false);
      }
      AppLogger.auth('Consultando flag de biometria habilitada...', name: 'Biometric');
      final enabled = await localDataSource.isBiometricEnabled();
      AppLogger.auth('Biometria habilitada: $enabled', name: 'Biometric');
      return Right(enabled);
    } on CacheException catch (e) {
      AppLogger.error('Erro de cache ao consultar biometria habilitada', name: 'Biometric', error: e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Erro inesperado ao consultar biometria habilitada', name: 'Biometric', error: e);
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithBiometrics() async {
    try {
      if (AppConstants.biometricsGloballyDisabled) {
        AppLogger.warning('Tentativa de login biométrico bloqueada: desativado globalmente', name: 'Biometric');
        return Left(AuthenticationFailure(
          message: AppConstants.biometricTemporarilyDisabledMessage,
        ));
      }
      AppLogger.auth('Iniciando autenticação biométrica...', name: 'Biometric');
      final localAuth = LocalAuthentication();
      final types = await localAuth.getAvailableBiometrics();
      AppLogger.debug('Tipos biométricos disponíveis: $types', name: 'Biometric');
      final didAuthenticate = await localAuth.authenticate(
        localizedReason: AppConstants.biometricReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!didAuthenticate) {
        AppLogger.warning('Autenticação biométrica cancelada/negada pelo usuário', name: 'Biometric');
        return Left(AuthenticationFailure(
          message: AppConstants.biometricErrorMessage,
        ));
      }

      // Recupera credenciais salvas para efetuar o login
      final credentials = await localDataSource.getUserCredentials();
      if (credentials == null) {
        AppLogger.error('Credenciais salvas não encontradas para login biométrico', name: 'Biometric');
        return Left(AuthenticationFailure(
          message: 'Credenciais não encontradas para login biométrico',
        ));
      }

      AppLogger.auth('Autenticação biométrica aprovada. Efetuando login com credenciais salvas...', name: 'Biometric');
      final loginResult = await login(
        username: credentials['username']!,
        password: credentials['password']!,
      );

      return await loginResult.fold(
        (failure) => Left(failure),
        (_) async {
          final userResult = await getCurrentUser();
          return userResult.fold(
            (failure) => Left(failure),
            (user) {
              AppLogger.success('Login biométrico concluído para usuário: ${user.username ?? user.name ?? user.email ?? user.id}', name: 'Biometric');
              return Right(user);
            },
          );
        },
      );
    } on AuthenticationException catch (e) {
      AppLogger.error('Falha de autenticação biométrica', name: 'Biometric', error: e);
      return Left(AuthenticationFailure(message: e.message));
    } on CacheException catch (e) {
      AppLogger.error('Erro de cache durante login biométrico', name: 'Biometric', error: e);
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      AppLogger.error('Erro de servidor durante login biométrico', name: 'Biometric', error: e);
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Erro de rede durante login biométrico', name: 'Biometric', error: e);
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Erro inesperado durante login biométrico', name: 'Biometric', error: e);
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled) async {
    try {
      AppLogger.auth('Definindo biometria habilitada para: $enabled', name: 'Biometric');
      await localDataSource.setBiometricEnabled(enabled);
      AppLogger.success('Preferência de biometria salva: $enabled', name: 'Biometric');
      return const Right(null);
    } on CacheException catch (e) {
      AppLogger.error('Erro de cache ao salvar preferência de biometria', name: 'Biometric', error: e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Erro inesperado ao salvar preferência de biometria', name: 'Biometric', error: e);
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }
}