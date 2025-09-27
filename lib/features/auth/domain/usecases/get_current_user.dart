import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para obter o usuário atualmente logado
/// 
/// Verifica se há uma sessão ativa e retorna os dados do usuário
class GetCurrentUser implements UseCaseNoParams<User> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User>> call() async {
    // Primeiro verifica se o token ainda é válido
    final tokenValidResult = await repository.isTokenValid();
    
    return tokenValidResult.fold(
      (failure) => Left(failure),
      (isValid) async {
        if (!isValid) {
          // Tenta renovar o token
          final refreshResult = await repository.refreshToken();
          
          return refreshResult.fold(
            (failure) => Left(AuthenticationFailure(
              message: 'Sessão expirada. Faça login novamente.',
            )),
            (newToken) async {
              // Com o token renovado, obtém o usuário atual
              return await repository.getCurrentUser();
            },
          );
        }

        // Token válido, obtém o usuário atual
        return await repository.getCurrentUser();
      },
    );
  }
}