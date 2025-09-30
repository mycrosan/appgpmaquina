import 'package:dartz/dartz.dart';
import 'dart:developer' as developer;
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/carcaca.dart';
import '../../domain/entities/matriz.dart';
import '../../domain/entities/machine_config.dart';
import '../../domain/repositories/machine_repository.dart';
import '../datasources/machine_remote_datasource_impl.dart';
import '../models/carcaca_model.dart';
import '../models/matriz_model.dart';
import '../models/machine_config_model.dart';

/// Implementação simplificada do repositório de máquina
/// Conecta apenas o datasource remoto com a camada de domínio
class MachineRepositoryImpl implements MachineRepository {
  final MachineRemoteDataSourceImpl remoteDataSource;

  MachineRepositoryImpl({
    required this.remoteDataSource,
  }) {
    developer.log('🏗️ MachineRepositoryImpl inicializado', name: 'MachineRepository');
  }
  
  // TODO: Implementar método para buscar todas as máquinas
  // @override
  // Future<Either<Failure, List<RegistroMaquina>>> getAllMachines() async {
  //   // Implementação futura
  // }

  @override
  Future<Either<Failure, List<Matriz>>> getAllMatrizes() async {
    developer.log('📋 Buscando todas as matrizes', name: 'MachineRepository');
    
    try {
      // Busca diretamente da API
      developer.log('🌐 Fazendo requisição para API remota', name: 'MachineRepository');
      final remoteMatrizes = await remoteDataSource.getAllMatrizes();
      developer.log('✅ Matrizes obtidas da API: ${remoteMatrizes.length} itens', name: 'MachineRepository');
      
      return Right(remoteMatrizes);
    } on ServerException catch (e) {
      AppLogger.error('Erro do servidor ao buscar matrizes: ${e.message}', name: 'MachineRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Erro de rede ao buscar matrizes: ${e.message}', name: 'MachineRepository');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Erro inesperado ao buscar matrizes: $e', name: 'MachineRepository');
      return Left(DeviceFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, MachineConfig?>> getCurrentMachineConfig(String deviceId, String userId) async {
    developer.log('🔍 Buscando configuração atual da máquina', name: 'MachineRepository');
    developer.log('  - Device ID: $deviceId', name: 'MachineRepository');
    developer.log('  - User ID: $userId', name: 'MachineRepository');
    
    try {
      // Busca sempre da API remota (sem cache)
      developer.log('🌐 Fazendo requisição para API remota', name: 'MachineRepository');
      final remoteConfig = await remoteDataSource.getCurrentMachineConfig(deviceId, userId);
      developer.log('✅ Configuração obtida da API', name: 'MachineRepository');
      developer.log('  - Matriz ID: ${remoteConfig.matrizId}', name: 'MachineRepository');
      
      return Right(remoteConfig);
    } on ServerException catch (e) {
      if (e.message.contains('not found') || 
          e.message.contains('404') || 
          e.message.contains('não encontrada')) {
        developer.log('ℹ️ Nenhuma configuração encontrada para este dispositivo/usuário', name: 'MachineRepository');
        return const Right(null);
      }
      AppLogger.error('Erro do servidor ao buscar configuração: ${e.message}', name: 'MachineRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Erro de rede ao buscar configuração: ${e.message}', name: 'MachineRepository');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Erro inesperado ao buscar configuração: $e', name: 'MachineRepository');
      return Left(DeviceFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, MachineConfig>> saveMachineConfig(MachineConfig config) async {
    developer.log('💾 Salvando configuração da máquina', name: 'MachineRepository');
    developer.log('  - Device ID: ${config.deviceId}', name: 'MachineRepository');
    developer.log('  - User ID: ${config.userId}', name: 'MachineRepository');
    developer.log('  - Matriz ID: ${config.matrizId}', name: 'MachineRepository');
    
    try {
      // Chama a API para salvar a configuração
      developer.log('🌐 Enviando configuração para API remota', name: 'MachineRepository');
      final updatedConfig = await remoteDataSource.selectMatrizForMachine(
        config.deviceId, 
        config.userId, 
        config.matrizId
      );
      developer.log('✅ Configuração salva na API com sucesso', name: 'MachineRepository');
      developer.log('  - Config ID: ${updatedConfig.id}', name: 'MachineRepository');
      developer.log('  - Configurada em: ${updatedConfig.configuredAt}', name: 'MachineRepository');
      
      return Right(updatedConfig);
    } on ServerException catch (e) {
      AppLogger.error('Erro do servidor ao salvar configuração: ${e.message}', name: 'MachineRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Erro de rede ao salvar configuração: ${e.message}', name: 'MachineRepository');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Erro inesperado ao salvar configuração: $e', name: 'MachineRepository');
      return Left(DeviceFailure(message: 'Unexpected error: $e'));
    }
  }

  // Implementações básicas para outros métodos da interface
  @override
  Future<Either<Failure, Carcaca>> getCarcacaByCodigo(String codigo) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, Carcaca>> getCarcacaById(int id) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, List<Carcaca>>> getAllCarcacas() async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, List<Carcaca>>> getCarcacasByMatriz(int matrizId) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, Carcaca>> createCarcaca(Carcaca carcaca) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, Carcaca>> updateCarcaca(Carcaca carcaca) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, void>> deleteCarcaca(int id) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, Matriz>> getMatrizById(int id) async {
    developer.log('🔍 Buscando matriz por ID: $id', name: 'MachineRepository');
    
    try {
      // Primeiro tenta buscar todas as matrizes
      final matrizesResult = await getAllMatrizes();
      
      return matrizesResult.fold(
        (failure) {
          developer.log('❌ Erro ao buscar matrizes para encontrar ID $id: ${failure.toString()}', name: 'MachineRepository');
          return Left(failure);
        },
        (matrizes) {
          try {
            final matriz = matrizes.firstWhere((m) => m.id == id);
            developer.log('✅ Matriz encontrada: ${matriz.nome} (${matriz.codigo})', name: 'MachineRepository');
            return Right(matriz);
          } catch (e) {
            developer.log('❌ Matriz com ID $id não encontrada', name: 'MachineRepository');
            return Left(DeviceFailure(message: 'Matriz com ID $id não encontrada'));
          }
        },
      );
    } catch (e) {
      developer.log('💥 Erro inesperado ao buscar matriz por ID: $e', name: 'MachineRepository');
      return Left(DeviceFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Matriz>> getMatrizByCodigo(String codigo) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, List<Matriz>>> getMatrizesByMarca(String marca) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, List<Matriz>>> getMatrizesByTamanho(String tamanho) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, Matriz>> createMatriz(Matriz matriz) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, Matriz>> updateMatriz(Matriz matriz) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, void>> deleteMatriz(int id) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, bool>> canProcessCarcaca(int carcacaId) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, List<Carcaca>>> searchCarcacas(String searchTerm) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, List<Matriz>>> searchMatrizes(String searchTerm) async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, void>> syncData() async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, bool>> hasPendingSync() async {
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, void>> removeMachineConfig(String deviceId, String userId) async {
    // Método não implementado - sem cache local
    return Left(DeviceFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<Failure, void>> removeAllActiveConfigsForDevice(String deviceId) async {
    try {
      developer.log(
        '🗑️ Removendo todas as configurações ativas para o dispositivo: $deviceId',
        name: 'MachineRepository',
      );

      await remoteDataSource.removeAllActiveConfigsForDevice(deviceId);
      
      developer.log(
        '✅ Todas as configurações ativas removidas com sucesso',
        name: 'MachineRepository',
      );
      
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error(
        'Erro do servidor ao remover configurações: ${e.message}',
        name: 'MachineRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error(
        'Erro de rede ao remover configurações: ${e.message}',
        name: 'MachineRepository',
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      AppLogger.error(
        'Erro inesperado ao remover configurações: $e',
        name: 'MachineRepository',
      );
      return Left(DeviceFailure(message: 'Erro inesperado: $e'));
    }
  }
}