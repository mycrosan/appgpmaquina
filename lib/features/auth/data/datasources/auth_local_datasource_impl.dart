import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_token_model.dart';
import 'auth_local_datasource.dart';

/// Implementação do data source local para autenticação
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _authTokenKey = 'auth_token';
  static const String _userCredentialsKey = 'user_credentials';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveAuthToken(AuthTokenModel token) async {
    try {
      final tokenJson = json.encode(token.toJson());
      final success = await sharedPreferences.setString(
        _authTokenKey,
        tokenJson,
      );
      if (!success) {
        throw CacheException(message: 'Falha ao salvar token de autenticação');
      }
    } catch (e) {
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException(message: 'Erro ao salvar token: $e');
    }
  }

  @override
  Future<AuthTokenModel?> getAuthToken() async {
    try {
      final tokenJson = sharedPreferences.getString(_authTokenKey);
      if (tokenJson == null) {
        return null;
      }

      final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
      return AuthTokenModel.fromJson(tokenMap);
    } catch (e) {
      throw CacheException(message: 'Erro ao recuperar token: $e');
    }
  }

  @override
  Future<void> removeAuthToken() async {
    try {
      final success = await sharedPreferences.remove(_authTokenKey);
      if (!success) {
        throw CacheException(message: 'Falha ao remover token de autenticação');
      }
    } catch (e) {
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException(message: 'Erro ao remover token: $e');
    }
  }

  @override
  Future<bool> hasAuthToken() async {
    try {
      return sharedPreferences.containsKey(_authTokenKey);
    } catch (e) {
      throw CacheException(message: 'Erro ao verificar token: $e');
    }
  }

  @override
  Future<void> saveUserCredentials({
    required String username,
    required String password,
  }) async {
    try {
      final credentialsJson = json.encode({
        'username': username,
        'password': password,
      });
      final success = await sharedPreferences.setString(
        _userCredentialsKey,
        credentialsJson,
      );
      if (!success) {
        throw CacheException(message: 'Falha ao salvar credenciais do usuário');
      }
    } catch (e) {
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException(message: 'Erro ao salvar credenciais: $e');
    }
  }

  @override
  Future<Map<String, String>?> getUserCredentials() async {
    try {
      final credentialsJson = sharedPreferences.getString(_userCredentialsKey);
      if (credentialsJson == null) {
        return null;
      }

      final credentialsMap =
          json.decode(credentialsJson) as Map<String, dynamic>;
      return {
        'username': credentialsMap['username'] as String,
        'password': credentialsMap['password'] as String,
      };
    } catch (e) {
      throw CacheException(message: 'Erro ao recuperar credenciais: $e');
    }
  }

  @override
  Future<void> removeUserCredentials() async {
    try {
      final success = await sharedPreferences.remove(_userCredentialsKey);
      if (!success) {
        throw CacheException(
          message: 'Falha ao remover credenciais do usuário',
        );
      }
    } catch (e) {
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException(message: 'Erro ao remover credenciais: $e');
    }
  }

  @override
  Future<bool> hasUserCredentials() async {
    try {
      return sharedPreferences.containsKey(_userCredentialsKey);
    } catch (e) {
      throw CacheException(message: 'Erro ao verificar credenciais: $e');
    }
  }
}