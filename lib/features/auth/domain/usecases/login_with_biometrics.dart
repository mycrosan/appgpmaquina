import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para realizar login com autenticação biométrica
/// 
/// Verifica se a biometria está disponível e habilitada antes de tentar autenticar
class LoginWithBiometrics implements UseCaseNoParams<User> {
  final AuthRepository repository;

  LoginWithBiometrics(this.repository);

  @override
  Future<Either<Failure, User>> call() async {
    // Verifica se a biometria está disponível no dispositivo
    final biometricAvailableResult = await repository.isBiometricAvailable();
    
    return biometricAvailableResult.fold(
      (failure) => Left(failure),
      (isAvailable) async {
        if (!isAvailable) {
          return Left(DeviceFailure(
            message: 'Autenticação biométrica não está disponível neste dispositivo',
          ));
        }

        // Verifica se a biometria está habilitada para o usuário
        final biometricEnabledResult = await repository.isBiometricEnabled();
        
        return biometricEnabledResult.fold(
          (failure) => Left(failure),
          (isEnabled) async {
            if (!isEnabled) {
              return Left(AuthenticationFailure(
                message: 'Autenticação biométrica não está habilitada para este usuário',
              ));
            }

            // Realiza o login biométrico
            return await repository.loginWithBiometrics();
          },
        );
      },
    );
  }
}