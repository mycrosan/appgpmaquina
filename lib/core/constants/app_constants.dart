/// Constantes da aplicação
class AppConstants {
  // Informações da aplicação
  static const String appName = 'GP Máquina';
  static const String appVersion = '1.0.0';

  // URLs da API - DEPRECATED: Use AppConfig instead
  // static const String baseUrl = 'https://api.gpmaquina.com.br';
  // static const String apiVersion = '/v1';

  // Endpoints da API - DEPRECATED: Use AppConfig instead
  // static const String loginEndpoint = '/auth/login';
  // static const String userEndpoint = '/users';
  // static const String carcacaEndpoint = '/carcacas';
  // static const String matrizEndpoint = '/matrizes';
  // static const String regraEndpoint = '/regras';

  // Configurações de rede - DEPRECATED: Use AppConfig instead
  // static const int connectionTimeout = 30000; // 30 segundos
  // static const int receiveTimeout = 30000; // 30 segundos
  // static const int sendTimeout = 30000; // 30 segundos

  // Configurações do Tasmota - DEPRECATED: Use AppConfig instead
  // static const String tasmotaBaseUrl = 'http://192.168.1.100';
  // static const String tasmotaPowerOnCommand = '/cm?cmnd=Power%20On';
  // static const String tasmotaPowerOffCommand = '/cm?cmnd=Power%20Off';
  // static const String tasmotaStatusCommand = '/cm?cmnd=Status';

  // Chaves do SharedPreferences
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyMachineMatrix = 'machine_matrix';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyLastLoginTime = 'last_login_time';

  // Configurações de autenticação biométrica
  static const String biometricReason =
      'Autentique-se para acessar o aplicativo';
  static const String biometricTitle = 'Autenticação Biométrica';
  static const String biometricSubtitle =
      'Use sua impressão digital ou Face ID';
  static const String biometricNegativeButton = 'Cancelar';

  // Mensagens de erro padrão
  static const String networkErrorMessage =
      'Erro de conexão. Verifique sua internet.';
  static const String serverErrorMessage =
      'Erro no servidor. Tente novamente mais tarde.';
  static const String authErrorMessage =
      'Falha na autenticação. Verifique suas credenciais.';
  static const String validationErrorMessage =
      'Dados inválidos. Verifique os campos.';
  static const String biometricErrorMessage =
      'Falha na autenticação biométrica.';
  static const String hardwareErrorMessage = 'Erro no controle da válvula.';
  static const String wrongMachineMessage =
      'Máquina errada! Esta carcaça não pertence a esta matriz.';

  // Configurações de UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double buttonHeight = 48.0;

  // Configurações de timer
  static const int defaultInjectionTime = 30; // segundos
  static const int timerUpdateInterval = 1000; // milissegundos

  // Códigos de status HTTP
  static const int httpOk = 200;
  static const int httpCreated = 201;
  static const int httpBadRequest = 400;
  static const int httpUnauthorized = 401;
  static const int httpForbidden = 403;
  static const int httpNotFound = 404;
  static const int httpInternalServerError = 500;

  // Regex patterns
  static const String carcacaCodePattern = r'^\d{6}$'; // 6 dígitos
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Configurações de cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // número máximo de itens em cache
}