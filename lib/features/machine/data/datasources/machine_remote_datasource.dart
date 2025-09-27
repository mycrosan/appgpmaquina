import '../models/carcaca_model.dart';
import '../models/matriz_model.dart';
import '../models/machine_config_model.dart';

/// Interface para operações remotas de máquina
/// Define métodos para interagir com a API de máquina
abstract class MachineRemoteDataSource {
  /// Operações de Carcaça
  
  /// Busca uma carcaça por ID
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<CarcacaModel> getCarcacaById(String id);

  /// Busca carcaça por código
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<CarcacaModel> getCarcacaByCodigo(String codigo);

  /// Lista todas as carcaças ativas
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<CarcacaModel>> getCarcacasAtivas();

  /// Lista carcaças com paginação e filtros
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<CarcacaModel>> getCarcacas({
    int page = 1,
    int limit = 20,
    String? search,
    String? matrizId,
    bool? isActive,
  });

  /// Cria uma nova carcaça
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se os dados forem inválidos
  Future<CarcacaModel> createCarcaca(CarcacaModel carcaca);

  /// Atualiza uma carcaça existente
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se os dados forem inválidos
  Future<CarcacaModel> updateCarcaca(CarcacaModel carcaca);

  /// Remove uma carcaça (soft delete)
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<void> deleteCarcaca(String id);

  /// Verifica se uma carcaça pode ser processada
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<bool> isCarcacaProcessable(String id);

  /// Busca carcaças por matriz
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<CarcacaModel>> getCarcacasByMatriz(String matrizId);

  /// Operações de Matriz
  
  /// Busca uma matriz por ID
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<MatrizModel> getMatrizById(String id);

  /// Busca matriz por código
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<MatrizModel> getMatrizByCodigo(String codigo);

  /// Lista todas as matrizes ativas
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<MatrizModel>> getMatrizesAtivas();

  /// Lista matrizes com paginação e filtros
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<MatrizModel>> getMatrizes({
    int page = 1,
    int limit = 20,
    String? search,
    String? marca,
    String? modelo,
    bool? isActive,
  });

  /// Cria uma nova matriz
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se os dados forem inválidos
  Future<MatrizModel> createMatriz(MatrizModel matriz);

  /// Atualiza uma matriz existente
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se os dados forem inválidos
  Future<MatrizModel> updateMatriz(MatrizModel matriz);

  /// Remove uma matriz (soft delete)
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<void> deleteMatriz(String id);

  /// Verifica se uma matriz pode ser usada
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<bool> isMatrizUsable(String id);

  /// Busca matrizes por marca
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<MatrizModel>> getMatrizesByMarca(String marca);

  /// Busca matrizes por modelo
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<MatrizModel>> getMatrizesByModelo(String modelo);

  /// Operações de sincronização
  
  /// Sincroniza dados de carcaças com o servidor
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<void> syncCarcacaData();

  /// Sincroniza dados de matrizes com o servidor
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<void> syncMatrizData();

  /// Sincroniza todos os dados de máquina
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<void> syncMachineData();

  /// Operações de validação
  
  /// Valida código de carcaça
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se o código for inválido
  Future<bool> validateCarcacaCodigo(String codigo);

  /// Valida código de matriz
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se o código for inválido
  Future<bool> validateMatrizCodigo(String codigo);

  /// Operações de Configuração da Máquina
  
  /// Salva a configuração da máquina
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se os dados forem inválidos
  Future<MachineConfigModel> saveMachineConfig(MachineConfigModel config);

  /// Busca a configuração atual da máquina
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<MachineConfigModel?> getCurrentMachineConfig(String deviceId, String userId);

  /// Remove a configuração da máquina
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<void> removeMachineConfig(String deviceId, String userId);
}