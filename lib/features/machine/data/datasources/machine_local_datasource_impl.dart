import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/matriz_model.dart';
import '../models/machine_config_model.dart';

const String CACHED_MATRIZES = 'CACHED_MATRIZES';
const String CACHED_MACHINE_CONFIG = 'CACHED_MACHINE_CONFIG';

/// Implementação simplificada do MachineLocalDataSource
/// Contém apenas os métodos essenciais para o funcionamento do MachineConfigBloc
class MachineLocalDataSourceImpl {
  final SharedPreferences sharedPreferences;

  MachineLocalDataSourceImpl({required this.sharedPreferences});

  Future<void> cacheMatrizes(List<MatrizModel> matrizes) async {
    final jsonString = json.encode(matrizes.map((m) => m.toJson()).toList());
    await sharedPreferences.setString(CACHED_MATRIZES, jsonString);
  }

  Future<List<MatrizModel>> getCachedMatrizes() async {
    final jsonString = sharedPreferences.getString(CACHED_MATRIZES);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => MatrizModel.fromJson(json)).toList();
    } else {
      throw CacheException(message: 'No cached matrizes found');
    }
  }

  Future<void> clearCachedMatrizes() async {
    await sharedPreferences.remove(CACHED_MATRIZES);
  }

  Future<void> cacheMachineConfig(MachineConfigModel config) async {
    final jsonString = json.encode(config.toJson());
    await sharedPreferences.setString(CACHED_MACHINE_CONFIG, jsonString);
  }

  Future<MachineConfigModel?> getCachedMachineConfig(
    String deviceId,
    String userId,
  ) async {
    final jsonString = sharedPreferences.getString(CACHED_MACHINE_CONFIG);
    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      return MachineConfigModel.fromJson(json);
    }
    return null;
  }

  Future<void> removeCachedMachineConfig(String deviceId, String userId) async {
    await sharedPreferences.remove(CACHED_MACHINE_CONFIG);
  }

  Future<void> clearCachedMachineConfigs() async {
    await sharedPreferences.remove(CACHED_MACHINE_CONFIG);
  }
}