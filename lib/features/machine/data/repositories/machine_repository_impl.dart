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
import '../datasources/machine_local_datasource_impl.dart';
import '../models/carcaca_model.dart';
import '../models/matriz_model.dart';
import '../models/machine_config_model.dart';

/// Implementação simplificada do repositório de máquina
/// Conecta os datasources remotos e locais com a camada de domínio
class MachineRepositoryImpl implements MachineRepository {
  final MachineRemoteDataSourceImpl remoteDataSource;
  final MachineLocalDataSourceImpl localDataSource;

  MachineRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  }) {
    developer.log('🏗️ MachineRepositoryImpl inicializado', name: 'MachineRepository');
  }

  @override
  Future<Either<Failure, List<Matriz>>> getAllMatrizes() async {
    developer.log('📋 Buscando todas as matrizes', name: 'MachineRepository');
    
    try {
      // Primeiro tenta buscar do cache local
      try {
        developer.log('💾 Tentando buscar matrizes do cache local', name: 'MachineRepository');
        final cachedMatrizes = await localDataSource.getCachedMatrizes();
        developer.log('✅ Matrizes encontradas no cache: ${cachedMatrizes.length} itens', name: 'MachineRepository');
        return Right(cachedMatrizes);
      } catch (e) {
        developer.log('ℹ️ Cache não disponível, buscando da API: $e', name: 'MachineRepository');
        
        // Se não há cache, busca da API
        developer.log('🌐 Fazendo requisição para API remota', name: 'MachineRepository');
        final remoteMatrizes = await remoteDataSource.getAllMatrizes();
        developer.log('✅ Matrizes obtidas da API: ${remoteMatrizes.length} itens', name: 'MachineRepository');
        
        // Salva no cache para próximas consultas
        developer.log('💾 Salvando matrizes no cache local', name: 'MachineRepository');
        await localDataSource.cacheMatrizes(remoteMatrizes);
        developer.log('✅ Matrizes salvas no cache com sucesso', name: 'MachineRepository');
        
        return Right(remoteMatrizes);
      }
    } on ServerException catch (e) {
      AppLogger.error('Erro do servidor ao buscar matrizes: ${e.message}', name: 'MachineRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Erro de rede ao buscar matrizes: ${e.message}', name: 'MachineRepository');
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      AppLogger.error('Erro de cache ao buscar matrizes: ${e.message}', name: 'MachineRepository');
      return Left(CacheFailure(message: e.message));
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
      // Primeiro tenta buscar do cache local
      developer.log('💾 Tentando buscar configuração do cache local', name: 'MachineRepository');
      final cachedConfig = await localDataSource.getCachedMachineConfig(deviceId, userId);
      if (cachedConfig != null) {
        developer.log('✅ Configuração encontrada no cache', name: 'MachineRepository');
        developer.log('  - Matriz ID: ${cachedConfig.matrizId}', name: 'MachineRepository');
        developer.log('  - Configurada em: ${cachedConfig.configuredAt}', name: 'MachineRepository');
        return Right(cachedConfig);
      }

      developer.log('ℹ️ Configuração não encontrada no cache, buscando da API', name: 'MachineRepository');
      
      // Se não há cache, busca da API
      developer.log('🌐 Fazendo requisição para API remota', name: 'MachineRepository');
      final remoteConfig = await remoteDataSource.getCurrentMachineConfig(deviceId, userId);
      developer.log('✅ Configuração obtida da API', name: 'MachineRepository');
      developer.log('  - Matriz ID: ${remoteConfig.matrizId}', name: 'MachineRepository');
      
      // Salva no cache para próximas consultas
      developer.log('💾 Salvando configuração no cache local', name: 'MachineRepository');
      await localDataSource.cacheMachineConfig(remoteConfig);
      developer.log('✅ Configuração salva no cache com sucesso', name: 'MachineRepository');
      
      return Right(remoteConfig);
    } on ServerException catch (e) {
      if (e.message.contains('not found') || e.message.contains('404')) {
        developer.log('ℹ️ Nenhuma configuração encontrada para este dispositivo/usuário', name: 'MachineRepository');
        return const Right(null);
      }
      AppLogger.error('Erro do servidor ao buscar configuração: ${e.message}', name: 'MachineRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Erro de rede ao buscar configuração: ${e.message}', name: 'MachineRepository');
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      AppLogger.error('Erro de cache ao buscar configuração: ${e.message}', name: 'MachineRepository');
      return Left(CacheFailure(message: e.message));
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
      
      // Atualiza o cache local
      developer.log('💾 Atualizando cache local com nova configuração', name: 'MachineRepository');
      await localDataSource.cacheMachineConfig(updatedConfig);
      developer.log('✅ Cache local atualizado com sucesso', name: 'MachineRepository');
      
      return Right(updatedConfig);
    } on ServerException catch (e) {
      AppLogger.error('Erro do servidor ao salvar configuração: ${e.message}', name: 'MachineRepository');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Erro de rede ao salvar configuração: ${e.message}', name: 'MachineRepository');
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      AppLogger.error('Erro de cache ao salvar configuração: ${e.message}', name: 'MachineRepository');
      return Left(CacheFailure(message: e.message));
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
    try {
      // Remove do cache local
      await localDataSource.removeCachedMachineConfig(deviceId, userId);
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(DeviceFailure(message: 'Unexpected error: $e'));
    }
  }
}