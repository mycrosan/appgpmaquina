import '../models/regra_model.dart';
import '../models/processo_injecao_model.dart';

/// Interface para operações remotas de injeção
/// Define métodos para interagir com a API de injeção
abstract class InjectionRemoteDataSource {
  /// Busca uma regra por ID
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<RegraModel> getRegraById(int id);

  /// Busca regra por matriz ID
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<RegraModel> getRegraByMatrizId(int matrizId);

  /// Lista todas as regras ativas
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<RegraModel>> getRegrasAtivas();

  /// Lista regras com paginação
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<RegraModel>> getRegras({
    int page = 1,
    int limit = 20,
    String? search,
  });

  /// Cria uma nova regra
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se os dados forem inválidos
  Future<RegraModel> createRegra(RegraModel regra);

  /// Atualiza uma regra existente
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se os dados forem inválidos
  Future<RegraModel> updateRegra(RegraModel regra);

  /// Remove uma regra (soft delete)
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<void> deleteRegra(int id);

  /// Busca um processo de injeção por ID
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<ProcessoInjecaoModel> getProcessoById(String id);

  /// Lista processos de injeção ativos
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<ProcessoInjecaoModel>> getProcessosAtivos();

  /// Lista processos com paginação e filtros
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<ProcessoInjecaoModel>> getProcessos({
    int page = 1,
    int limit = 20,
    String? status,
    String? carcacaCodigo,
    DateTime? dataInicio,
    DateTime? dataFim,
  });

  /// Inicia um novo processo de injeção
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se os dados forem inválidos
  Future<ProcessoInjecaoModel> startProcesso({
    required int carcacaId,
    required String carcacaCodigo,
    required int regraId,
    required double pressaoInicial,
    String? observacoes,
  });

  /// Pausa um processo de injeção
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<ProcessoInjecaoModel> pauseProcesso(String processoId);

  /// Retoma um processo de injeção pausado
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<ProcessoInjecaoModel> resumeProcesso(String processoId);

  /// Cancela um processo de injeção
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<ProcessoInjecaoModel> cancelProcesso({
    required String processoId,
    String? motivo,
  });

  /// Finaliza um processo de injeção
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<ProcessoInjecaoModel> finishProcesso({
    required String processoId,
    required double pressaoFinal,
    String? observacoes,
  });

  /// Atualiza o status de um processo em tempo real
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<ProcessoInjecaoModel> updateProcessoStatus({
    required String processoId,
    required double pressaoAtual,
    required int tempoDecorrido,
    int? pulsoAtual,
  });

  /// Verifica se há processos ativos para uma carcaça
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<bool> hasActiveProcessForCarcaca(int carcacaId);

  /// Sincroniza dados de injeção com o servidor
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<void> syncInjectionData();
}