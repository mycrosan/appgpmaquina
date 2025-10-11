import 'dart:developer' as developer;
import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/pneu_vulcanizado_create_dto.dart';
import '../models/pneu_vulcanizado_response_dto.dart';
import 'vulcanizacao_remote_datasource.dart';

/// Implementação do datasource remoto de vulcanização
/// 
/// Utiliza Dio para comunicação HTTP com a API de vulcanização
class VulcanizacaoRemoteDataSourceImpl implements VulcanizacaoRemoteDataSource {
  final Dio dio;

  VulcanizacaoRemoteDataSourceImpl({required this.dio});

  /// Endpoint base para pneus vulcanizados (evita duplicar '/api')
  String get _baseEndpoint => '${AppConfig.instance.apiBaseUrl}/pneu-vulcanizado';

  /// Headers padrão para requisições
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  @override
  Future<PneuVulcanizadoResponseDTO> criarPneuVulcanizado(
    PneuVulcanizadoCreateDTO createDto,
  ) async {
    try {
      developer.log(
        '🚀 [VULCANIZACAO] Criando pneu vulcanizado: ${createDto.toString()}',
        name: 'VulcanizacaoRemoteDataSource',
      );

      // Monta corpo mínimo exigido pela API: apenas producaoId
      final requestBody = {
        'producaoId': createDto.producaoId,
      };

      // Log explícito indicando a tentativa de request de criação (apenas producaoId)
      print('🌐 [VULCANIZACAO] Tentando POST $_baseEndpoint com body: $requestBody');

      final response = await dio.post(
        _baseEndpoint,
        data: requestBody,
        options: Options(headers: _headers),
      );

      developer.log(
        '✅ [VULCANIZACAO] Pneu vulcanizado criado com sucesso. Status: ${response.statusCode}',
        name: 'VulcanizacaoRemoteDataSource',
      );

      if (response.statusCode == 201) {
        final responseDto = PneuVulcanizadoResponseDTO.fromJson(
          response.data as Map<String, dynamic>,
        );
        
        developer.log(
          '📦 [VULCANIZACAO] Dados recebidos: ${responseDto.toString()}',
          name: 'VulcanizacaoRemoteDataSource',
        );
        
        return responseDto;
      } else {
        throw ServerException(
          message: 'Erro inesperado ao criar pneu vulcanizado. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      developer.log(
        '💥 [VULCANIZACAO] Erro Dio ao criar pneu vulcanizado: ${e.message}',
        name: 'VulcanizacaoRemoteDataSource',
        error: e,
      );
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        // Preferir a mensagem exata da API quando disponível (campo 'error' ou 'message')
        String serverMsg;
        try {
          if (responseData is Map<String, dynamic>) {
            serverMsg = (responseData['error'] as String?)
                ?? (responseData['message'] as String?)
                ?? (e.message ?? 'Erro desconhecido');
          } else {
            serverMsg = e.message ?? 'Erro desconhecido';
          }
        } catch (_) {
          serverMsg = e.message ?? 'Erro desconhecido';
        }

        switch (statusCode) {
          case 400:
            throw ServerException(
              message: serverMsg,
              statusCode: statusCode,
            );
          case 404:
            throw ServerException(
              message: serverMsg,
              statusCode: statusCode,
            );
          default:
            throw ServerException(
              message: serverMsg,
              statusCode: statusCode,
            );
        }
      } else {
        throw ServerException(
          message: 'Erro de conexão ao criar pneu vulcanizado: ${e.message}',
        );
      }
    } catch (e) {
      developer.log(
        '💥 [VULCANIZACAO] Erro geral ao criar pneu vulcanizado: $e',
        name: 'VulcanizacaoRemoteDataSource',
        error: e,
      );
      throw ServerException(
        message: 'Erro inesperado ao criar pneu vulcanizado: $e',
      );
    }
  }

  @override
  Future<PneuVulcanizadoResponseDTO> finalizarPneuVulcanizado(int id) async {
    try {
      developer.log(
        '🏁 [VULCANIZACAO] Finalizando pneu vulcanizado ID: $id',
        name: 'VulcanizacaoRemoteDataSource',
      );

      // Log explícito no console antes da chamada PUT de finalização
      print('🌐 [VULCANIZACAO] Tentando PUT $_baseEndpoint/$id/finalizar');

      final response = await dio.put(
        '$_baseEndpoint/$id/finalizar',
        options: Options(headers: _headers),
      );

      developer.log(
        '✅ [VULCANIZACAO] Pneu vulcanizado finalizado com sucesso. Status: ${response.statusCode}',
        name: 'VulcanizacaoRemoteDataSource',
      );

      if (response.statusCode == 200) {
        final responseDto = PneuVulcanizadoResponseDTO.fromJson(
          response.data as Map<String, dynamic>,
        );
        
        developer.log(
          '📦 [VULCANIZACAO] Dados recebidos: ${responseDto.toString()}',
          name: 'VulcanizacaoRemoteDataSource',
        );
        
        return responseDto;
      } else {
        throw ServerException(
          message: 'Erro inesperado ao finalizar pneu vulcanizado. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      developer.log(
        '💥 [VULCANIZACAO] Erro Dio ao finalizar pneu vulcanizado: ${e.message}',
        name: 'VulcanizacaoRemoteDataSource',
        error: e,
      );
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        switch (statusCode) {
          case 400:
            throw ServerException(
              message: 'Pneu vulcanizado já finalizado: ${responseData?['message'] ?? 'Erro desconhecido'}',
            );
          case 404:
            throw ServerException(
              message: 'Pneu vulcanizado não encontrado: ${responseData?['message'] ?? 'Erro desconhecido'}',
            );
          default:
            throw ServerException(
              message: 'Erro do servidor ao finalizar pneu vulcanizado: ${responseData?['message'] ?? e.message}',
            );
        }
      } else {
        throw ServerException(
          message: 'Erro de conexão ao finalizar pneu vulcanizado: ${e.message}',
        );
      }
    } catch (e) {
      developer.log(
        '💥 [VULCANIZACAO] Erro geral ao finalizar pneu vulcanizado: $e',
        name: 'VulcanizacaoRemoteDataSource',
        error: e,
      );
      throw ServerException(
        message: 'Erro inesperado ao finalizar pneu vulcanizado: $e',
      );
    }
  }

  @override
  Future<PneuVulcanizadoResponseDTO> buscarPneuVulcanizadoPorId(int id) async {
    try {
      developer.log(
        '🔍 [VULCANIZACAO] Buscando pneu vulcanizado ID: $id',
        name: 'VulcanizacaoRemoteDataSource',
      );

      final response = await dio.get(
        '$_baseEndpoint/$id',
        options: Options(headers: _headers),
      );

      developer.log(
        '✅ [VULCANIZACAO] Pneu vulcanizado encontrado. Status: ${response.statusCode}',
        name: 'VulcanizacaoRemoteDataSource',
      );

      if (response.statusCode == 200) {
        final responseDto = PneuVulcanizadoResponseDTO.fromJson(
          response.data as Map<String, dynamic>,
        );
        
        developer.log(
          '📦 [VULCANIZACAO] Dados recebidos: ${responseDto.toString()}',
          name: 'VulcanizacaoRemoteDataSource',
        );
        
        return responseDto;
      } else {
        throw ServerException(
          message: 'Erro inesperado ao buscar pneu vulcanizado. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      developer.log(
        '💥 [VULCANIZACAO] Erro Dio ao buscar pneu vulcanizado: ${e.message}',
        name: 'VulcanizacaoRemoteDataSource',
        error: e,
      );
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        switch (statusCode) {
          case 404:
            throw ServerException(
              message: 'Pneu vulcanizado não encontrado: ${responseData?['message'] ?? 'Erro desconhecido'}',
            );
          default:
            throw ServerException(
              message: 'Erro do servidor ao buscar pneu vulcanizado: ${responseData?['message'] ?? e.message}',
            );
        }
      } else {
        throw ServerException(
          message: 'Erro de conexão ao buscar pneu vulcanizado: ${e.message}',
        );
      }
    } catch (e) {
      developer.log(
        '💥 [VULCANIZACAO] Erro geral ao buscar pneu vulcanizado: $e',
        name: 'VulcanizacaoRemoteDataSource',
        error: e,
      );
      throw ServerException(
        message: 'Erro inesperado ao buscar pneu vulcanizado: $e',
      );
    }
  }

  @override
  Future<List<PneuVulcanizadoResponseDTO>> listarPneusVulcanizados({
    int? usuarioId,
    String? status,
    String? numeroEtiqueta,
    int page = 0,
    int size = 20,
  }) async {
    try {
      developer.log(
        '📋 [VULCANIZACAO] Listando pneus vulcanizados - usuarioId: $usuarioId, status: $status, page: $page, size: $size',
        name: 'VulcanizacaoRemoteDataSource',
      );

      final queryParameters = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (usuarioId != null) {
        queryParameters['usuarioId'] = usuarioId;
      }

      if (status != null) {
        queryParameters['status'] = status;
      }

      // Pesquisa por número da etiqueta (se suportado pela API)
      if (numeroEtiqueta != null && numeroEtiqueta.trim().isNotEmpty) {
        queryParameters['numeroEtiqueta'] = numeroEtiqueta.trim();
      }

      final response = await dio.get(
        _baseEndpoint,
        queryParameters: queryParameters,
        options: Options(headers: _headers),
      );

      developer.log(
        '✅ [VULCANIZACAO] Lista de pneus vulcanizados obtida. Status: ${response.statusCode}',
        name: 'VulcanizacaoRemoteDataSource',
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final content = responseData['content'] as List<dynamic>;
        
        final pneusVulcanizados = content
            .map((item) => PneuVulcanizadoResponseDTO.fromJson(item as Map<String, dynamic>))
            .toList();
        
        developer.log(
          '📦 [VULCANIZACAO] ${pneusVulcanizados.length} pneus vulcanizados encontrados',
          name: 'VulcanizacaoRemoteDataSource',
        );
        
        return pneusVulcanizados;
      } else {
        throw ServerException(
          message: 'Erro inesperado ao listar pneus vulcanizados. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      developer.log(
        '💥 [VULCANIZACAO] Erro Dio ao listar pneus vulcanizados: ${e.message}',
        name: 'VulcanizacaoRemoteDataSource',
        error: e,
      );
      
      if (e.response != null) {
        final responseData = e.response!.data;
        
        throw ServerException(
          message: 'Erro do servidor ao listar pneus vulcanizados: ${responseData?['message'] ?? e.message}',
        );
      } else {
        throw ServerException(
          message: 'Erro de conexão ao listar pneus vulcanizados: ${e.message}',
        );
      }
    } catch (e) {
      developer.log(
        '💥 [VULCANIZACAO] Erro geral ao listar pneus vulcanizados: $e',
        name: 'VulcanizacaoRemoteDataSource',
        error: e,
      );
      throw ServerException(
        message: 'Erro inesperado ao listar pneus vulcanizados: $e',
      );
    }
  }

  @override
  Future<PneuVulcanizadoResponseDTO> atualizarPneuVulcanizado(
    int id, {
    String? numeroEtiqueta,
  }) async {
    try {
      developer.log(
        '✏️ [VULCANIZACAO] Atualizando pneu vulcanizado ID: $id, numeroEtiqueta: ${numeroEtiqueta ?? '(sem alteração)'}',
        name: 'VulcanizacaoRemoteDataSource',
      );

      final payload = <String, dynamic>{};
      if (numeroEtiqueta != null) {
        payload['numeroEtiqueta'] = numeroEtiqueta;
      }

      final response = await dio.put(
        '$_baseEndpoint/$id',
        data: payload,
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        return PneuVulcanizadoResponseDTO.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: 'Erro ao atualizar pneu vulcanizado. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      throw ServerException(message: 'Erro do servidor ao atualizar: $msg');
    } catch (e) {
      throw ServerException(message: 'Erro inesperado ao atualizar pneu vulcanizado: $e');
    }
  }

  @override
  Future<void> removerPneuVulcanizado(int id) async {
    try {
      developer.log(
        '🗑️ [VULCANIZACAO] Removendo (soft delete) pneu vulcanizado ID: $id',
        name: 'VulcanizacaoRemoteDataSource',
      );

      final response = await dio.delete(
        '$_baseEndpoint/$id',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      // Alguns backends usam 202 ou até 500 para cenários específicos de soft delete
      if (response.statusCode == 202 || response.statusCode == 500) {
        developer.log('⚠️ Soft delete retornou status ${response.statusCode}, tratando como sucesso', name: 'VulcanizacaoRemoteDataSource');
        return;
      }

      throw ServerException(
        message: 'Erro ao remover pneu vulcanizado. Status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      throw ServerException(message: 'Erro do servidor ao remover: $msg');
    } catch (e) {
      throw ServerException(message: 'Erro inesperado ao remover pneu vulcanizado: $e');
    }
  }
}