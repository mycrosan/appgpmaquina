import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/network_config.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/matriz_model.dart';
import '../models/machine_config_model.dart';
import '../../../auth/data/models/auth_token_model.dart';

/// Implementação simplificada do MachineRemoteDataSource
/// Contém apenas os métodos essenciais para o funcionamento do MachineConfigBloc
class MachineRemoteDataSourceImpl {
  final http.Client client;

  MachineRemoteDataSourceImpl({required this.client}) {
    developer.log('🌐 MachineRemoteDataSourceImpl inicializado', name: 'MachineRemoteDataSource');
  }

  /// Obtém headers com autenticação para as requisições
  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenJson = prefs.getString('auth_token');

      if (tokenJson != null) {
        final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
        final tokenModel = AuthTokenModel.fromJson(tokenMap);
        final token = tokenModel.toEntity();

        if (token.isValid) {
          headers['Authorization'] = token.authorizationHeader;
          developer.log('🔐 Token de autenticação adicionado aos headers', name: 'MachineRemoteDataSource');
          developer.log('  - Token Type: ${token.tokenType}', name: 'MachineRemoteDataSource');
          developer.log('  - Expires At: ${token.expiresAt}', name: 'MachineRemoteDataSource');
          developer.log('  - Is Valid: ${token.isValid}', name: 'MachineRemoteDataSource');
        } else {
          developer.log('⚠️ Token expirado, requisição sem autenticação', name: 'MachineRemoteDataSource');
        }
      } else {
        developer.log('⚠️ Nenhum token encontrado, requisição sem autenticação', name: 'MachineRemoteDataSource');
      }
    } catch (e) {
      developer.log('❌ Erro ao obter token de autenticação: $e', name: 'MachineRemoteDataSource');
    }

    return headers;
  }

  Future<List<MatrizModel>> getAllMatrizes() async {
    developer.log('📋 Iniciando busca de todas as matrizes', name: 'MachineRemoteDataSource');
    final endpoint = AppConfig.instance.matrizEndpoint;
    developer.log('🔗 Endpoint: $endpoint', name: 'MachineRemoteDataSource');
    
    try {
      developer.log('📤 Fazendo requisição GET para buscar matrizes', name: 'MachineRemoteDataSource');
      final headers = await _getAuthHeaders();
      developer.log('📋 Headers da requisição: $headers', name: 'MachineRemoteDataSource');
      
      final response = await client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      developer.log('📥 Resposta recebida - Status: ${response.statusCode}', name: 'MachineRemoteDataSource');
      developer.log('📏 Tamanho da resposta: ${response.body.length} caracteres', name: 'MachineRemoteDataSource');
      developer.log('📄 Corpo completo da resposta: ${response.body}', name: 'MachineRemoteDataSource');
      developer.log('🔍 Headers da resposta: ${response.headers}', name: 'MachineRemoteDataSource');

      if (response.statusCode == 200) {
        developer.log('✅ Requisição bem-sucedida, processando dados', name: 'MachineRemoteDataSource');
        try {
          final List<dynamic> jsonList = json.decode(response.body);
          developer.log('📊 JSON decodificado: $jsonList', name: 'MachineRemoteDataSource');
          developer.log('📊 Matrizes encontradas: ${jsonList.length} itens', name: 'MachineRemoteDataSource');
          
          final matrizes = jsonList.map((json) => MatrizModel.fromJson(json)).toList();
          developer.log('✅ Matrizes processadas com sucesso:', name: 'MachineRemoteDataSource');
          for (var matriz in matrizes) {
            developer.log('  - ${matriz.nome} (${matriz.codigo}) - ID: ${matriz.id} - Ativa: ${matriz.isActive}', name: 'MachineRemoteDataSource');
          }
          return matrizes;
        } catch (e) {
          developer.log('💥 Erro ao processar JSON das matrizes: $e', name: 'MachineRemoteDataSource');
          developer.log('📄 JSON que causou erro: ${response.body}', name: 'MachineRemoteDataSource');
          throw ServerException(message: 'Erro ao processar resposta do servidor: $e');
        }
      } else {
        AppLogger.error('Erro na requisição - Status: ${response.statusCode}', name: 'MachineRemoteDataSource');
        AppLogger.error('Corpo da resposta de erro: ${response.body}', name: 'MachineRemoteDataSource');
        AppLogger.error('Headers da resposta de erro: ${response.headers}', name: 'MachineRemoteDataSource');
        
        // Tenta extrair mensagem de erro do corpo da resposta
        String errorMessage = 'Falha ao buscar matrizes';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map<String, dynamic>) {
            errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
            developer.log('📝 Mensagem de erro extraída: $errorMessage', name: 'MachineRemoteDataSource');
          }
        } catch (e) {
          developer.log('⚠️ Não foi possível extrair mensagem de erro do JSON: $e', name: 'MachineRemoteDataSource');
        }
        
        throw ServerException(message: '$errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (e is ServerException) {
        AppLogger.error('Erro do servidor: ${e.message}', name: 'MachineRemoteDataSource');
        rethrow;
      }
      AppLogger.error('Erro de rede: $e', name: 'MachineRemoteDataSource');
      throw NetworkException(message: 'Network error: $e');
    }
  }

  Future<MachineConfigModel> getCurrentMachineConfig(String deviceId, String userId) async {
    developer.log('🔍 Iniciando busca da configuração atual da máquina', name: 'MachineRemoteDataSource');
    developer.log('  - Device ID: $deviceId', name: 'MachineRemoteDataSource');
    developer.log('  - User ID: $userId', name: 'MachineRemoteDataSource');
    
    final endpoint = '${AppConfig.instance.machineConfigEndpoint}/$deviceId/$userId';
    developer.log('🔗 Endpoint: $endpoint', name: 'MachineRemoteDataSource');
    
    try {
      developer.log('📤 Fazendo requisição GET para buscar configuração', name: 'MachineRemoteDataSource');
      final headers = await _getAuthHeaders();
      developer.log('📋 Headers da requisição: $headers', name: 'MachineRemoteDataSource');
      
      final response = await client.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      developer.log('📥 Resposta recebida - Status: ${response.statusCode}', name: 'MachineRemoteDataSource');
      developer.log('📏 Tamanho da resposta: ${response.body.length} caracteres', name: 'MachineRemoteDataSource');
      developer.log('📄 Corpo completo da resposta: ${response.body}', name: 'MachineRemoteDataSource');
      developer.log('🔍 Headers da resposta: ${response.headers}', name: 'MachineRemoteDataSource');

      if (response.statusCode == 200) {
        developer.log('✅ Configuração encontrada, processando dados', name: 'MachineRemoteDataSource');
        try {
          final json = jsonDecode(response.body);
          developer.log('📊 JSON decodificado: $json', name: 'MachineRemoteDataSource');
          
          final config = MachineConfigModel.fromJson(json);
          developer.log('✅ Configuração processada com sucesso:', name: 'MachineRemoteDataSource');
          developer.log('  - Config ID: ${config.id}', name: 'MachineRemoteDataSource');
          developer.log('  - Device ID: ${config.deviceId}', name: 'MachineRemoteDataSource');
          developer.log('  - User ID: ${config.userId}', name: 'MachineRemoteDataSource');
          developer.log('  - Matriz ID: ${config.matrizId}', name: 'MachineRemoteDataSource');
          developer.log('  - Configurada em: ${config.configuredAt}', name: 'MachineRemoteDataSource');
          developer.log('  - Ativa: ${config.isActive}', name: 'MachineRemoteDataSource');
          
          return config;
        } catch (e) {
          developer.log('💥 Erro ao processar JSON da configuração: $e', name: 'MachineRemoteDataSource');
          developer.log('📄 JSON que causou erro: ${response.body}', name: 'MachineRemoteDataSource');
          throw ServerException(message: 'Erro ao processar resposta do servidor: $e');
        }
      } else if (response.statusCode == 404) {
        developer.log('ℹ️ Configuração não encontrada (404)', name: 'MachineRemoteDataSource');
        developer.log('📄 Corpo da resposta 404: ${response.body}', name: 'MachineRemoteDataSource');
        throw ServerException(message: 'Configuração da máquina não encontrada');
      } else {
        AppLogger.error('Erro na requisição - Status: ${response.statusCode}', name: 'MachineRemoteDataSource');
        AppLogger.error('Corpo da resposta de erro: ${response.body}', name: 'MachineRemoteDataSource');
        AppLogger.error('Headers da resposta de erro: ${response.headers}', name: 'MachineRemoteDataSource');
        
        // Tenta extrair mensagem de erro do corpo da resposta
        String errorMessage = 'Falha ao buscar configuração da máquina';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map<String, dynamic>) {
            errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
            developer.log('📝 Mensagem de erro extraída: $errorMessage', name: 'MachineRemoteDataSource');
          }
        } catch (e) {
          developer.log('⚠️ Não foi possível extrair mensagem de erro do JSON: $e', name: 'MachineRemoteDataSource');
        }
        
        throw ServerException(message: '$errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (e is ServerException) {
        AppLogger.error('Erro do servidor: ${e.message}', name: 'MachineRemoteDataSource');
        rethrow;
      }
      AppLogger.error('Erro de rede: $e', name: 'MachineRemoteDataSource');
      throw NetworkException(message: 'Network error: $e');
    }
  }

  Future<MachineConfigModel> selectMatrizForMachine(String deviceId, String userId, int matrizId) async {
    developer.log('💾 Iniciando seleção de matriz para máquina', name: 'MachineRemoteDataSource');
    developer.log('  - Device ID: $deviceId', name: 'MachineRemoteDataSource');
    developer.log('  - User ID: $userId', name: 'MachineRemoteDataSource');
    developer.log('  - Matriz ID: $matrizId', name: 'MachineRemoteDataSource');
    
    final endpoint = AppConfig.instance.selectMatrizEndpoint;
    developer.log('🔗 Endpoint: $endpoint', name: 'MachineRemoteDataSource');
    
    final requestBody = {
      'deviceId': deviceId,
      'userId': userId,
      'matrizId': matrizId,
    };
    developer.log('📦 Corpo da requisição: ${json.encode(requestBody)}', name: 'MachineRemoteDataSource');
    
    try {
      developer.log('📤 Fazendo requisição POST para selecionar matriz', name: 'MachineRemoteDataSource');
      final headers = await _getAuthHeaders();
      developer.log('📋 Headers da requisição: $headers', name: 'MachineRemoteDataSource');
      
      final response = await client.post(
        Uri.parse(endpoint),
        headers: headers,
        body: json.encode(requestBody),
      );

      developer.log('📥 Resposta recebida - Status: ${response.statusCode}', name: 'MachineRemoteDataSource');
      developer.log('📏 Tamanho da resposta: ${response.body.length} caracteres', name: 'MachineRemoteDataSource');
      developer.log('📄 Corpo completo da resposta: ${response.body}', name: 'MachineRemoteDataSource');
      developer.log('🔍 Headers da resposta: ${response.headers}', name: 'MachineRemoteDataSource');

      if (response.statusCode == 200) {
        developer.log('✅ Matriz selecionada com sucesso, processando dados', name: 'MachineRemoteDataSource');
        try {
          final json = jsonDecode(response.body);
          developer.log('📊 JSON decodificado: $json', name: 'MachineRemoteDataSource');
          
          final config = MachineConfigModel.fromJson(json);
          developer.log('✅ Configuração processada com sucesso:', name: 'MachineRemoteDataSource');
          developer.log('  - Config ID: ${config.id}', name: 'MachineRemoteDataSource');
          developer.log('  - Device ID: ${config.deviceId}', name: 'MachineRemoteDataSource');
          developer.log('  - User ID: ${config.userId}', name: 'MachineRemoteDataSource');
          developer.log('  - Matriz ID: ${config.matrizId}', name: 'MachineRemoteDataSource');
          developer.log('  - Configurada em: ${config.configuredAt}', name: 'MachineRemoteDataSource');
          developer.log('  - Ativa: ${config.isActive}', name: 'MachineRemoteDataSource');
          
          return config;
        } catch (e) {
          developer.log('💥 Erro ao processar JSON da resposta: $e', name: 'MachineRemoteDataSource');
          developer.log('📄 JSON que causou erro: ${response.body}', name: 'MachineRemoteDataSource');
          throw ServerException(message: 'Erro ao processar resposta do servidor: $e');
        }
      } else {
        AppLogger.error('Erro na requisição - Status: ${response.statusCode}', name: 'MachineRemoteDataSource');
        AppLogger.error('Corpo da resposta de erro: ${response.body}', name: 'MachineRemoteDataSource');
        AppLogger.error('Headers da resposta de erro: ${response.headers}', name: 'MachineRemoteDataSource');
        
        // Tenta extrair mensagem de erro do corpo da resposta
        String errorMessage = 'Falha ao selecionar matriz';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map<String, dynamic>) {
            errorMessage = errorJson['message'] ?? errorJson['error'] ?? errorMessage;
            developer.log('📝 Mensagem de erro extraída: $errorMessage', name: 'MachineRemoteDataSource');
          }
        } catch (e) {
          developer.log('⚠️ Não foi possível extrair mensagem de erro do JSON: $e', name: 'MachineRemoteDataSource');
        }
        
        throw ServerException(message: '$errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (e is ServerException) {
        AppLogger.error('Erro do servidor: ${e.message}', name: 'MachineRemoteDataSource');
        rethrow;
      }
      AppLogger.error('Erro de rede: $e', name: 'MachineRemoteDataSource');
      throw NetworkException(message: 'Network error: $e');
    }
  }
}