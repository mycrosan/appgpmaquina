import 'package:dartz/dartz.dart';
import 'dart:developer' as developer;

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/machine_repository.dart';

/// Use case para remover todas as configurações ativas de um dispositivo
/// 
/// Este use case é usado quando há múltiplas configurações ativas para o mesmo
/// dispositivo, causando erro 500 na busca da configuração atual.
class RemoveAllActiveConfigsForDevice implements UseCase<void, String> {
  final MachineRepository repository;

  RemoveAllActiveConfigsForDevice(this.repository);

  @override
  Future<Either<Failure, void>> call(String deviceId) async {
    developer.log(
      '🗑️ Iniciando remoção de todas as configurações ativas para o dispositivo: $deviceId',
      name: 'RemoveAllActiveConfigsForDevice',
    );

    if (deviceId.isEmpty) {
      developer.log(
        '❌ Device ID não pode estar vazio',
        name: 'RemoveAllActiveConfigsForDevice',
      );
      return Left(ValidationFailure(message: 'Device ID não pode estar vazio'));
    }

    final result = await repository.removeAllActiveConfigsForDevice(deviceId);

    return result.fold(
      (failure) {
        String errorMessage = 'Erro desconhecido';
        if (failure is ServerFailure) {
          errorMessage = failure.message;
        } else if (failure is NetworkFailure) {
          errorMessage = failure.message;
        } else if (failure is ValidationFailure) {
          errorMessage = failure.message;
        } else if (failure is DeviceFailure) {
          errorMessage = failure.message;
        }
        
        developer.log(
          '💥 Erro ao remover configurações: $errorMessage',
          name: 'RemoveAllActiveConfigsForDevice',
        );
        return Left(failure);
      },
      (_) {
        developer.log(
          '✅ Todas as configurações ativas removidas com sucesso',
          name: 'RemoveAllActiveConfigsForDevice',
        );
        return const Right(null);
      },
    );
  }
}