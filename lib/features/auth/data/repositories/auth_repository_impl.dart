import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
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
      
      return tokenResult.fold(
        (failure) => Left(failure),
        (authToken) async {
          if (authToken == null) {
            return Left(AuthenticationFailure(message: 'Token não encontrado'));
          }
          
          final userModel = await remoteDataSource.getCurrentUser(authToken.accessToken);
          return Right(userModel.toEntity());
        },
      );
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
}