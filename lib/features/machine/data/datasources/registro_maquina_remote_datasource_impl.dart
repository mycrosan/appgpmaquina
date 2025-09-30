import 'dart:developer' as developer;
import 'package:dio/dio.dart';

import '../../../../core/config/network_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/registro_maquina_dto.dart';
import 'registro_maquina_remote_datasource.dart';

/// Implementação do data source remoto para registro de máquinas
/// Utiliza Dio para comunicação HTTP com a API
class RegistroMaquinaRemoteDataSourceImpl
    implements RegistroMaquinaRemoteDataSource {
  final Dio dio;

  RegistroMaquinaRemoteDataSourceImpl({required this.dio}) {
    developer.log(
      '🌐 RegistroMaquinaRemoteDataSourceImpl inicializado',
      name: 'RegistroMaquinaRemoteDS',
    );
  }

  @override
  Future<RegistroMaquinaResponseDTO> createMaquina(
    RegistroMaquinaUpdateDTO createData,
  ) async {
    try {
      developer.log('📋 Criando nova máquina', name: 'RegistroMaquinaRemoteDS');
      developer.log(
        '📋 Dados: ${createData.toJson()}',
        name: 'RegistroMaquinaRemoteDS',
      );

      final response = await dio.post(
        ApiEndpoints.registroMaquina,
        data: createData.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json; charset=UTF-8',
          },
        ),
      );

      developer.log(
        '✅ Máquina criada: ${response.statusCode}',
        name: 'RegistroMaquinaRemoteDS',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dto = RegistroMaquinaResponseDTO.fromJson(
          response.data as Map<String, dynamic>,
        );
        developer.log(
          '📋 Máquina criada: ${dto.nome}',
          name: 'RegistroMaquinaRemoteDS',
        );
        return dto;
      } else if (response.statusCode == 400) {
        developer.log(
          '❌ Dados inválidos para criação',
          name: 'RegistroMaquinaRemoteDS',
        );
        throw const ServerException(
          message: 'Dados inválidos para criação da máquina',
        );
      } else {
        developer.log(
          '❌ Erro ao criar máquina: ${response.statusCode}',
          name: 'RegistroMaquinaRemoteDS',
        );
        throw ServerException(
          message: 'Erro ao criar máquina: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      developer.log(
        '❌ Erro de rede ao criar máquina: ${e.message}',
        name: 'RegistroMaquinaRemoteDS',
      );

      if (e.response?.statusCode == 400) {
        throw const ServerException(
          message: 'Dados inválidos para criação da máquina',
        );
      } else if (e.response?.statusCode == 409) {
        throw const ServerException(message: 'Máquina já existe');
      } else if (e.response?.statusCode == 500) {
        throw const ServerException(message: 'Erro interno do servidor');
      } else {
        throw ServerException(message: 'Erro de conexão: ${e.message}');
      }
    } catch (e) {
      developer.log(
        '❌ Erro inesperado ao criar máquina: $e',
        name: 'RegistroMaquinaRemoteDS',
      );
      throw ServerException(message: 'Erro inesperado: $e');
    }
  }

  @override
  Future<RegistroMaquinaResponseDTO> getMaquinaById(int id) async {
    try {
      developer.log(
        '📋 Buscando máquina por ID: $id',
        name: 'RegistroMaquinaRemoteDS',
      );

      final response = await dio.get(
        ApiEndpoints.registroMaquinaById(id),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json; charset=UTF-8',
          },
        ),
      );

      developer.log(
        '✅ Máquina encontrada: ${response.statusCode}',
        name: 'RegistroMaquinaRemoteDS',
      );

      if (response.statusCode == 200) {
        final dto = RegistroMaquinaResponseDTO.fromJson(
          response.data as Map<String, dynamic>,
        );
        developer.log(
          '📋 Máquina carregada: ${dto.nome}',
          name: 'RegistroMaquinaRemoteDS',
        );
        return dto;
      } else if (response.statusCode == 404) {
        developer.log(
          '❌ Máquina não encontrada: $id',
          name: 'RegistroMaquinaRemoteDS',
        );
        throw const ServerException(message: 'Máquina não encontrada');
      } else {
        developer.log(
          '❌ Erro ao buscar máquina: ${response.statusCode}',
          name: 'RegistroMaquinaRemoteDS',
        );
        throw ServerException(
          message: 'Erro ao buscar máquina: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      developer.log(
        '❌ Erro de rede ao buscar máquina: ${e.message}',
        name: 'RegistroMaquinaRemoteDS',
      );

      if (e.response?.statusCode == 404) {
        throw const ServerException(message: 'Máquina não encontrada');
      } else if (e.response?.statusCode == 500) {
        throw const ServerException(message: 'Erro interno do servidor');
      } else {
        throw ServerException(message: 'Erro de conexão: ${e.message}');
      }
    } catch (e) {
      developer.log(
        '❌ Erro inesperado ao buscar máquina: $e',
        name: 'RegistroMaquinaRemoteDS',
      );
      throw ServerException(message: 'Erro inesperado: $e');
    }
  }

  @override
  Future<List<RegistroMaquinaResponseDTO>> getAllMaquinas() async {
    try {
      developer.log(
        '📋 Buscando todas as máquinas',
        name: 'RegistroMaquinaRemoteDS',
      );

      final response = await dio.get(
        ApiEndpoints.registroMaquina,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json; charset=UTF-8',
          },
        ),
      );

      developer.log(
        '✅ Máquinas encontradas: ${response.statusCode}',
        name: 'RegistroMaquinaRemoteDS',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final List<RegistroMaquinaResponseDTO> maquinas = data
            .map(
              (json) => RegistroMaquinaResponseDTO.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList();

        developer.log(
          '📋 Máquinas carregadas: ${maquinas.length}',
          name: 'RegistroMaquinaRemoteDS',
        );
        return maquinas;
      } else {
        developer.log(
          '❌ Erro ao buscar máquinas: ${response.statusCode}',
          name: 'RegistroMaquinaRemoteDS',
        );
        throw ServerException(
          message: 'Erro ao buscar máquinas: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      developer.log(
        '❌ Erro de rede ao buscar máquinas: ${e.message}',
        name: 'RegistroMaquinaRemoteDS',
      );

      if (e.response?.statusCode == 500) {
        throw const ServerException(message: 'Erro interno do servidor');
      } else {
        throw ServerException(message: 'Erro de conexão: ${e.message}');
      }
    } catch (e) {
      developer.log(
        '❌ Erro inesperado ao buscar máquinas: $e',
        name: 'RegistroMaquinaRemoteDS',
      );
      throw ServerException(message: 'Erro inesperado: $e');
    }
  }

  @override
  Future<RegistroMaquinaResponseDTO> updateMaquina(
    int id,
    RegistroMaquinaUpdateDTO updateData,
  ) async {
    try {
      developer.log(
        '📋 Atualizando máquina ID: $id',
        name: 'RegistroMaquinaRemoteDS',
      );
      developer.log(
        '📋 Dados: ${updateData.toJson()}',
        name: 'RegistroMaquinaRemoteDS',
      );

      final response = await dio.put(
        ApiEndpoints.registroMaquinaById(id),
        data: updateData.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json; charset=UTF-8',
          },
        ),
      );

      developer.log(
        '✅ Máquina atualizada: ${response.statusCode}',
        name: 'RegistroMaquinaRemoteDS',
      );

      if (response.statusCode == 200) {
        // Se a resposta for um objeto, converte para DTO
        if (response.data is Map<String, dynamic>) {
          final dto = RegistroMaquinaResponseDTO.fromJson(
            response.data as Map<String, dynamic>,
          );
          developer.log(
            '📋 Máquina atualizada: ${dto.nome}',
            name: 'RegistroMaquinaRemoteDS',
          );
          return dto;
        } else {
          // Se a resposta for apenas um objeto genérico, busca a máquina atualizada
          developer.log(
            '📋 Buscando máquina atualizada...',
            name: 'RegistroMaquinaRemoteDS',
          );
          return await getMaquinaById(id);
        }
      } else if (response.statusCode == 400) {
        developer.log(
          '❌ Dados inválidos para atualização',
          name: 'RegistroMaquinaRemoteDS',
        );
        throw const ServerException(
          message: 'Dados inválidos para atualização',
        );
      } else if (response.statusCode == 404) {
        developer.log(
          '❌ Máquina não encontrada para atualização: $id',
          name: 'RegistroMaquinaRemoteDS',
        );
        throw const ServerException(message: 'Máquina não encontrada');
      } else {
        developer.log(
          '❌ Erro ao atualizar máquina: ${response.statusCode}',
          name: 'RegistroMaquinaRemoteDS',
        );
        throw ServerException(
          message: 'Erro ao atualizar máquina: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      developer.log(
        '❌ Erro de rede ao atualizar máquina: ${e.message}',
        name: 'RegistroMaquinaRemoteDS',
      );

      if (e.response?.statusCode == 400) {
        throw const ServerException(
          message: 'Dados inválidos para atualização',
        );
      } else if (e.response?.statusCode == 404) {
        throw const ServerException(message: 'Máquina não encontrada');
      } else if (e.response?.statusCode == 500) {
        throw const ServerException(message: 'Erro interno do servidor');
      } else {
        throw ServerException(message: 'Erro de conexão: ${e.message}');
      }
    } catch (e) {
      developer.log(
        '❌ Erro inesperado ao atualizar máquina: $e',
        name: 'RegistroMaquinaRemoteDS',
      );
      throw ServerException(message: 'Erro inesperado: $e');
    }
  }

  // Método getAllMaquinas já implementado acima
}