import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para realizar logout do usuário
/// 
/// Remove a sessão atual e limpa dados de autenticação
class Logout implements UseCaseNoParams<void> {
  final AuthRepository repository;

  Logout(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    // Verifica se há um usuário logado
    final currentUserResult = await repository.getCurrentUser();
    
    return currentUserResult.fold(
      (failure) {
        // Se não há usuário logado, considera o logout como bem-sucedido
        if (failure is AuthenticationFailure) {
          return const Right(null);
        }
        return Left(failure);
      },
      (user) async {
        // Realiza o logout através do repositório
        return await repository.logout();
      },
    );
  }
}