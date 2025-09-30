import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/machine_config.dart';
import '../repositories/machine_repository.dart';

/// Use case para selecionar uma matriz para a máquina
///
/// Este use case é responsável por configurar qual matriz
/// está aceita para a máquina naquele momento, vinculada
/// ao usuário/dispositivo.
class SelectMatrizForMachine
    implements UseCase<MachineConfig, SelectMatrizParams> {
  final MachineRepository repository;

  SelectMatrizForMachine(this.repository);

  @override
  Future<Either<Failure, MachineConfig>> call(SelectMatrizParams params) async {
    // Primeiro verifica se a matriz existe e está ativa
    final matrizResult = await repository.getMatrizById(params.matrizId);

    return matrizResult.fold((failure) => Left(failure), (matriz) async {
      if (!matriz.canBeUsed) {
        return Left(
          ValidationFailure(
            message:
                'A matriz selecionada não está ativa ou não pode ser usada',
          ),
        );
      }

      // Cria a configuração da máquina
      final machineConfig = MachineConfig(
        deviceId: params.deviceId,
        userId: params.userId,
        matrizId: params.matrizId,
        matriz: matriz,
        configuredAt: DateTime.now(),
      );

      // Salva a configuração (implementar no repository)
      return await repository.saveMachineConfig(machineConfig);
    });
  }
}

/// Parâmetros para o use case SelectMatrizForMachine
class SelectMatrizParams extends Equatable {
  final String deviceId;
  final String userId;
  final int matrizId;

  const SelectMatrizParams({
    required this.deviceId,
    required this.userId,
    required this.matrizId,
  });

  @override
  List<Object> get props => [deviceId, userId, matrizId];
}