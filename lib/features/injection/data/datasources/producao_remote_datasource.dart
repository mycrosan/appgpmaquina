import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/data/models/auth_token_model.dart';
import '../models/producao_response_model.dart';
import '../../../../core/errors/exceptions.dart';

/// Interface para o datasource remoto da API de produção
abstract class ProducaoRemoteDataSource {
  /// Busca dados da carcaça pelo número da etiqueta
  Future<List<ProducaoResponseModel>> pesquisarCarcaca(String numeroEtiqueta);
}

/// Implementação do datasource remoto da API de produção
class ProducaoRemoteDataSourceImpl implements ProducaoRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ProducaoRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

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
            name: 'ProducaoRemoteDataSource',
          );
          developer.log(
            '  - Token Type: ${token.tokenType}',
            name: 'ProducaoRemoteDataSource',
          );
          developer.log(
            '  - Expires At: ${token.expiresAt}',
            name: 'ProducaoRemoteDataSource',
          );
          developer.log(
            '  - Is Valid: ${token.isValid}',
            name: 'ProducaoRemoteDataSource',
          );
        } else {
          developer.log(
            '⚠️ Token expirado, requisição sem autenticação',
            name: 'ProducaoRemoteDataSource',
          );
        }
      } else {
        developer.log(
          '⚠️ Nenhum token encontrado, requisição sem autenticação',
          name: 'ProducaoRemoteDataSource',
        );
      }
    } catch (e) {
      developer.log(
        '❌ Erro ao obter token de autenticação: $e',
        name: 'ProducaoRemoteDataSource',
      );
    }

    return headers;
  }

  @override
  Future<List<ProducaoResponseModel>> pesquisarCarcaca(String numeroEtiqueta) async {
    try {
      final url = Uri.parse('$baseUrl/producao/pesquisa?numeroEtiqueta=$numeroEtiqueta');
      final headers = await _getAuthHeaders();
      headers['Accept'] = 'application/json';
      
      print('[PRODUCAO_API] 🔍 Pesquisando carcaça: $numeroEtiqueta');
      print('[PRODUCAO_API] 🌐 URL: $url');
      print('[PRODUCAO_API] 🏠 Base URL: $baseUrl');
      print('[PRODUCAO_API] 🔐 Headers: $headers');
      
      final response = await client.get(url, headers: headers);
      
      print('[PRODUCAO_API] 📥 Status Code: ${response.statusCode}');
      print('[PRODUCAO_API] 📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => ProducaoResponseModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 404) {
        // Retorna lista vazia se não encontrar a carcaça
        return [];
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw ValidationException(message: 'Dados inválidos: ${response.body}');
      } else if (response.statusCode >= 500) {
        throw ServerException(message: 'Erro interno do servidor: ${response.statusCode}');
      } else {
        throw ServerException(message: 'Erro inesperado: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ValidationException || e is ServerException) {
        rethrow;
      }
      throw NetworkException(message: 'Erro de conexão: ${e.toString()}');
    }
  }
}