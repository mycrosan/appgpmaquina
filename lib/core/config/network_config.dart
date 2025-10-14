import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'app_config.dart';
import '../../features/auth/domain/entities/auth_token.dart';
import '../../features/auth/data/models/auth_token_model.dart';

/// Configuração de rede centralizada
class NetworkConfig {
  static Dio? _dio;

  /// Obtém a instância configurada do Dio
  static Dio get dio {
    if (_dio == null) {
      _initializeDio();
    }
    return _dio!;
  }

  /// Inicializa o Dio com as configurações do ambiente
  static void _initializeDio() {
    final config = AppConfig.instance;

    _dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectionTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Adiciona interceptors baseados no ambiente
    if (config.enableLogging) {
      _dio!.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) {
            print('[DIO] $obj');
          },
        ),
      );
    }

    // Interceptor para tratamento de erros
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (config.enableLogging) {
            print('[DIO ERROR] ${error.message}');
            print('[DIO ERROR] Status: ${error.response?.statusCode}');
            print('[DIO ERROR] Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );

    // Interceptor para adicionar token de autenticação
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Obtém o token de autenticação do armazenamento local
            final token = await _getAuthToken();
            if (token != null && token.isValid) {
              options.headers['Authorization'] = token.authorizationHeader;
            }
          } catch (e) {
            if (config.enableLogging) {
              print('[DIO AUTH] Erro ao obter token: $e');
            }
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Reconfigura o Dio (útil para mudanças de ambiente em runtime)
  static void reconfigure() {
    _dio = null;
    _initializeDio();
  }

  /// Obtém o token de autenticação do armazenamento local
  static Future<AuthToken?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenJson = prefs.getString('auth_token');

      if (tokenJson == null) {
        return null;
      }

      final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
      final tokenModel = AuthTokenModel.fromJson(tokenMap);
      return tokenModel.toEntity();
    } catch (e) {
      return null;
    }
  }
}

/// Endpoints da API
class ApiEndpoints {
  // Auth endpoints
  static String get login => '/auth/login';
  static String get logout => '/auth/logout';
  static String get refresh => '/auth/refresh';
  static String get profile => '/auth';

  // Machine endpoints
  static String get matrizes => '/matriz';
  static String get carcacas => '/carcacas';
  static String get regras => '/regras';
  static String machineConfig(String deviceId, String userId) =>
      '/machine-config/$deviceId/$userId';
  static String get selectMatriz => '/machine-config/select-matriz';

  // Injection endpoints
  static String get injections => '/injections';
  static String get injectionHistory => '/injections/history';
  static String injectionById(String id) => '/injections/$id';

  // User endpoints
  static String get users => '/users';
  static String userById(String id) => '/users/$id';

  // Configuracao Maquina endpoints
  static String get configuracaoMaquina => '/configuracao-maquina';
  static String configuracaoMaquinaById(int id) => '/configuracao-maquina/$id';
  static String configuracaoMaquinaByMaquinaAndChave(
    int registroMaquinaId,
    String chaveConfiguracao,
  ) =>
      '/configuracao-maquina/maquina/$registroMaquinaId/chave/$chaveConfiguracao';

  // Relay endpoints
  static String get rele => '/rele';

  // Registro Maquina endpoints
  static String get registroMaquina => '/registro-maquina';
  static String registroMaquinaById(int id) => '/registro-maquina/$id';
}
