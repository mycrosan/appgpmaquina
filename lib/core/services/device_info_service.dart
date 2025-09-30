import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

/// Serviço para obter informações do dispositivo
class DeviceInfoService {
  static const String _deviceIdKey = 'device_id';
  static DeviceInfoService? _instance;
  static DeviceInfoService get instance => _instance ??= DeviceInfoService._();

  DeviceInfoService._();

  /// Obtém um ID único do dispositivo
  Future<String> getDeviceId() async {
    try {
      // Primeiro tenta obter do cache local
      final prefs = await SharedPreferences.getInstance();
      String? cachedDeviceId = prefs.getString(_deviceIdKey);

      if (cachedDeviceId != null && cachedDeviceId.isNotEmpty) {
        developer.log(
          '📱 Device ID obtido do cache: $cachedDeviceId',
          name: 'DeviceInfoService',
        );
        return cachedDeviceId;
      }

      // Se não existe no cache, obtém do dispositivo
      final deviceInfo = DeviceInfoPlugin();
      String deviceId;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Usa uma combinação de informações para criar um ID único
        deviceId = '${androidInfo.brand}_${androidInfo.model}_${androidInfo.id}'
            .replaceAll(' ', '_');
        developer.log(
          '📱 Android Device ID gerado: $deviceId',
          name: 'DeviceInfoService',
        );
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // Para iOS, usa o identifierForVendor
        deviceId =
            iosInfo.identifierForVendor ??
            'ios_${iosInfo.model}_${iosInfo.systemVersion}';
        developer.log(
          '📱 iOS Device ID gerado: $deviceId',
          name: 'DeviceInfoService',
        );
      } else {
        // Para outras plataformas, gera um ID baseado em timestamp
        deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
        developer.log(
          '📱 Generic Device ID gerado: $deviceId',
          name: 'DeviceInfoService',
        );
      }

      // Salva no cache para uso futuro
      await prefs.setString(_deviceIdKey, deviceId);
      developer.log('💾 Device ID salvo no cache', name: 'DeviceInfoService');

      return deviceId;
    } catch (e) {
      developer.log('❌ Erro ao obter Device ID: $e', name: 'DeviceInfoService');

      // Em caso de erro, tenta obter do cache ou gera um ID de fallback
      final prefs = await SharedPreferences.getInstance();
      String? cachedDeviceId = prefs.getString(_deviceIdKey);

      if (cachedDeviceId != null && cachedDeviceId.isNotEmpty) {
        return cachedDeviceId;
      }

      // Fallback: gera um ID baseado em timestamp
      final fallbackId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_deviceIdKey, fallbackId);
      return fallbackId;
    }
  }

  /// Obtém informações detalhadas do dispositivo
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'manufacturer': androidInfo.manufacturer,
          'product': androidInfo.product,
          'device': androidInfo.device,
          'id': androidInfo.id,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      } else {
        return {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
        };
      }
    } catch (e) {
      developer.log(
        '❌ Erro ao obter informações do dispositivo: $e',
        name: 'DeviceInfoService',
      );
      return {'platform': Platform.operatingSystem, 'error': e.toString()};
    }
  }

  /// Limpa o cache do device ID (útil para testes)
  Future<void> clearDeviceIdCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
      developer.log('🗑️ Cache do Device ID limpo', name: 'DeviceInfoService');
    } catch (e) {
      developer.log(
        '❌ Erro ao limpar cache do Device ID: $e',
        name: 'DeviceInfoService',
      );
    }
  }
}