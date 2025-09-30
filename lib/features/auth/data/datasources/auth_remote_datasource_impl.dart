import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/network_config.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Implementação do data source remoto para autenticação
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthTokenModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final endpoint = AppConfig.instance.loginEndpoint;
      print('🔐 [LOGIN] Tentando login para: $username');
      print('🌐 [LOGIN] Endpoint: $endpoint');

      final response = await client.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'login': username, 'senha': password}),
      );

      print('📡 [LOGIN] Status Code: ${response.statusCode}');
      print('📄 [LOGIN] Response Body: ${response.body}');
      print('📋 [LOGIN] Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        print('✅ [LOGIN] Login bem-sucedido, processando token...');
        return AuthTokenModel.fromLoginResponse(jsonData);
      } else if (response.statusCode == 401) {
        print('❌ [LOGIN] Credenciais inválidas (401)');
        throw AuthenticationException(message: 'Credenciais inválidas');
      } else {
        print('🚨 [LOGIN] Erro do servidor: ${response.statusCode}');
        print('🚨 [LOGIN] Response body: ${response.body}');
        throw ServerException(
          message:
              'Erro no servidor: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('💥 [LOGIN] Exceção capturada: $e');
      print('💥 [LOGIN] Tipo da exceção: ${e.runtimeType}');

      if (e is AuthenticationException || e is ServerException) {
        rethrow;
      }
      throw NetworkException(message: 'Erro de conexão: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final endpoint = AppConfig.instance.userProfileEndpoint;
      print('👤 [GET_CURRENT_USER] Iniciando busca de usuário atual');
      print('🌐 [GET_CURRENT_USER] Endpoint: $endpoint');
      print(
        '🔑 [GET_CURRENT_USER] Token: ${token.isNotEmpty ? "${token.substring(0, 20)}..." : "VAZIO"}',
      );
      print('📦 [GET_CURRENT_USER] Método: GET (sem corpo da requisição)');

      final response = await client.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 [GET_CURRENT_USER] Status Code: ${response.statusCode}');
      print('📄 [GET_CURRENT_USER] Response Body: ${response.body}');
      print('📋 [GET_CURRENT_USER] Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        print('✅ [GET_CURRENT_USER] Sucesso, processando dados do usuário...');
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        print('❌ [GET_CURRENT_USER] Token inválido ou expirado (401)');
        throw AuthenticationException(message: 'Token inválido ou expirado');
      } else {
        print('🚨 [GET_CURRENT_USER] Erro no servidor: ${response.statusCode}');
        print('📄 [GET_CURRENT_USER] Response Body (Erro): ${response.body}');
        throw ServerException(
          message: 'Erro no servidor: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('💥 [GET_CURRENT_USER] Exceção capturada: $e');
      print('🔍 [GET_CURRENT_USER] Tipo da exceção: ${e.runtimeType}');
      if (e is AuthenticationException || e is ServerException) {
        print('🔄 [GET_CURRENT_USER] Relançando exceção conhecida...');
        rethrow;
      }
      print('🌐 [GET_CURRENT_USER] Erro de conexão detectado');
      throw NetworkException(message: 'Erro de conexão: $e');
    }
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await client.post(
        Uri.parse(AppConfig.instance.refreshTokenEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return AuthTokenModel.fromLoginResponse(jsonData);
      } else if (response.statusCode == 401) {
        throw AuthenticationException(
          message: 'Refresh token inválido ou expirado',
        );
      } else {
        throw ServerException(
          message: 'Erro no servidor: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthenticationException || e is ServerException) {
        rethrow;
      }
      throw NetworkException(message: 'Erro de conexão: $e');
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      final response = await client.post(
        Uri.parse(AppConfig.instance.logoutEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Erro no servidor: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException(message: 'Erro de conexão: $e');
    }
  }
}