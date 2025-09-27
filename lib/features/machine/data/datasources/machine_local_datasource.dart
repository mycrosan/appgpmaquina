import '../models/carcaca_model.dart';
import '../models/matriz_model.dart';
import '../models/machine_config_model.dart';

/// Interface para operações locais de máquina
/// Define métodos para cache e armazenamento local de dados de máquina
abstract class MachineLocalDataSource {
  /// Cache de Carcaças
  
  /// Salva uma carcaça no cache local
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> cacheCarcaca(CarcacaModel carcaca);

  /// Salva múltiplas carcaças no cache local
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> cacheCarcacas(List<CarcacaModel> carcacas);

  /// Busca uma carcaça do cache por ID
  /// Throws [CacheException] se a carcaça não for encontrada
  Future<CarcacaModel> getCachedCarcaca(String id);

  /// Busca carcaça do cache por código
  /// Throws [CacheException] se a carcaça não for encontrada
  Future<CarcacaModel> getCachedCarcacaByCodigo(String codigo);

  /// Lista todas as carcaças do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<CarcacaModel>> getCachedCarcacas();

  /// Lista carcaças ativas do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<CarcacaModel>> getCachedCarcacasAtivas();

  /// Lista carcaças por matriz do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<CarcacaModel>> getCachedCarcacasByMatriz(String matrizId);

  /// Remove uma carcaça do cache
  /// Throws [CacheException] se houver erro ao remover
  Future<void> removeCachedCarcaca(String id);

  /// Limpa todas as carcaças do cache
  /// Throws [CacheException] se houver erro ao limpar
  Future<void> clearCachedCarcacas();

  /// Cache de Matrizes
  
  /// Salva uma matriz no cache local
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> cacheMatriz(MatrizModel matriz);

  /// Salva múltiplas matrizes no cache local
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> cacheMatrizes(List<MatrizModel> matrizes);

  /// Busca uma matriz do cache por ID
  /// Throws [CacheException] se a matriz não for encontrada
  Future<MatrizModel> getCachedMatriz(String id);

  /// Busca matriz do cache por código
  /// Throws [CacheException] se a matriz não for encontrada
  Future<MatrizModel> getCachedMatrizByCodigo(String codigo);

  /// Lista todas as matrizes do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<MatrizModel>> getCachedMatrizes();

  /// Lista matrizes ativas do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<MatrizModel>> getCachedMatrizesAtivas();

  /// Lista matrizes por marca do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<MatrizModel>> getCachedMatrizesByMarca(String marca);

  /// Lista matrizes por modelo do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<MatrizModel>> getCachedMatrizesByModelo(String modelo);

  /// Remove uma matriz do cache
  /// Throws [CacheException] se houver erro ao remover
  Future<void> removeCachedMatriz(String id);

  /// Limpa todas as matrizes do cache
  /// Throws [CacheException] se houver erro ao limpar
  Future<void> clearCachedMatrizes();

  /// Configurações e preferências locais
  
  /// Salva configurações de máquina
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> saveMachineSettings(Map<String, dynamic> settings);

  /// Busca configurações de máquina
  /// Throws [CacheException] se houver erro ao buscar
  Future<Map<String, dynamic>> getMachineSettings();

  /// Salva última sincronização de carcaças
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> saveLastCarcacaSync(DateTime timestamp);

  /// Busca última sincronização de carcaças
  /// Throws [CacheException] se houver erro ao buscar
  Future<DateTime?> getLastCarcacaSync();

  /// Salva última sincronização de matrizes
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> saveLastMatrizSync(DateTime timestamp);

  /// Busca última sincronização de matrizes
  /// Throws [CacheException] se houver erro ao buscar
  Future<DateTime?> getLastMatrizSync();

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

  /// Histórico e auditoria
  
  /// Salva histórico de operações
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> saveOperationHistory(Map<String, dynamic> operation);

  /// Busca histórico de operações
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<Map<String, dynamic>>> getOperationHistory({
    int? limit,
    DateTime? since,
  });

  /// Limpa histórico antigo
  /// Throws [CacheException] se houver erro ao limpar
  Future<void> clearOldHistory(DateTime before);

  /// Estatísticas e métricas locais
  
  /// Salva estatísticas de máquina
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> saveMachineStats(Map<String, dynamic> stats);

  /// Busca estatísticas de máquina
  /// Throws [CacheException] se houver erro ao buscar
  Future<Map<String, dynamic>> getMachineStats();

  /// Atualiza contador de operações
  /// Throws [CacheException] se houver erro ao atualizar
  Future<void> updateOperationCounter(String operation);

  /// Busca contadores de operações
  /// Throws [CacheException] se houver erro ao buscar
  Future<Map<String, int>> getOperationCounters();

  /// Cache de Configuração da Máquina
  
  /// Salva a configuração da máquina no cache local
  /// Throws [CacheException] se houver erro ao salvar
  Future<void> cacheMachineConfig(MachineConfigModel config);

  /// Busca a configuração atual da máquina do cache
  /// Throws [CacheException] se a configuração não for encontrada
  Future<MachineConfigModel?> getCachedMachineConfig(String deviceId, String userId);

  /// Remove a configuração da máquina do cache
  /// Throws [CacheException] se houver erro ao remover
  Future<void> removeCachedMachineConfig(String deviceId, String userId);

  /// Lista todas as configurações de máquina do cache
  /// Throws [CacheException] se houver erro ao buscar
  Future<List<MachineConfigModel>> getCachedMachineConfigs();

  /// Limpa todas as configurações de máquina do cache
  /// Throws [CacheException] se houver erro ao limpar
  Future<void> clearCachedMachineConfigs();
}