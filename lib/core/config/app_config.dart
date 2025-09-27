import 'package:flutter/foundation.dart';

/// Configuração centralizada da aplicação
/// Gerencia diferentes ambientes (desenvolvimento, produção)
class AppConfig {
  static AppConfig? _instance;
  static AppConfig get instance => _instance!;

  final String apiBaseUrl;
  final String tasmotaBaseUrl;
  final bool isProduction;
  final String environment;
  final Duration connectionTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
  final bool enableCrashReporting;

  AppConfig._({
    required this.apiBaseUrl,
    required this.tasmotaBaseUrl,
    required this.isProduction,
    required this.environment,
    required this.connectionTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
    required this.enableLogging,
    required this.enableCrashReporting,
  });

  /// Inicializa a configuração baseada no ambiente
  static void initialize({AppEnvironment? environment}) {
    final env = environment ?? _detectEnvironment();
    _instance = _createConfig(env);
  }

  /// Detecta o ambiente automaticamente
  static AppEnvironment _detectEnvironment() {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction
        ? AppEnvironment.production
        : AppEnvironment.development;
  }

  /// Cria a configuração baseada no ambiente
  static AppConfig _createConfig(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.development:
        return AppConfig._(
          apiBaseUrl: 'http://192.168.0.178:8080/api',
          tasmotaBaseUrl: 'http://192.168.0.178',
          isProduction: false,
          environment: 'development',
          connectionTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          enableLogging: true,
          enableCrashReporting: false,
        );

      case AppEnvironment.production:
        return AppConfig._(
          apiBaseUrl: 'http://192.168.0.220:8080/gp/api',
          tasmotaBaseUrl: 'http://192.168.0.220',
          isProduction: true,
          environment: 'production',
          connectionTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          enableLogging: false,
          enableCrashReporting: true,
        );

      case AppEnvironment.staging:
        return AppConfig._(
          apiBaseUrl: 'http://192.168.0.200:8080/staging/api',
          tasmotaBaseUrl: 'http://192.168.0.200',
          isProduction: false,
          environment: 'staging',
          connectionTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          enableLogging: true,
          enableCrashReporting: true,
        );
    }
  }

  /// URLs completas dos endpoints
  String get loginEndpoint => '$apiBaseUrl/auth';
  String get userEndpoint => '$apiBaseUrl/users';
  String get carcacaEndpoint => '$apiBaseUrl/carcacas';
  String get matrizEndpoint => '$apiBaseUrl/matriz';
  String get regraEndpoint => '$apiBaseUrl/regras';
  String get refreshTokenEndpoint => '$apiBaseUrl/auth/refresh';
  String get logoutEndpoint => '$apiBaseUrl/auth/logout';
  String get userProfileEndpoint => '$apiBaseUrl/usuario/me';
  String get machineConfigEndpoint => '$apiBaseUrl/machine-config';
  String get selectMatrizEndpoint => '$apiBaseUrl/machine-config/select-matriz';

  /// URLs do Tasmota
  String get tasmotaPowerOnCommand => '$tasmotaBaseUrl/cm?cmnd=Power%20On';
  String get tasmotaPowerOffCommand => '$tasmotaBaseUrl/cm?cmnd=Power%20Off';
  String get tasmotaStatusCommand => '$tasmotaBaseUrl/cm?cmnd=Status';

  /// Informações de debug
  Map<String, dynamic> get debugInfo => {
    'environment': environment,
    'isProduction': isProduction,
    'apiBaseUrl': apiBaseUrl,
    'tasmotaBaseUrl': tasmotaBaseUrl,
    'enableLogging': enableLogging,
    'enableCrashReporting': enableCrashReporting,
    'connectionTimeout': connectionTimeout.inSeconds,
    'receiveTimeout': receiveTimeout.inSeconds,
    'sendTimeout': sendTimeout.inSeconds,
  };

  /// Valida se a configuração está correta
  bool get isValid {
    try {
      Uri.parse(apiBaseUrl);
      Uri.parse(tasmotaBaseUrl);
      return apiBaseUrl.isNotEmpty && tasmotaBaseUrl.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() {
    return 'AppConfig(environment: $environment, isProduction: $isProduction, apiBaseUrl: $apiBaseUrl)';
  }
}

/// Enum para definir os ambientes disponíveis
enum AppEnvironment { development, staging, production }

/// Extensão para facilitar o uso dos ambientes
extension AppEnvironmentExtension on AppEnvironment {
  String get name {
    switch (this) {
      case AppEnvironment.development:
        return 'Development';
      case AppEnvironment.staging:
        return 'Staging';
      case AppEnvironment.production:
        return 'Production';
    }
  }

  bool get isDevelopment => this == AppEnvironment.development;
  bool get isStaging => this == AppEnvironment.staging;
  bool get isProduction => this == AppEnvironment.production;
}
