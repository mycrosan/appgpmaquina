import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/regra.dart';
import '../entities/processo_injecao.dart';

/// Repositório abstrato para operações de injeção de ar
/// Define os contratos para gerenciamento de regras e processos de injeção
abstract class InjectionRepository {
  /// Busca uma regra pelo ID da matriz
  ///
  /// [matrizId] - ID da matriz
  /// Retorna [Regra] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Regra>> getRegraByMatrizId(int matrizId);

  /// Busca uma regra pelo seu ID
  ///
  /// [id] - ID único da regra
  /// Retorna [Regra] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Regra>> getRegraById(int id);

  /// Lista todas as regras ativas
  ///
  /// Retorna [List<Regra>] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, List<Regra>>> getAllRegras();

  /// Cria uma nova regra de injeção
  ///
  /// [regra] - dados da regra a ser criada
  /// Retorna [Regra] criada em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Regra>> createRegra(Regra regra);

  /// Atualiza uma regra existente
  ///
  /// [regra] - dados atualizados da regra
  /// Retorna [Regra] atualizada em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Regra>> updateRegra(Regra regra);

  /// Remove uma regra (soft delete)
  ///
  /// [id] - ID da regra a ser removida
  /// Retorna [void] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, void>> deleteRegra(int id);

  /// Inicia um novo processo de injeção
  ///
  /// [carcacaId] - ID da carcaça
  /// [regraId] - ID da regra a ser aplicada
  /// [userId] - ID do usuário que está iniciando o processo
  /// Retorna [ProcessoInjecao] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, ProcessoInjecao>> startInjectionProcess({
    required int carcacaId,
    required int regraId,
    required int userId,
  });

  /// Pausa um processo de injeção em andamento
  ///
  /// [processoId] - ID do processo
  /// Retorna [ProcessoInjecao] atualizado em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, ProcessoInjecao>> pauseInjectionProcess(
    String processoId,
  );

  /// Retoma um processo de injeção pausado
  ///
  /// [processoId] - ID do processo
  /// Retorna [ProcessoInjecao] atualizado em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, ProcessoInjecao>> resumeInjectionProcess(
    String processoId,
  );

  /// Cancela um processo de injeção
  ///
  /// [processoId] - ID do processo
  /// [motivo] - motivo do cancelamento
  /// Retorna [ProcessoInjecao] atualizado em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, ProcessoInjecao>> cancelInjectionProcess(
    String processoId,
    String motivo,
  );

  /// Finaliza um processo de injeção
  ///
  /// [processoId] - ID do processo
  /// [observacoes] - observações finais (opcional)
  /// Retorna [ProcessoInjecao] atualizado em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, ProcessoInjecao>> finishInjectionProcess(
    String processoId, {
    String? observacoes,
  });

  /// Busca um processo de injeção pelo seu ID
  ///
  /// [processoId] - ID do processo
  /// Retorna [ProcessoInjecao] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, ProcessoInjecao>> getProcessoById(String processoId);

  /// Lista processos de injeção por status
  ///
  /// [status] - status dos processos a serem listados
  /// Retorna [List<ProcessoInjecao>] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, List<ProcessoInjecao>>> getProcessosByStatus(
    StatusProcesso status,
  );

  /// Lista todos os processos de injeção de um usuário
  ///
  /// [userId] - ID do usuário
  /// [limit] - limite de resultados (opcional)
  /// Retorna [List<ProcessoInjecao>] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, List<ProcessoInjecao>>> getProcessosByUser(
    int userId, {
    int? limit,
  });

  /// Lista processos de injeção por período
  ///
  /// [startDate] - data inicial
  /// [endDate] - data final
  /// Retorna [List<ProcessoInjecao>] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, List<ProcessoInjecao>>> getProcessosByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Atualiza o status de um processo de injeção
  ///
  /// [processoId] - ID do processo
  /// [status] - novo status
  /// [tempoDecorrido] - tempo decorrido atualizado (opcional)
  /// [pressaoAtual] - pressão atual atualizada (opcional)
  /// Retorna [ProcessoInjecao] atualizado em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, ProcessoInjecao>> updateProcessoStatus(
    String processoId,
    StatusProcesso status, {
    int? tempoDecorrido,
    double? pressaoAtual,
  });

  /// Obtém estatísticas de processos de injeção
  ///
  /// [startDate] - data inicial para as estatísticas
  /// [endDate] - data final para as estatísticas
  /// Retorna [Map] com estatísticas em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, Map<String, dynamic>>> getInjectionStatistics(
    DateTime startDate,
    DateTime endDate,
  );

  /// Verifica se há algum processo de injeção em andamento
  ///
  /// Retorna [bool] indicando se há processo ativo ou [Failure] em caso de erro
  Future<Either<Failure, bool>> hasActiveProcess();

  /// Obtém o processo de injeção ativo atual (se houver)
  ///
  /// Retorna [ProcessoInjecao] se houver processo ativo ou [Failure] caso contrário
  Future<Either<Failure, ProcessoInjecao?>> getCurrentActiveProcess();

  /// Sincroniza dados de processos com o servidor
  ///
  /// Retorna [void] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, void>> syncProcesses();
}