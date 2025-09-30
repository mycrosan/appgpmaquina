import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/device_info_service.dart';
import '../entities/registro_maquina.dart';
import '../repositories/registro_maquina_repository.dart';
import 'dart:developer' as developer;

/// Use case para obter a máquina atual configurada para este dispositivo
class GetCurrentDeviceMachine {
  final RegistroMaquinaRepository repository;
  final DeviceInfoService deviceInfoService;

  GetCurrentDeviceMachine({
    required this.repository,
    required this.deviceInfoService,
  });

  /// Obtém a máquina atual configurada para este dispositivo
  ///
  /// Retorna a última máquina configurada para o device ID atual,
  /// ou null se nenhuma máquina foi configurada ainda
  Future<Either<Failure, RegistroMaquina?>> call() async {
    try {
      developer.log(
        '🔍 Iniciando busca da máquina atual do dispositivo',
        name: 'GetCurrentDeviceMachine',
      );

      // 1. Obter o device ID
      final deviceId = await deviceInfoService.getDeviceId();
      developer.log(
        '📱 Device ID obtido: $deviceId',
        name: 'GetCurrentDeviceMachine',
      );

      // 2. Buscar todas as máquinas
      final result = await repository.getAllMaquinas();

      return result.fold(
        (failure) {
          developer.log(
            '❌ Erro ao buscar máquinas: $failure',
            name: 'GetCurrentDeviceMachine',
          );
          return Left(failure);
        },
        (maquinas) {
          developer.log(
            '📋 Total de máquinas encontradas: ${maquinas.length}',
            name: 'GetCurrentDeviceMachine',
          );

          // 3. Filtrar máquinas que foram configuradas para este dispositivo
          // Assumindo que existe um campo deviceId na entidade Maquina
          // ou que podemos identificar através de algum outro campo

          // Por enquanto, vamos retornar a primeira máquina como fallback
          // TODO: Implementar lógica específica baseada em como as máquinas
          // são associadas aos dispositivos no seu sistema

          if (maquinas.isEmpty) {
            developer.log(
              'ℹ️ Nenhuma máquina encontrada',
              name: 'GetCurrentDeviceMachine',
            );
            return const Right(null);
          }

          // Retorna a primeira máquina por enquanto
          // Esta lógica deve ser ajustada conforme a regra de negócio
          final currentMachine = maquinas.first;
          developer.log(
            '✅ Máquina atual encontrada: ${currentMachine.nome} (ID: ${currentMachine.id})',
            name: 'GetCurrentDeviceMachine',
          );

          return Right(currentMachine);
        },
      );
    } catch (e) {
      developer.log(
        '❌ Erro inesperado ao buscar máquina atual: $e',
        name: 'GetCurrentDeviceMachine',
      );
      return Left(ServerFailure(message: 'Erro ao buscar máquina atual: $e'));
    }
  }
}