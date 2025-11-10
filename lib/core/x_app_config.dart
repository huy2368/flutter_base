enum XEnvironment { dev, prod }

class XAppConfig {
  static late XEnvironment environment;

  static late XApiConfig apiConfig;

  static bool get isDevelop => environment == XEnvironment.dev;

  static bool get isProduction => environment == XEnvironment.prod;

  static void setup({
    required XEnvironment env,
    required XApiConfig apiConfig,
  }) {
    XAppConfig.apiConfig = apiConfig;
    XAppConfig.environment = env;
  }

  static String get webUrl => apiConfig.webUrl;

  static String get baseUrl => apiConfig.baseUrl;
}

class XApiConfig {
  final String webUrl;
  final String baseUrl;

  XApiConfig({required this.webUrl, required this.baseUrl});
}
