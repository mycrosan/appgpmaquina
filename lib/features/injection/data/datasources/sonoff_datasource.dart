import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class SonoffDataSource {
  Future<bool> ligarRele();
  Future<bool> desligarRele();
  Future<bool> verificarStatusRele();
}

class SonoffDataSourceImpl implements SonoffDataSource {
  final http.Client client;
  final String baseUrl;

  SonoffDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<bool> ligarRele() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/cm?cmnd=Power%20On'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['POWER'] == 'ON';
      }
      return false;
    } catch (e) {
      throw Exception('Erro ao ligar relé: $e');
    }
  }

  @override
  Future<bool> desligarRele() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/cm?cmnd=Power%20Off'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['POWER'] == 'OFF';
      }
      return false;
    } catch (e) {
      throw Exception('Erro ao desligar relé: $e');
    }
  }

  @override
  Future<bool> verificarStatusRele() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/cm?cmnd=Power'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['POWER'] == 'ON';
      }
      return false;
    } catch (e) {
      throw Exception('Erro ao verificar status do relé: $e');
    }
  }
}