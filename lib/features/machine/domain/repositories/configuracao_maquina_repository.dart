import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/configuracao_maquina.dart';

/// Interface do repositório para configuração de máquina
/// Define os contratos para operações CRUD e consultas específicas
abstract class ConfiguracaoMaquinaRepository {
  /// Cria uma nova configuração de máquina
  ///
  /// Retorna [Right] com a configuração criada em caso de sucesso
  /// Retorna [Left] com [Failure] em caso de erro
  Future<Either<Failure, ConfiguracaoMaquina>> createConfiguracaoMaquina(
    ConfiguracaoMaquina configuracao,
  );

  /// Lista configurações de máquina com filtros opcionais
  ///
  /// [registroMaquinaId] - ID da máquina para filtrar
  /// [chaveConfiguracao] - Chave específica para filtrar
  /// [ativo] - Status ativo/inativo para filtrar
  /// [page] - Página para paginação (padrão: 0)
  /// [size] - Tamanho da página (padrão: 20)
  ///
  /// Retorna [Right] com resposta paginada de configurações em caso de sucesso
  /// Retorna [Left] com [Failure] em caso de erro
  Future<Either<Failure, PaginatedResponse<ConfiguracaoMaquina>>>
  getConfiguracoesMaquina({
    int? registroMaquinaId,
    String? chaveConfiguracao,
    bool? ativo,
    int page = 0,
    int size = 20,
  });

  /// Busca uma configuração específica por ID
  ///
  /// [id] - ID da configuração
  ///
  /// Retorna [Right] com a configuração encontrada em caso de sucesso
  /// Retorna [Left] com [Failure] em caso de erro ou não encontrado
  Future<Either<Failure, ConfiguracaoMaquina>> getConfiguracaoMaquinaById(
    int id,
  );

  /// Atualiza uma configuração existente
  ///
  /// [id] - ID da configuração a ser atualizada
  /// [configuracao] - Dados atualizados da configuração
  ///
  /// Retorna [Right] com a configuração atualizada em caso de sucesso
  /// Retorna [Left] com [Failure] em caso de erro
  Future<Either<Failure, ConfiguracaoMaquina>> updateConfiguracaoMaquina(
    int id,
    ConfiguracaoMaquina configuracao,
  );

  /// Remove uma configuração (exclusão lógica)
  ///
  /// [id] - ID da configuração a ser removida
  ///
  /// Retorna [Right] com void em caso de sucesso
  /// Retorna [Left] com [Failure] em caso de erro
  Future<Either<Failure, void>> deleteConfiguracaoMaquina(int id);

  /// Busca configuração específica por máquina e chave
  ///
  /// [registroMaquinaId] - ID da máquina
  /// [chaveConfiguracao] - Chave da configuração
  ///
  /// Retorna [Right] com a configuração encontrada em caso de sucesso
  /// Retorna [Left] com [Failure] em caso de erro ou não encontrado
  Future<Either<Failure, ConfiguracaoMaquina>> getConfiguracaoByMaquinaAndChave(
    int registroMaquinaId,
    String chaveConfiguracao,
  );
}