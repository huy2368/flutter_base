enum XEnvironment { dev, prod }

class XAppConfig {
  static late XEnvironment environment;

  static late Map<String, dynamic> _config;

  static String webUrl = _config[_Config.webUrl];

  static String baseUrl = _config[_Config.baseUrl];

  static bool get isDevelop => environment == XEnvironment.dev;

  static bool get isProduction => environment == XEnvironment.prod;

  static void setup(XEnvironment env) {
    environment = env;
    switch (env) {
      case XEnvironment.dev:
        _config = _Config.devConstants;
        break;
      case XEnvironment.prod:
        _config = _Config.prodConstants;
        break;
    }
  }
}

class _Config {
  static const webUrl = 'WEB_URL';
  static const baseUrl = 'BASE_URL';

  static Map<String, dynamic> devConstants = {
    webUrl: 'https://pte.ftinfra.com',
    baseUrl: 'https://pte-api.ftinfra.com',
  };

  static Map<String, dynamic> prodConstants = {
    webUrl: 'https://pte.ftinfra.com',
    baseUrl: 'https://pte-api.ftinfra.com',
  };
}
