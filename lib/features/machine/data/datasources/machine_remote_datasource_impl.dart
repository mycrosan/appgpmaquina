import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/network_config.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../injection_container.dart';
import '../models/matriz_model.dart';
import '../models/machine_config_model.dart';
import '../models/configuracao_maquina_dto.dart';
import '../models/registro_maquina_model.dart';
import '../../../auth/data/models/auth_token_model.dart';
import 'registro_maquina_remote_datasource.dart';

/// Implementação simplificada do MachineRemoteDataSource
/// Contém apenas os métodos essenciais para o funcionamento do MachineConfigBloc
class MachineRemoteDataSourceImpl {
  final http.Client client;

  MachineRemoteDataSourceImpl({required this.client}) {
    developer.log(
      '🌐 MachineRemoteDataSourceImpl inicializado',
      name: 'MachineRemoteDataSource',
    );
  }

  // TODO: Implementar método para buscar todas as máquinas
  // Future<List<RegistroMaquinaModel>> getAllMachines() async {
  //   // Implementação futura
  // }

  /// Obtém headers com autenticação para as requisições
  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenJson = prefs.getString('auth_token');

      if (tokenJson != null) {
        final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
        final tokenModel = AuthTokenModel.fromJson(tokenMap);
        final token = tokenModel.toEntity();

        if (token.isValid) {
          headers['Authorization'] = token.authorizationHeader;
          developer.log(
            '🔐 Token de autenticação adicionado aos headers',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '  - Token Type: ${token.tokenType}',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '  - Expires At: ${token.expiresAt}',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '  - Is Valid: ${token.isValid}',
            name: 'MachineRemoteDataSource',
          );
        } else {
          developer.log(
            '⚠️ Token expirado, requisição sem autenticação',
            name: 'MachineRemoteDataSource',
          );
        }
      } else {
        developer.log(
          '⚠️ Nenhum token encontrado, requisição sem autenticação',
          name: 'MachineRemoteDataSource',
        );
      }
    } catch (e) {
      developer.log(
        '❌ Erro ao obter token de autenticação: $e',
        name: 'MachineRemoteDataSource',
      );
    }

    return headers;
  }

  Future<List<MatrizModel>> getAllMatrizes() async {
    developer.log(
      '📋 Iniciando busca de todas as matrizes',
      name: 'MachineRemoteDataSource',
    );
    final endpoint = AppConfig.instance.matrizEndpoint;
    developer.log('🔗 Endpoint: $endpoint', name: 'MachineRemoteDataSource');

    try {
      developer.log(
        '📤 Fazendo requisição GET para buscar matrizes',
        name: 'MachineRemoteDataSource',
      );
      final headers = await _getAuthHeaders();
      developer.log(
        '📋 Headers da requisição: $headers',
        name: 'MachineRemoteDataSource',
      );

      final response = await client.get(Uri.parse(endpoint), headers: headers);

      developer.log(
        '📥 Resposta recebida - Status: ${response.statusCode}',
        name: 'MachineRemoteDataSource',
      );
      developer.log(
        '📏 Tamanho da resposta: ${response.body.length} caracteres',
        name: 'MachineRemoteDataSource',
      );
      developer.log(
        '📄 Corpo completo da resposta: ${response.body}',
        name: 'MachineRemoteDataSource',
      );
      developer.log(
        '🔍 Headers da resposta: ${response.headers}',
        name: 'MachineRemoteDataSource',
      );

      if (response.statusCode == 200) {
        developer.log(
          '✅ Requisição bem-sucedida, processando dados',
          name: 'MachineRemoteDataSource',
        );
        try {
          final List<dynamic> jsonList = json.decode(response.body);
          developer.log(
            '📊 JSON decodificado: $jsonList',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '📊 Matrizes encontradas: ${jsonList.length} itens',
            name: 'MachineRemoteDataSource',
          );

          final matrizes = jsonList
              .map((json) => MatrizModel.fromJson(json))
              .toList();
          developer.log(
            '✅ Matrizes processadas com sucesso:',
            name: 'MachineRemoteDataSource',
          );
          for (var matriz in matrizes) {
            developer.log(
              '  - ${matriz.nome} (${matriz.codigo}) - ID: ${matriz.id} - Ativa: ${matriz.isActive}',
              name: 'MachineRemoteDataSource',
            );
          }
          return matrizes;
        } catch (e) {
          developer.log(
            '💥 Erro ao processar JSON das matrizes: $e',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '📄 JSON que causou erro: ${response.body}',
            name: 'MachineRemoteDataSource',
          );
          throw ServerException(
            message: 'Erro ao processar resposta do servidor: $e',
          );
        }
      } else {
        AppLogger.error(
          'Erro na requisição - Status: ${response.statusCode}',
          name: 'MachineRemoteDataSource',
        );
        AppLogger.error(
          'Corpo da resposta de erro: ${response.body}',
          name: 'MachineRemoteDataSource',
        );
        AppLogger.error(
          'Headers da resposta de erro: ${response.headers}',
          name: 'MachineRemoteDataSource',
        );

        // Tenta extrair mensagem de erro do corpo da resposta
        String errorMessage = 'Falha ao buscar matrizes';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map<String, dynamic>) {
            errorMessage =
                errorJson['message'] ?? errorJson['error'] ?? errorMessage;
            developer.log(
              '📝 Mensagem de erro extraída: $errorMessage',
              name: 'MachineRemoteDataSource',
            );
          }
        } catch (e) {
          developer.log(
            '⚠️ Não foi possível extrair mensagem de erro do JSON: $e',
            name: 'MachineRemoteDataSource',
          );
        }

        throw ServerException(
          message: '$errorMessage (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is ServerException) {
        AppLogger.error(
          'Erro do servidor: ${e.message}',
          name: 'MachineRemoteDataSource',
        );
        rethrow;
      }
      AppLogger.error('Erro de rede: $e', name: 'MachineRemoteDataSource');
      throw NetworkException(message: 'Network error: $e');
    }
  }

  Future<MachineConfigModel> getCurrentMachineConfig(
    String deviceId,
    String userId,
  ) async {
    developer.log(
      '🔍 Iniciando busca da configuração atual da máquina',
      name: 'MachineRemoteDataSource',
    );
    developer.log('  - Device ID: $deviceId', name: 'MachineRemoteDataSource');
    developer.log('  - User ID: $userId', name: 'MachineRemoteDataSource');

    // Novo formato: http://IP:8080/api/configuracao-maquina/celular/CELULARID/ativa
    final endpoint =
        '${AppConfig.instance.apiBaseUrl}/configuracao-maquina/celular/$deviceId/ativa';
    developer.log('🔗 Endpoint: $endpoint', name: 'MachineRemoteDataSource');

    try {
      developer.log(
        '📤 Fazendo requisição GET para buscar configuração',
        name: 'MachineRemoteDataSource',
      );
      final headers = await _getAuthHeaders();
      developer.log(
        '📋 Headers da requisição: $headers',
        name: 'MachineRemoteDataSource',
      );

      final response = await client.get(Uri.parse(endpoint), headers: headers);

      developer.log(
        '📥 Resposta recebida - Status: ${response.statusCode}',
        name: 'MachineRemoteDataSource',
      );
      developer.log(
        '📏 Tamanho da resposta: ${response.body.length} caracteres',
        name: 'MachineRemoteDataSource',
      );
      developer.log(
        '📄 Corpo completo da resposta: ${response.body}',
        name: 'MachineRemoteDataSource',
      );
      developer.log(
        '🔍 Headers da resposta: ${response.headers}',
        name: 'MachineRemoteDataSource',
      );

      if (response.statusCode == 200) {
        developer.log(
          '✅ Configuração encontrada, processando dados',
          name: 'MachineRemoteDataSource',
        );
        try {
          final json = jsonDecode(response.body);
          developer.log(
            '📊 JSON decodificado: $json',
            name: 'MachineRemoteDataSource',
          );

          // Usar o DTO correto para fazer o parse da resposta da API
          final dto = ConfiguracaoMaquinaResponseDTO.fromJson(json);
          
          // Converter o DTO para MachineConfigModel usando o método fromConfiguracao
          final config = MachineConfigModel.fromConfiguracao(
            dto,
            deviceId: deviceId,
            userId: userId,
          );
          
          // Verificar se a configuração foi soft-deletada
          if (!config.isActive) {
            developer.log(
              '⚠️ Configuração encontrada mas foi soft-deletada (dt_delete não é null)',
              name: 'MachineRemoteDataSource',
            );
            throw ServerException(
              message: 'Configuração da máquina não encontrada (soft-deletada)',
            );
          }
          
          developer.log(
            '✅ Configuração processada com sucesso:',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '  - Config ID: ${config.id}',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '  - Device ID: ${config.deviceId}',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '  - User ID: ${config.userId}',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '  - Matriz ID: ${config.matrizId}',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '  - Configurada em: ${config.configuredAt}',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '  - Ativa: ${config.isActive}',
            name: 'MachineRemoteDataSource',
          );

          return config;
        } catch (e) {
          developer.log(
            '💥 Erro ao processar JSON da configuração: $e',
            name: 'MachineRemoteDataSource',
          );
          developer.log(
            '📄 JSON que causou erro: ${response.body}',
            name: 'MachineRemoteDataSource',
          );
          throw ServerException(
            message: 'Erro ao processar resposta do servidor: $e',
          );
        }
      } else if (response.statusCode == 404) {
        developer.log(
          'ℹ️ Configuração não encontrada (404)',
          name: 'MachineRemoteDataSource',
        );
        developer.log(
          '📄 Corpo da resposta 404: ${response.body}',
          name: 'MachineRemoteDataSource',
        );
        throw ServerException(
          message: 'Configuração da máquina não encontrada',
        );
      } else {
        AppLogger.error(
          'Erro na requisição - Status: ${response.statusCode}',
          name: 'MachineRemoteDataSource',
        );
        AppLogger.error(
          'Corpo da resposta de erro: ${response.body}',
          name: 'MachineRemoteDataSource',
        );
        AppLogger.error(
          'Headers da resposta de erro: ${response.headers}',
          name: 'MachineRemoteDataSource',
        );

        // Tenta extrair mensagem de erro do corpo da resposta
        String errorMessage = 'Falha ao buscar configuração da máquina';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map<String, dynamic>) {
            errorMessage =
                errorJson['message'] ?? errorJson['error'] ?? errorMessage;
            developer.log(
              '📝 Mensagem de erro extraída: $errorMessage',
              name: 'MachineRemoteDataSource',
            );
          }
        } catch (e) {
          developer.log(
            '⚠️ Não foi possível extrair mensagem de erro do JSON: $e',
            name: 'MachineRemoteDataSource',
          );
        }

        throw ServerException(
          message: '$errorMessage (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is ServerException) {
        AppLogger.error(
          'Erro do servidor: ${e.message}',
          name: 'MachineRemoteDataSource',
        );
        rethrow;
      }
      AppLogger.error('Erro de rede: $e', name: 'MachineRemoteDataSource');
      throw NetworkException(message: 'Network error: $e');
    }
  }

  Future<MachineConfigModel> selectMatrizForMachine(
    String deviceId,
    String userId,
    int matrizId,
  ) async {
    developer.log(
      '💾 Iniciando seleção de matriz para máquina',
      name: 'MachineRemoteDataSource',
    );
    developer.log('  - Device ID: $deviceId', name: 'MachineRemoteDataSource');
    developer.log('  - User ID: $userId', name: 'MachineRemoteDataSource');
    developer.log('  - Matriz ID: $matrizId', name: 'MachineRemoteDataSource');

    try {
      // Primeiro, buscar a matriz para validar se existe e está ativa
      developer.log(
        '🔍 Buscando dados da matriz ID: $matrizId',
        name: 'MachineRemoteDataSource',
      );
      final matrizResponse = await client.get(
        Uri.parse('${AppConfig.instance.matrizEndpoint}/$matrizId'),
        headers: await _getAuthHeaders(),
      );

      if (matrizResponse.statusCode != 200) {
        developer.log(
          '❌ Matriz não encontrada ou erro ao buscar: ${matrizResponse.statusCode}',
          name: 'MachineRemoteDataSource',
        );
        throw ServerException(message: 'Matriz não encontrada');
      }

      final matrizData = jsonDecode(matrizResponse.body);
      final matriz = MatrizModel.fromJson(matrizData);

      if (!matriz.isActive) {
        developer.log(
          '❌ Matriz não está ativa',
          name: 'MachineRemoteDataSource',
        );
        throw ValidationException(
          message: 'A matriz selecionada não está ativa',
        );
      }

      developer.log(
        '✅ Matriz validada com sucesso: ${matriz.nome}',
        name: 'MachineRemoteDataSource',
      );

      // Criar DTO para configuração de máquina usando o endpoint correto
      final createDto = ConfiguracaoMaquinaCreateDTO(
        maquinaId: int.tryParse(deviceId) ?? 1, // Converter deviceId para int
        matrizId: matrizId,
        celularId: deviceId, // Usar deviceId como celularId
        descricao: 'Configuração de matriz para máquina: ${matriz.nome}',
        atributos: jsonEncode({
          'matriz_selecionada': matrizId,
          'usuario_configuracao': userId,
          'data_configuracao': DateTime.now().toIso8601String(),
        }),
      );

      developer.log(
        '📦 Criando configuração de máquina: ${jsonEncode(createDto.toJson())}',
        name: 'MachineRemoteDataSource',
      );

      // Usar o endpoint correto POST /configuracao-maquina
      final configResponse = await client.post(
        Uri.parse('${AppConfig.instance.apiBaseUrl}/configuracao-maquina'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(createDto.toJson()),
      );

      developer.log(
        '📥 Resposta da configuração - Status: ${configResponse.statusCode}',
        name: 'MachineRemoteDataSource',
      );
      developer.log(
        '📄 Corpo da resposta: ${configResponse.body}',
        name: 'MachineRemoteDataSource',
      );

      if (configResponse.statusCode == 200 ||
          configResponse.statusCode == 201) {
        developer.log(
          '✅ Configuração salva com sucesso',
          name: 'MachineRemoteDataSource',
        );

        // Parse da resposta usando o DTO de resposta
        final responseData = jsonDecode(configResponse.body);
        final responseDto = ConfiguracaoMaquinaResponseDTO.fromJson(
          responseData,
        );

        // Criar MachineConfigModel baseado na resposta do servidor usando o método factory
        final machineConfig = MachineConfigModel.fromConfiguracao(
          responseDto,
          deviceId: deviceId,
          userId: userId,
          matriz: matriz,
        );

        developer.log(
          '✅ Configuração da máquina criada com sucesso:',
          name: 'MachineRemoteDataSource',
        );
        developer.log(
          '  - Config ID: ${machineConfig.id}',
          name: 'MachineRemoteDataSource',
        );
        developer.log(
          '  - Device ID: ${machineConfig.deviceId}',
          name: 'MachineRemoteDataSource',
        );
        developer.log(
          '  - User ID: ${machineConfig.userId}',
          name: 'MachineRemoteDataSource',
        );
        developer.log(
          '  - Matriz ID: ${machineConfig.matrizId}',
          name: 'MachineRemoteDataSource',
        );
        developer.log(
          '  - Matriz Nome: ${machineConfig.matriz?.nome}',
          name: 'MachineRemoteDataSource',
        );
        developer.log(
          '  - Configurada em: ${machineConfig.configuredAt}',
          name: 'MachineRemoteDataSource',
        );
        developer.log(
          '  - Ativa: ${machineConfig.isActive}',
          name: 'MachineRemoteDataSource',
        );

        return machineConfig;
      } else {
        developer.log(
          '❌ Erro ao salvar configuração: ${configResponse.statusCode}',
          name: 'MachineRemoteDataSource',
        );
        developer.log(
          '❌ Resposta de erro: ${configResponse.body}',
          name: 'MachineRemoteDataSource',
        );
        throw ServerException(
          message:
              'Erro ao salvar configuração da matriz: ${configResponse.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is ValidationException) {
        rethrow;
      }
      developer.log(
        '💥 Erro inesperado ao selecionar matriz: $e',
        name: 'MachineRemoteDataSource',
      );
      throw ServerException(message: 'Erro ao processar seleção da matriz: $e');
    }
  }

  @override
  Future<void> removeAllActiveConfigsForDevice(String deviceId) async {
    developer.log(
      '🗑️ Removendo todas as configurações ativas para o dispositivo: $deviceId',
      name: 'MachineRemoteDataSource',
    );

    // Endpoint para remover todas as configurações ativas de um dispositivo
    final endpoint = '${AppConfig.instance.apiBaseUrl}/configuracao-maquina/celular/$deviceId/remover-todas';
    developer.log('🔗 Endpoint: $endpoint', name: 'MachineRemoteDataSource');

    try {
      final headers = await _getAuthHeaders();
      developer.log(
        '📤 Fazendo requisição DELETE para remover todas as configurações',
        name: 'MachineRemoteDataSource',
      );

      final response = await client.delete(Uri.parse(endpoint), headers: headers);

      developer.log(
        '📥 Resposta recebida - Status: ${response.statusCode}',
        name: 'MachineRemoteDataSource',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        developer.log(
          '✅ Todas as configurações ativas removidas com sucesso',
          name: 'MachineRemoteDataSource',
        );
      } else if (response.statusCode == 404) {
        developer.log(
          '⚠️ Nenhuma configuração ativa encontrada para o dispositivo',
          name: 'MachineRemoteDataSource',
        );
        // Não é um erro, apenas não havia configurações para remover
      } else {
        developer.log(
          '💥 Erro ao remover configurações: ${response.statusCode}',
          name: 'MachineRemoteDataSource',
        );
        throw ServerException(
          message: 'Erro ao remover configurações: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      developer.log(
        '💥 Erro inesperado ao remover configurações: $e',
        name: 'MachineRemoteDataSource',
      );
      throw ServerException(
        message: 'Erro ao remover configurações do dispositivo: $e',
      );
    }
  }
}