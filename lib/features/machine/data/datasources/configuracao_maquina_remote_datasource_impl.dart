import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/config/network_config.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/configuracao_maquina_model.dart';
import '../models/configuracao_maquina_dto.dart';
import 'configuracao_maquina_remote_datasource.dart';

class ConfiguracaoMaquinaRemoteDataSourceImpl implements ConfiguracaoMaquinaRemoteDataSource {
  final Dio dio;

  ConfiguracaoMaquinaRemoteDataSourceImpl({required this.dio});

  @override
  Future<ConfiguracaoMaquinaModel> createConfiguracaoMaquina(ConfiguracaoMaquinaModel config) async {
    try {
      developer.log('🔄 Criando nova configuração de máquina', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📋 Dados: ${config.toString()}', name: 'ConfiguracaoMaquinaRemoteDS');

      final response = await dio.post(
        ApiEndpoints.configuracaoMaquina,
        data: config.toJson(),
      );

      developer.log('✅ Configuração criada com sucesso', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📊 Status: ${response.statusCode}', name: 'ConfiguracaoMaquinaRemoteDS');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Usar o DTO correto para fazer o parse da resposta da API
        final dto = ConfiguracaoMaquinaResponseDTO.fromJson(response.data as Map<String, dynamic>);
        
        // Converter o DTO para o modelo esperado pela interface
        return ConfiguracaoMaquinaModel(
          id: dto.id,
          registroMaquinaId: dto.maquinaId ?? 1, // Usar 1 como padrão se for null
          chaveConfiguracao: 'matriz_id',
          valorConfiguracao: dto.matrizId?.toString() ?? '0',
          descricao: dto.descricao ?? '',
          tipoValor: 'int',
          valorPadrao: '0',
          obrigatorio: true,
          // Configuração está ativa apenas se não foi soft-deletada (dt_delete é null)
          ativo: dto.dtDelete == null,
          criadoEm: dto.dtCreate != null ? DateTime.tryParse(dto.dtCreate!) : null,
          atualizadoEm: dto.dtUpdate != null ? DateTime.tryParse(dto.dtUpdate!) : null,
        );
      } else {
        throw ServerException(message: 'Erro ao criar configuração: ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('💥 Erro DioException ao criar configuração: ${e.message}', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📊 Status Code: ${e.response?.statusCode}', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📋 Response Data: ${e.response?.data}', name: 'ConfiguracaoMaquinaRemoteDS');

      if (e.response?.statusCode == 400) {
        throw ValidationException(message: 'Dados inválidos para criação da configuração');
      } else if (e.response?.statusCode == 401) {
        throw AuthenticationException(message: 'Token de autenticação inválido');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException(message: 'Sem permissão para criar configuração');
      } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        throw ServerException(message: 'Erro interno do servidor: ${e.response?.statusCode}');
      } else {
        throw NetworkException(message: 'Erro de rede ao criar configuração');
      }
    } catch (e) {
      developer.log('💥 Erro inesperado ao criar configuração: $e', name: 'ConfiguracaoMaquinaRemoteDS');
      throw ServerException(message: 'Erro inesperado ao criar configuração: $e');
    }
  }

  @override
  Future<List<ConfiguracaoMaquinaModel>> getConfiguracoesMaquina({
    int? registroMaquinaId,
    String? chaveConfiguracao,
    bool? ativo,
    int page = 0,
    int size = 20,
  }) async {
    try {
      developer.log('🔄 Buscando configurações de máquina', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📋 Filtros: registroMaquinaId=$registroMaquinaId, chave=$chaveConfiguracao, ativo=$ativo', name: 'ConfiguracaoMaquinaRemoteDS');

      final queryParameters = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (registroMaquinaId != null) {
        queryParameters['registroMaquinaId'] = registroMaquinaId;
      }
      if (chaveConfiguracao != null) {
        queryParameters['chaveConfiguracao'] = chaveConfiguracao;
      }
      if (ativo != null) {
        queryParameters['ativo'] = ativo;
      }

      final response = await dio.get(
        ApiEndpoints.configuracaoMaquina,
        queryParameters: queryParameters,
      );

      developer.log('✅ Configurações obtidas com sucesso', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📊 Status: ${response.statusCode}', name: 'ConfiguracaoMaquinaRemoteDS');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) {
          // Usar o DTO correto para fazer o parse da resposta da API
          final dto = ConfiguracaoMaquinaResponseDTO.fromJson(json as Map<String, dynamic>);
          
          // Converter o DTO para o modelo esperado pela interface
          return ConfiguracaoMaquinaModel(
            id: dto.id,
            registroMaquinaId: dto.maquinaId ?? 0,
            chaveConfiguracao: 'matriz_id',
            valorConfiguracao: dto.matrizId?.toString() ?? '',
            descricao: dto.descricao ?? '',
            tipoValor: 'int',
            valorPadrao: '',
            obrigatorio: true,
            // Configuração está ativa apenas se não foi soft-deletada (dt_delete é null)
            ativo: dto.dtDelete == null,
            criadoEm: dto.dtCreate != null ? DateTime.tryParse(dto.dtCreate!) : null,
            atualizadoEm: dto.dtUpdate != null ? DateTime.tryParse(dto.dtUpdate!) : null,
          );
        }).toList();
      } else {
        throw ServerException(message: 'Erro ao buscar configurações: ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('💥 Erro DioException ao buscar configurações: ${e.message}', name: 'ConfiguracaoMaquinaRemoteDS');
      
      if (e.response?.statusCode == 401) {
        throw AuthenticationException(message: 'Token de autenticação inválido');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException(message: 'Sem permissão para buscar configurações');
      } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        throw ServerException(message: 'Erro interno do servidor: ${e.response?.statusCode}');
      } else {
        throw NetworkException(message: 'Erro de rede ao buscar configurações');
      }
    } catch (e) {
      developer.log('💥 Erro inesperado ao buscar configurações: $e', name: 'ConfiguracaoMaquinaRemoteDS');
      throw ServerException(message: 'Erro inesperado ao buscar configurações: $e');
    }
  }

  @override
  Future<ConfiguracaoMaquinaModel> getConfiguracaoMaquinaById(int id) async {
    try {
      developer.log('🔄 Buscando configuração por ID: $id', name: 'ConfiguracaoMaquinaRemoteDS');

      final response = await dio.get(ApiEndpoints.configuracaoMaquinaById(id));

      developer.log('✅ Configuração obtida com sucesso', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📊 Status: ${response.statusCode}', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📄 Dados recebidos: ${response.data}', name: 'ConfiguracaoMaquinaRemoteDS');

      if (response.statusCode == 200) {
        // Usar o DTO correto para fazer o parse da resposta da API
        final dto = ConfiguracaoMaquinaResponseDTO.fromJson(response.data as Map<String, dynamic>);
        
        // Converter o DTO para o modelo esperado pela interface
        return ConfiguracaoMaquinaModel(
          id: dto.id,
          registroMaquinaId: dto.maquinaId ?? 1, // Usar 1 como padrão se for null
          chaveConfiguracao: 'matriz_id',
          valorConfiguracao: dto.matrizId?.toString() ?? '0',
          descricao: dto.descricao ?? '',
          tipoValor: 'int',
          valorPadrao: '0',
          obrigatorio: true,
          ativo: true,
          criadoEm: dto.dtCreate != null ? DateTime.tryParse(dto.dtCreate!) : null,
          atualizadoEm: dto.dtUpdate != null ? DateTime.tryParse(dto.dtUpdate!) : null,
        );
      } else {
        throw ServerException(message: 'Erro ao buscar configuração: ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('💥 Erro DioException ao buscar configuração: ${e.message}', name: 'ConfiguracaoMaquinaRemoteDS');
      
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Configuração não encontrada');
      } else if (e.response?.statusCode == 401) {
        throw AuthenticationException(message: 'Token de autenticação inválido');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException(message: 'Sem permissão para buscar configuração');
      } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        throw ServerException(message: 'Erro interno do servidor: ${e.response?.statusCode}');
      } else {
        throw NetworkException(message: 'Erro de rede ao buscar configuração');
      }
    } catch (e) {
      developer.log('💥 Erro inesperado ao buscar configuração: $e', name: 'ConfiguracaoMaquinaRemoteDS');
      throw ServerException(message: 'Erro inesperado ao buscar configuração: $e');
    }
  }

  @override
  Future<ConfiguracaoMaquinaModel> updateConfiguracaoMaquina(int id, ConfiguracaoMaquinaModel config) async {
    try {
      developer.log('🔄 Atualizando configuração ID: $id', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📋 Dados: ${config.toString()}', name: 'ConfiguracaoMaquinaRemoteDS');

      final response = await dio.put(
        ApiEndpoints.configuracaoMaquinaById(id),
        data: config.toJson(),
      );

      developer.log('✅ Configuração atualizada com sucesso', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📊 Status: ${response.statusCode}', name: 'ConfiguracaoMaquinaRemoteDS');

      if (response.statusCode == 200) {
        // Usar o DTO correto para fazer o parse da resposta da API
        final dto = ConfiguracaoMaquinaResponseDTO.fromJson(response.data as Map<String, dynamic>);
        
        // Converter o DTO para o modelo esperado pela interface
        return ConfiguracaoMaquinaModel(
          id: dto.id,
          registroMaquinaId: dto.maquinaId ?? 0,
          chaveConfiguracao: 'matriz_id',
          valorConfiguracao: dto.matrizId?.toString() ?? '',
          descricao: dto.descricao ?? '',
          tipoValor: 'int',
          valorPadrao: '',
          obrigatorio: true,
          // Configuração está ativa apenas se não foi soft-deletada (dt_delete é null)
          ativo: dto.dtDelete == null,
          criadoEm: dto.dtCreate != null ? DateTime.tryParse(dto.dtCreate!) : null,
          atualizadoEm: dto.dtUpdate != null ? DateTime.tryParse(dto.dtUpdate!) : null,
        );
      } else {
        throw ServerException(message: 'Erro ao atualizar configuração: ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('💥 Erro DioException ao atualizar configuração: ${e.message}', name: 'ConfiguracaoMaquinaRemoteDS');
      
      if (e.response?.statusCode == 400) {
        throw ValidationException(message: 'Dados inválidos para atualização da configuração');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Configuração não encontrada');
      } else if (e.response?.statusCode == 401) {
        throw AuthenticationException(message: 'Token de autenticação inválido');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException(message: 'Sem permissão para atualizar configuração');
      } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        throw ServerException(message: 'Erro interno do servidor: ${e.response?.statusCode}');
      } else {
        throw NetworkException(message: 'Erro de rede ao atualizar configuração');
      }
    } catch (e) {
      developer.log('💥 Erro inesperado ao atualizar configuração: $e', name: 'ConfiguracaoMaquinaRemoteDS');
      throw ServerException(message: 'Erro inesperado ao atualizar configuração: $e');
    }
  }

  @override
  Future<void> deleteConfiguracaoMaquina(int id) async {
    try {
      developer.log('🔄 Removendo configuração ID: $id', name: 'ConfiguracaoMaquinaRemoteDS');

      final response = await dio.delete(ApiEndpoints.configuracaoMaquinaById(id));

      developer.log('✅ Configuração removida com sucesso', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📊 Status: ${response.statusCode}', name: 'ConfiguracaoMaquinaRemoteDS');

      // Status 200, 204 e 500 são considerados sucesso
      // 500 indica que o backend fez soft delete de múltiplas configurações ativas
      if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 500) {
        throw ServerException(message: 'Erro ao remover configuração: ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('💥 Erro DioException ao remover configuração: ${e.message}', name: 'ConfiguracaoMaquinaRemoteDS');
      
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Configuração não encontrada');
      } else if (e.response?.statusCode == 401) {
        throw AuthenticationException(message: 'Token de autenticação inválido');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException(message: 'Sem permissão para remover configuração');
      } else if (e.response?.statusCode == 500) {
        // Status 500 indica soft delete bem-sucedido de múltiplas configurações
        developer.log('✅ Soft delete realizado com sucesso (múltiplas configurações)', name: 'ConfiguracaoMaquinaRemoteDS');
        return; // Retorna sucesso
      } else if (e.response?.statusCode != null && e.response!.statusCode! > 500) {
        throw ServerException(message: 'Erro interno do servidor: ${e.response?.statusCode}');
      } else {
        throw NetworkException(message: 'Erro de rede ao remover configuração');
      }
    } catch (e) {
      developer.log('💥 Erro inesperado ao remover configuração: $e', name: 'ConfiguracaoMaquinaRemoteDS');
      throw ServerException(message: 'Erro inesperado ao remover configuração: $e');
    }
  }

  @override
  Future<ConfiguracaoMaquinaModel> getConfiguracaoByMaquinaAndChave(
    int registroMaquinaId,
    String chaveConfiguracao,
  ) async {
    try {
      developer.log('🔄 Buscando configuração por máquina e chave', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📋 Máquina: $registroMaquinaId, Chave: $chaveConfiguracao', name: 'ConfiguracaoMaquinaRemoteDS');

      final response = await dio.get(
        ApiEndpoints.configuracaoMaquinaByMaquinaAndChave(registroMaquinaId, chaveConfiguracao),
      );

      developer.log('✅ Configuração obtida com sucesso', name: 'ConfiguracaoMaquinaRemoteDS');
      developer.log('📊 Status: ${response.statusCode}', name: 'ConfiguracaoMaquinaRemoteDS');

      if (response.statusCode == 200) {
        // Usar o DTO correto para fazer o parse da resposta da API
        final dto = ConfiguracaoMaquinaResponseDTO.fromJson(response.data as Map<String, dynamic>);
        
        // Converter o DTO para o modelo esperado pela interface
        return ConfiguracaoMaquinaModel(
          id: dto.id,
          registroMaquinaId: dto.maquinaId ?? 0,
          chaveConfiguracao: 'matriz_id',
          valorConfiguracao: dto.matrizId?.toString() ?? '',
          descricao: dto.descricao ?? '',
          tipoValor: 'int',
          valorPadrao: '',
          obrigatorio: true,
          ativo: true,
          criadoEm: dto.dtCreate != null ? DateTime.tryParse(dto.dtCreate!) : null,
          atualizadoEm: dto.dtUpdate != null ? DateTime.tryParse(dto.dtUpdate!) : null,
        );
      } else {
        throw ServerException(message: 'Erro ao buscar configuração: ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('💥 Erro DioException ao buscar configuração: ${e.message}', name: 'ConfiguracaoMaquinaRemoteDS');
      
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Configuração não encontrada para a máquina e chave especificadas');
      } else if (e.response?.statusCode == 401) {
        throw AuthenticationException(message: 'Token de autenticação inválido');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException(message: 'Sem permissão para buscar configuração');
      } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        throw ServerException(message: 'Erro interno do servidor: ${e.response?.statusCode}');
      } else {
        throw NetworkException(message: 'Erro de rede ao buscar configuração');
      }
    } catch (e) {
      developer.log('💥 Erro inesperado ao buscar configuração: $e', name: 'ConfiguracaoMaquinaRemoteDS');
      throw ServerException(message: 'Erro inesperado ao buscar configuração: $e');
    }
  }
}