import '../models/pneu_vulcanizado_create_dto.dart';
import '../models/pneu_vulcanizado_response_dto.dart';

/// Interface para datasource remoto de vulcanização
/// 
/// Define os contratos para comunicação com a API de vulcanização
abstract class VulcanizacaoRemoteDataSource {
  /// Cria um novo registro de pneu vulcanizado com status 'INICIADO'
  /// 
  /// [createDto] - Dados para criação do pneu vulcanizado
  /// Retorna [PneuVulcanizadoResponseDTO] com os dados criados
  /// Throws [ServerException] em caso de erro na API
  Future<PneuVulcanizadoResponseDTO> criarPneuVulcanizado(
    PneuVulcanizadoCreateDTO createDto,
  );

  /// Finaliza um pneu vulcanizado, alterando status para 'FINALIZADO'
  /// 
  /// [id] - ID do pneu vulcanizado a ser finalizado
  /// Retorna [PneuVulcanizadoResponseDTO] com os dados atualizados
  /// Throws [ServerException] em caso de erro na API
  Future<PneuVulcanizadoResponseDTO> finalizarPneuVulcanizado(int id);

  /// Busca um pneu vulcanizado pelo ID
  /// 
  /// [id] - ID do pneu vulcanizado
  /// Retorna [PneuVulcanizadoResponseDTO] com os dados encontrados
  /// Throws [ServerException] em caso de erro na API
  Future<PneuVulcanizadoResponseDTO> buscarPneuVulcanizadoPorId(int id);

  /// Lista pneus vulcanizados com filtros opcionais
  /// 
  /// [usuarioId] - ID do usuário para filtrar (opcional)
  /// [status] - Status para filtrar (opcional)
  /// [numeroEtiqueta] - Pesquisa por número da etiqueta (opcional)
  /// [page] - Página para paginação (padrão: 0)
  /// [size] - Tamanho da página (padrão: 20)
  /// Retorna lista de [PneuVulcanizadoResponseDTO]
  /// Throws [ServerException] em caso de erro na API
  Future<List<PneuVulcanizadoResponseDTO>> listarPneusVulcanizados({
    int? usuarioId,
    String? status,
    String? numeroEtiqueta,
    int page = 0,
    int size = 20,
  });
}