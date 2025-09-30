import '../models/configuracao_maquina_model.dart';

/// Interface para operações remotas de configuração de máquina
abstract class ConfiguracaoMaquinaRemoteDataSource {
  /// Cria uma nova configuração de máquina
  /// 
  /// [config] - configuração a ser criada
  /// Retorna [ConfiguracaoMaquinaModel] criada
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se os dados forem inválidos
  Future<ConfiguracaoMaquinaModel> createConfiguracaoMaquina(ConfiguracaoMaquinaModel config);

  /// Lista configurações com filtros e paginação
  /// 
  /// [registroMaquinaId] - ID da máquina (opcional)
  /// [chaveConfiguracao] - chave da configuração (opcional)
  /// [ativo] - filtro por status ativo (opcional)
  /// [page] - página para paginação (padrão: 0)
  /// [size] - tamanho da página (padrão: 20)
  /// Retorna lista de [ConfiguracaoMaquinaModel]
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  Future<List<ConfiguracaoMaquinaModel>> getConfiguracoesMaquina({
    int? registroMaquinaId,
    String? chaveConfiguracao,
    bool? ativo,
    int page = 0,
    int size = 20,
  });

  /// Busca configuração por ID
  /// 
  /// [id] - ID da configuração
  /// Retorna [ConfiguracaoMaquinaModel] encontrada
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [NotFoundException] se a configuração não for encontrada
  Future<ConfiguracaoMaquinaModel> getConfiguracaoMaquinaById(int id);

  /// Atualiza uma configuração existente
  /// 
  /// [id] - ID da configuração
  /// [config] - dados atualizados da configuração
  /// Retorna [ConfiguracaoMaquinaModel] atualizada
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [ValidationException] se os dados forem inválidos
  /// Throws [NotFoundException] se a configuração não for encontrada
  Future<ConfiguracaoMaquinaModel> updateConfiguracaoMaquina(int id, ConfiguracaoMaquinaModel config);

  /// Remove uma configuração (exclusão lógica)
  /// 
  /// [id] - ID da configuração
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [NotFoundException] se a configuração não for encontrada
  Future<void> deleteConfiguracaoMaquina(int id);

  /// Busca configuração por máquina e chave
  /// 
  /// [registroMaquinaId] - ID da máquina
  /// [chaveConfiguracao] - chave da configuração
  /// Retorna [ConfiguracaoMaquinaModel] encontrada
  /// Throws [ServerException] se houver erro no servidor
  /// Throws [NetworkException] se houver erro de rede
  /// Throws [NotFoundException] se a configuração não for encontrada
  Future<ConfiguracaoMaquinaModel> getConfiguracaoByMaquinaAndChave(
    int registroMaquinaId,
    String chaveConfiguracao,
  );
}