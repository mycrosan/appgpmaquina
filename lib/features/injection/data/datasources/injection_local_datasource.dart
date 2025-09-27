import '../models/regra_model.dart';
import '../models/processo_injecao_model.dart';

/// Interface para operações locais de injeção
/// Define métodos para cache e armazenamento local de dados de injeção
abstract class InjectionLocalDataSource {
  /// Cache de regras
  
  /// Salva uma regra no cache local
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> cacheRegra(RegraModel regra);

  /// Salva múltiplas regras no cache local
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> cacheRegras(List<RegraModel> regras);

  /// Busca uma regra do cache por ID
  /// Throws [CacheException] se a regra não for encontrada
  Future<RegraModel> getCachedRegra(int id);

  /// Busca regra do cache por matriz ID
  /// Throws [CacheException] se a regra não for encontrada
  Future<RegraModel> getCachedRegraByMatrizId(int matrizId);

  /// Lista todas as regras do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<RegraModel>> getCachedRegras();

  /// Lista regras ativas do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<RegraModel>> getCachedRegrasAtivas();

  /// Remove uma regra do cache
  /// Throws [CacheException] se houver erro ao remover
  Future<void> removeCachedRegra(int id);

  /// Limpa todas as regras do cache
  /// Throws [CacheException] se houver erro ao limpar
  Future<void> clearCachedRegras();

  /// Cache de processos de injeção
  
  /// Salva um processo no cache local
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> cacheProcesso(ProcessoInjecaoModel processo);

  /// Salva múltiplos processos no cache local
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> cacheProcessos(List<ProcessoInjecaoModel> processos);

  /// Busca um processo do cache por ID
  /// Throws [CacheException] se o processo não for encontrado
  Future<ProcessoInjecaoModel> getCachedProcesso(String id);

  /// Lista todos os processos do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<ProcessoInjecaoModel>> getCachedProcessos();

  /// Lista processos ativos do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<ProcessoInjecaoModel>> getCachedProcessosAtivos();

  /// Lista processos por status
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<ProcessoInjecaoModel>> getCachedProcessosByStatus(String status);

  /// Remove um processo do cache
  /// Throws [CacheException] se houver erro ao remover
  Future<void> removeCachedProcesso(String id);

  /// Limpa todos os processos do cache
  /// Throws [CacheException] se houver erro ao limpar
  Future<void> clearCachedProcessos();

  /// Configurações e preferências locais
  
  /// Salva configurações de injeção
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> saveInjectionSettings(Map<String, dynamic> settings);

  /// Busca configurações de injeção
  /// Throws [CacheException] se houver erro ao buscar
  Future<Map<String, dynamic>> getInjectionSettings();

  /// Salva última sincronização de regras
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> saveLastRegraSync(DateTime timestamp);

  /// Busca última sincronização de regras
  /// Throws [CacheException] se houver erro ao buscar
  Future<DateTime?> getLastRegraSync();

  /// Salva última sincronização de processos
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> saveLastProcessoSync(DateTime timestamp);

  /// Busca última sincronização de processos
  /// Throws [CacheException] se houver erro ao buscar
  Future<DateTime?> getLastProcessoSync();

  /// Dados offline e sincronização
  
  /// Salva dados para sincronização posterior
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> savePendingSync(Map<String, dynamic> data);

  /// Lista dados pendentes de sincronização
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<Map<String, dynamic>>> getPendingSyncData();

  /// Remove dados sincronizados
  /// Throws [CacheException] se houver erro ao remover
  Future<void> removeSyncedData(String id);

  /// Limpa todos os dados pendentes de sincronização
  /// Throws [CacheException] se houver erro ao limpar
  Future<void> clearPendingSyncData();

  /// Verifica se há dados pendentes de sincronização
  /// Throws [CacheException] se houver erro ao verificar
  Future<bool> hasPendingSyncData();

  /// Estatísticas e métricas locais
  
  /// Salva estatísticas de injeção
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> saveInjectionStats(Map<String, dynamic> stats);

  /// Busca estatísticas de injeção
  /// Throws [CacheException] se houver erro ao buscar
  Future<Map<String, dynamic>> getInjectionStats();

  /// Atualiza contador de processos
  /// Throws [CacheException] se houver erro ao atualizar
  Future<void> updateProcessCounter();

  /// Busca contador de processos
  /// Throws [CacheException] se houver erro ao buscar
  Future<int> getProcessCounter();
}