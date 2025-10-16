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
  /// Busca através das configurações de máquina para encontrar
  /// qual máquina está associada ao dispositivo atual
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

      // 2. Buscar todas as máquinas disponíveis
      final maquinasResult = await repository.getAllMaquinas();

      return maquinasResult.fold(
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

          if (maquinas.isEmpty) {
            developer.log(
              '⚠️ Nenhuma máquina encontrada no sistema',
              name: 'GetCurrentDeviceMachine',
            );
            return const Right(null);
          }

          // 3. Tentar encontrar uma máquina através de configurações existentes
          // Procurar por máquinas que tenham configurações ativas para este dispositivo
          for (final maquina in maquinas) {
            if (maquina.id != null) {
              // Verificar se esta máquina tem configurações para este dispositivo
              // Isso seria feito através de um método no repositório que busca
              // configurações por registroMaquinaId e deviceId
              
              // Por enquanto, vamos usar uma heurística baseada no nome/descrição
              // que pode conter informações do dispositivo
              if (_isMachineAssociatedWithDevice(maquina, deviceId)) {
                developer.log(
                  '✅ Máquina encontrada através de associação: ${maquina.nome}',
                  name: 'GetCurrentDeviceMachine',
                );
                return Right(maquina);
              }
            }
          }

          // 4. Se não encontrou através de configurações, aplicar lógica de prioridade
          final prioritizedMachine = _selectMachineByPriority(maquinas);
          
          if (prioritizedMachine != null) {
            developer.log(
              '📌 Máquina selecionada por prioridade: ${prioritizedMachine.nome}',
              name: 'GetCurrentDeviceMachine',
            );
            return Right(prioritizedMachine);
          }

          developer.log(
            '⚠️ Nenhuma máquina adequada encontrada',
            name: 'GetCurrentDeviceMachine',
          );
          return const Right(null);
        },
      );
    } catch (e) {
      developer.log(
        '❌ Erro inesperado ao buscar máquina do dispositivo: $e',
        name: 'GetCurrentDeviceMachine',
      );
      return Left(DeviceFailure(message: 'Erro ao buscar máquina: $e'));
    }
  }

  /// Verifica se uma máquina está associada ao dispositivo
  /// através de informações na descrição, número de série, etc.
  bool _isMachineAssociatedWithDevice(RegistroMaquina maquina, String deviceId) {
    // Verificar se o deviceId está presente em campos da máquina
    final searchFields = [
      maquina.numeroSerie,
      maquina.descricao,
      maquina.observacoes,
    ];

    for (final field in searchFields) {
      if (field != null && field.contains(deviceId)) {
        return true;
      }
    }

    return false;
  }

  /// Seleciona uma máquina baseada em critérios de prioridade
  RegistroMaquina? _selectMachineByPriority(List<RegistroMaquina> maquinas) {
    // 1. Priorizar máquinas ativas e operacionais
    final operationalMachines = maquinas.where((m) => m.isOperational).toList();
    
    if (operationalMachines.isNotEmpty) {
      // 2. Priorizar máquinas com informações mais completas
      operationalMachines.sort((a, b) {
        int scoreA = _calculateMachineScore(a);
        int scoreB = _calculateMachineScore(b);
        return scoreB.compareTo(scoreA); // Ordem decrescente
      });
      
      return operationalMachines.first;
    }

    // 3. Se não há máquinas operacionais, retornar a primeira ativa
    final activeMachines = maquinas.where((m) => m.ativo).toList();
    if (activeMachines.isNotEmpty) {
      return activeMachines.first;
    }

    // 4. Como último recurso, retornar a primeira máquina disponível
    return maquinas.isNotEmpty ? maquinas.first : null;
  }

  /// Calcula uma pontuação para a máquina baseada na completude das informações
  int _calculateMachineScore(RegistroMaquina maquina) {
    int score = 0;
    
    // Pontos por informações preenchidas
    if (maquina.numeroSerie?.isNotEmpty == true) score += 2;
    if (maquina.modelo?.isNotEmpty == true) score += 2;
    if (maquina.fabricante?.isNotEmpty == true) score += 1;
    if (maquina.localizacao?.isNotEmpty == true) score += 1;
    if (maquina.responsavel?.isNotEmpty == true) score += 1;
    
    // Pontos por status
    if (maquina.status == 'ATIVA') score += 3;
    if (maquina.ativo) score += 2;
    
    // Pontos por data de criação (máquinas mais recentes têm prioridade)
    if (maquina.criadoEm != null) {
      final daysSinceCreation = DateTime.now().difference(maquina.criadoEm!).inDays;
      if (daysSinceCreation < 30) score += 2; // Máquinas criadas nos últimos 30 dias
      else if (daysSinceCreation < 90) score += 1; // Máquinas criadas nos últimos 90 dias
    }
    
    return score;
  }
}