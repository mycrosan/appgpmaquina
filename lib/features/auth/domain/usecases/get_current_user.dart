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
    // Primeiro verifica se o usuário está autenticado
    final isAuthenticatedResult = await repository.isAuthenticated();
    
    return isAuthenticatedResult.fold(
      (failure) => Left(failure),
      (isAuthenticated) async {
        if (!isAuthenticated) {
          // Tenta fazer login automático se há credenciais salvas
          final autoLoginResult = await repository.tryAutoLogin();
          
          return autoLoginResult.fold(
            (failure) => Left(AuthenticationFailure(
              message: 'Usuário não autenticado. Faça login.',
            )),
            (token) async {
              if (token == null) {
                return Left(AuthenticationFailure(
                  message: 'Usuário não autenticado. Faça login.',
                ));
              }
              // Com o token obtido, obtém o usuário atual
              return await repository.getCurrentUser();
            },
          );
        }

        // Usuário autenticado, obtém o usuário atual
        return await repository.getCurrentUser();
      },
    );
  }
}