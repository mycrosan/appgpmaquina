import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/regra.dart';
import '../../domain/entities/processo_injecao.dart';
import '../../domain/repositories/injection_repository.dart';
import '../datasources/injection_local_datasource.dart';
import '../datasources/injection_remote_datasource.dart';
import '../models/regra_model.dart';
import '../models/processo_injecao_model.dart';

/// Implementação concreta do repositório de injeção
/// Conecta as fontes de dados local e remota com o domínio
class InjectionRepositoryImpl implements InjectionRepository {
  final InjectionRemoteDataSource remoteDataSource;
  final InjectionLocalDataSource localDataSource;

  InjectionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Regra>> getRegraByMatrizId(int matrizId) async {
    try {
      // Tenta buscar no cache local primeiro
      try {
        final cachedRegra = await localDataSource.getCachedRegraByMatrizId(matrizId);
        return Right(cachedRegra);
      } on CacheException {
        // Se não encontrar no cache, busca remotamente
      }

      // Busca remotamente
      final remoteRegra = await remoteDataSource.getRegraByMatrizId(matrizId);
      
      // Salva no cache
      await localDataSource.cacheRegra(remoteRegra);
      
      return Right(remoteRegra);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } on CacheException {
      return const Left(CacheFailure(message: 'Erro no cache'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Regra>> getRegraById(int id) async {
    try {
      // Tenta buscar no cache local primeiro
      try {
        final cachedRegra = await localDataSource.getCachedRegra(id);
        return Right(cachedRegra);
      } on CacheException {
        // Se não encontrar no cache, busca remotamente
      }

      // Busca remotamente
      final remoteRegra = await remoteDataSource.getRegraById(id);
      
      // Salva no cache
      await localDataSource.cacheRegra(remoteRegra);
      
      return Right(remoteRegra);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } on CacheException {
      return const Left(CacheFailure(message: 'Erro no cache'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Regra>>> getAllRegras() async {
    try {
      // Tenta buscar no cache local primeiro
      try {
        final cachedRegras = await localDataSource.getCachedRegras();
        if (cachedRegras.isNotEmpty) {
          return Right(cachedRegras);
        }
      } on CacheException {
        // Se não encontrar no cache, busca remotamente
      }

      // Busca remotamente
      final remoteRegras = await remoteDataSource.getRegras();
      
      // Salva no cache
      await localDataSource.cacheRegras(remoteRegras);
      
      return Right(remoteRegras);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } on CacheException {
      return const Left(CacheFailure(message: 'Erro no cache'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Regra>> createRegra(Regra regra) async {
    try {
      final regraModel = RegraModel.fromEntity(regra);
      final createdRegra = await remoteDataSource.createRegra(regraModel);
      
      // Salva no cache
      await localDataSource.cacheRegra(createdRegra);
      
      return Right(createdRegra);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } on ValidationException {
      return const Left(ValidationFailure(message: 'Dados inválidos'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Regra>> updateRegra(Regra regra) async {
    try {
      final regraModel = RegraModel.fromEntity(regra);
      final updatedRegra = await remoteDataSource.updateRegra(regraModel);
      
      // Atualiza no cache
      await localDataSource.cacheRegra(updatedRegra);
      
      return Right(updatedRegra);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } on ValidationException {
      return const Left(ValidationFailure(message: 'Dados inválidos'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRegra(int id) async {
    try {
      await remoteDataSource.deleteRegra(id);
      
      // Remove do cache
      await localDataSource.removeCachedRegra(id);
      
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProcessoInjecao>> startInjectionProcess({
    required int carcacaId,
    required int regraId,
    required int userId,
  }) async {
    try {
      final processo = await remoteDataSource.startProcesso(
        carcacaId: carcacaId,
        carcacaCodigo: '', // Será preenchido pelo datasource
        regraId: regraId,
        pressaoInicial: 0.0, // Será definido pela regra
      );
      
      // Salva no cache
      await localDataSource.cacheProcesso(processo);
      
      return Right(processo);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } on ValidationException {
      return const Left(ValidationFailure(message: 'Dados inválidos'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProcessoInjecao>> pauseInjectionProcess(String processoId) async {
    try {
      final processo = await remoteDataSource.pauseProcesso(processoId);
      
      // Atualiza no cache
      await localDataSource.cacheProcesso(processo);
      
      return Right(processo);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProcessoInjecao>> resumeInjectionProcess(String processoId) async {
    try {
      final processo = await remoteDataSource.resumeProcesso(processoId);
      
      // Atualiza no cache
      await localDataSource.cacheProcesso(processo);
      
      return Right(processo);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProcessoInjecao>> cancelInjectionProcess(
    String processoId, 
    String motivo,
  ) async {
    try {
      final processo = await remoteDataSource.cancelProcesso(
        processoId: processoId,
        motivo: motivo,
      );
      
      // Atualiza no cache
      await localDataSource.cacheProcesso(processo);
      
      return Right(processo);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProcessoInjecao>> finishInjectionProcess(
    String processoId, {
    String? observacoes,
  }) async {
    try {
      final processo = await remoteDataSource.finishProcesso(
        processoId: processoId,
        pressaoFinal: 0.0, // Será obtida do hardware
        observacoes: observacoes,
      );
      
      // Atualiza no cache
      await localDataSource.cacheProcesso(processo);
      
      return Right(processo);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProcessoInjecao>> getProcessoById(String processoId) async {
    try {
      // Tenta buscar no cache local primeiro
      try {
        final cachedProcesso = await localDataSource.getCachedProcesso(processoId);
        return Right(cachedProcesso);
      } on CacheException {
        // Se não encontrar no cache, busca remotamente
      }

      // Busca remotamente
      final remoteProcesso = await remoteDataSource.getProcessoById(processoId);
      
      // Salva no cache
      await localDataSource.cacheProcesso(remoteProcesso);
      
      return Right(remoteProcesso);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } on CacheException {
      return const Left(CacheFailure(message: 'Erro no cache'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProcessoInjecao>>> getProcessosByStatus(
    StatusProcesso status,
  ) async {
    try {
      // Busca remotamente usando o método getProcessos com filtro de status
      final remoteProcessos = await remoteDataSource.getProcessos(
        status: status.toString(),
      );
      
      // Salva no cache
      await localDataSource.cacheProcessos(remoteProcessos);
      
      return Right(remoteProcessos);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      // Em caso de erro de rede, tenta buscar no cache
      try {
        final cachedProcessos = await localDataSource.getCachedProcessosByStatus(status.toString());
        return Right(cachedProcessos);
      } on CacheException {
        return const Left(NetworkFailure(message: 'Erro de rede'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProcessoInjecao>>> getProcessosByUser(
    int userId, {
    int? limit,
  }) async {
    try {
      // Busca remotamente usando o método getProcessos
      final remoteProcessos = await remoteDataSource.getProcessos(
        limit: limit ?? 20,
      );
      
      // Salva no cache
      await localDataSource.cacheProcessos(remoteProcessos);
      
      return Right(remoteProcessos);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProcessoInjecao>>> getProcessosByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Busca remotamente usando o método getProcessos com filtro de data
      final remoteProcessos = await remoteDataSource.getProcessos(
        dataInicio: startDate,
        dataFim: endDate,
      );
      
      // Salva no cache
      await localDataSource.cacheProcessos(remoteProcessos);
      
      return Right(remoteProcessos);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProcessoInjecao>> updateProcessoStatus(
    String processoId,
    StatusProcesso status, {
    int? tempoDecorrido,
    double? pressaoAtual,
  }) async {
    try {
      final processo = await remoteDataSource.updateProcessoStatus(
        processoId: processoId,
        pressaoAtual: pressaoAtual ?? 0.0,
        tempoDecorrido: tempoDecorrido ?? 0,
      );
      
      // Atualiza no cache
      await localDataSource.cacheProcesso(processo);
      
      return Right(processo);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getInjectionStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Como não há método específico, retorna estatísticas básicas
      final processos = await remoteDataSource.getProcessos(
        dataInicio: startDate,
        dataFim: endDate,
      );
      
      final statistics = <String, dynamic>{
        'totalProcessos': processos.length,
        'processosAtivos': processos.where((p) => p.status == 'ativo').length,
        'processosConcluidos': processos.where((p) => p.status == 'concluido').length,
        'processosCancelados': processos.where((p) => p.status == 'cancelado').length,
      };
      
      return Right(statistics);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasActiveProcess() async {
    try {
      final processosAtivos = await remoteDataSource.getProcessosAtivos();
      return Right(processosAtivos.isNotEmpty);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      // Em caso de erro de rede, verifica no cache local
      try {
        final hasActiveLocal = await localDataSource.getCachedProcessosAtivos();
        return Right(hasActiveLocal.isNotEmpty);
      } on CacheException {
        return const Left(NetworkFailure(message: 'Erro de rede'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProcessoInjecao?>> getCurrentActiveProcess() async {
    try {
      final processosAtivos = await remoteDataSource.getProcessosAtivos();
      final activeProcess = processosAtivos.isNotEmpty ? processosAtivos.first : null;
      
      // Salva no cache se encontrou um processo ativo
      if (activeProcess != null) {
        await localDataSource.cacheProcesso(activeProcess);
      }
      
      return Right(activeProcess);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      // Em caso de erro de rede, verifica no cache local
      try {
        final activeProcesses = await localDataSource.getCachedProcessosAtivos();
        final activeProcess = activeProcesses.isNotEmpty ? activeProcesses.first : null;
        return Right(activeProcess);
      } on CacheException {
        return const Left(NetworkFailure(message: 'Erro de rede'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> syncProcesses() async {
    try {
      await remoteDataSource.syncInjectionData();
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure(message: 'Erro no servidor'));
    } on NetworkException {
      return const Left(NetworkFailure(message: 'Erro de rede'));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro desconhecido: ${e.toString()}'));
    }
  }
}