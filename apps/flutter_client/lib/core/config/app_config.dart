enum AppEnvironment { dev, staging, prod }

class AppConfig {
  static AppConfig? _instance;

  final AppEnvironment environment;
  final String firebaseProjectId;
  final String functionsBaseUrl;
  final bool useEmulator;

  AppConfig._({
    required this.environment,
    required this.firebaseProjectId,
    required this.functionsBaseUrl,
    required this.useEmulator,
  });

  static AppConfig get instance {
    assert(_instance != null, 'AppConfig not initialized. Call AppConfig.init() first.');
    return _instance!;
  }

  static void init({
    required AppEnvironment environment,
    required String firebaseProjectId,
    required String functionsBaseUrl,
    required bool useEmulator,
  }) {
    _instance = AppConfig._(
      environment: environment,
      firebaseProjectId: firebaseProjectId,
      functionsBaseUrl: functionsBaseUrl,
      useEmulator: useEmulator,
    );
  }

  bool get isDev => environment == AppEnvironment.dev;
  bool get isProd => environment == AppEnvironment.prod;
  bool get isStaging => environment == AppEnvironment.staging;
}