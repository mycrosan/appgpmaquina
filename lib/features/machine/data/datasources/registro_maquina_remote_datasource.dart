import '../models/registro_maquina_dto.dart';

/// Data source abstrato para operações remotas com registro de máquinas
/// Define os contratos para comunicação com a API
abstract class RegistroMaquinaRemoteDataSource {
  /// Cria uma nova máquina
  ///
  /// [createData] - dados para criação da máquina
  /// Retorna [RegistroMaquinaResponseDTO] com os dados da máquina criada
  /// Lança [ServerException] em caso de erro
  Future<RegistroMaquinaResponseDTO> createMaquina(
    RegistroMaquinaUpdateDTO createData,
  );

  /// Busca uma máquina por ID
  ///
  /// [id] - ID da máquina
  /// Retorna [RegistroMaquinaResponseDTO] com os dados da máquina
  /// Lança [ServerException] em caso de erro
  Future<RegistroMaquinaResponseDTO> getMaquinaById(int id);

  /// Atualiza uma máquina existente
  ///
  /// [id] - ID da máquina a ser atualizada
  /// [updateData] - dados para atualização
  /// Retorna [RegistroMaquinaResponseDTO] com os dados atualizados
  /// Lança [ServerException] em caso de erro
  Future<RegistroMaquinaResponseDTO> updateMaquina(
    int id,
    RegistroMaquinaUpdateDTO updateData,
  );

  /// Lista todas as máquinas ativas
  ///
  /// Retorna [List<RegistroMaquinaResponseDTO>] com todas as máquinas
  /// Lança [ServerException] em caso de erro
  Future<List<RegistroMaquinaResponseDTO>> getAllMaquinas();
}