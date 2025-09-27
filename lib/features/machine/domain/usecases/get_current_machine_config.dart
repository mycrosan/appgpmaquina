import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/machine_config.dart';
import '../repositories/machine_repository.dart';

/// Use case para buscar a configuração atual da máquina
/// 
/// Este use case é responsável por recuperar a configuração
/// atual da máquina para um dispositivo e usuário específicos.
class GetCurrentMachineConfig implements UseCase<MachineConfig?, GetMachineConfigParams> {
  final MachineRepository repository;

  GetCurrentMachineConfig(this.repository);

  @override
  Future<Either<Failure, MachineConfig?>> call(GetMachineConfigParams params) async {
    return await repository.getCurrentMachineConfig(params.deviceId, params.userId);
  }
}

/// Parâmetros para o use case GetCurrentMachineConfig
class GetMachineConfigParams extends Equatable {
  final String deviceId;
  final String userId;

  const GetMachineConfigParams({
    required this.deviceId,
    required this.userId,
  });

  @override
  List<Object> get props => [deviceId, userId];
}