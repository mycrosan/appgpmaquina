import 'package:flutter/foundation.dart';

/// Configuração centralizada da aplicação
/// Gerencia diferentes ambientes (desenvolvimento, produção)
class AppConfig {
  static AppConfig? _instance;
  static AppConfig get instance => _instance!;

  final String apiBaseUrl;
  final bool isProduction;
  final String environment;
  final Duration connectionTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
  final bool enableCrashReporting;

  AppConfig._({
    required this.apiBaseUrl,
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
    // Permite override via --dart-define
    const String envOverride = String.fromEnvironment(
      'APP_ENV',
      defaultValue: '',
    );
    const String serverIpOverride = String.fromEnvironment(
      'SERVER_IP',
      defaultValue: '',
    );

    final autoEnv = environment ?? _detectEnvironment();
    final env = _resolveEnvironment(envOverride, autoEnv);

    // Cria configuração base pelo ambiente
    var config = _createConfig(env);

    // Se houver override de SERVER_IP, aplica na base URL da API
    if (serverIpOverride.isNotEmpty) {
      try {
        final uri = Uri.parse(serverIpOverride);
        config = _createConfig(env, apiBaseOverride: serverIpOverride);
      } catch (_) {
        // Mantém configuração padrão caso o override seja inválido
      }
    }

    _instance = config;
  }

  /// Detecta o ambiente automaticamente
  static AppEnvironment _detectEnvironment() {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction
        ? AppEnvironment.production
        : AppEnvironment.development;
  }

  /// Cria a configuração baseada no ambiente
  static AppConfig _createConfig(
    AppEnvironment environment, {
    String? apiBaseOverride,
  }) {
    switch (environment) {
      case AppEnvironment.development:
        return AppConfig._(
          apiBaseUrl: apiBaseOverride ?? 'http://192.168.0.164:8080/api',
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
          apiBaseUrl: apiBaseOverride ?? 'http://192.168.0.220:8080/gp/api',
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
          apiBaseUrl:
              apiBaseOverride ?? 'http://192.168.0.200:8080/staging/api',
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

  /// Resolve o ambiente efetivo considerando override via --dart-define
  static AppEnvironment _resolveEnvironment(
    String envOverride,
    AppEnvironment fallback,
  ) {
    switch (envOverride.toLowerCase()) {
      case 'production':
      case 'prod':
      case 'prd':
        return AppEnvironment.production;
      case 'development':
      case 'dev':
      case 'local':
        return AppEnvironment.development;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      default:
        return fallback;
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

  /// Informações de debug
  Map<String, dynamic> get debugInfo => {
    'environment': environment,
    'isProduction': isProduction,
    'apiBaseUrl': apiBaseUrl,
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
      return apiBaseUrl.isNotEmpty;
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
