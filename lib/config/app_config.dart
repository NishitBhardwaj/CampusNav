/// CampusNav - App Configuration
///
/// Global app configuration and settings.

// =============================================================================
// APP CONFIGURATION
// =============================================================================

class AppConfig {
  // App info
  static const String appName = 'CampusNav';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Feature flags
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enableDebugMode = true;
  static const bool enableOfflineMode = true;

  // Navigation settings
  static const double defaultStepLength = 0.7; // meters
  static const double arrivalThreshold = 2.0; // meters
  static const int rerouteDelayMs = 5000;

  // Map settings
  static const double defaultPixelsPerMeter = 10.0;
  static const double minZoom = 0.5;
  static const double maxZoom = 4.0;

  // Search settings
  static const int searchDebounceMs = 300;
  static const int maxSearchResults = 10;
  static const double fuzzyMatchThreshold = 0.6;

  // API settings (for future backend integration)
  static const String apiBaseUrl = 'https://api.campusnav.example.com';
  static const int apiTimeoutSeconds = 30;

  // Cache settings
  static const int mapCacheMaxSizeMb = 100;
  static const int dataCacheExpiryHours = 24;
}

// =============================================================================
// ENVIRONMENT
// =============================================================================

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment currentEnvironment = Environment.development;

  static bool get isDevelopment =>
      currentEnvironment == Environment.development;
  static bool get isStaging => currentEnvironment == Environment.staging;
  static bool get isProduction => currentEnvironment == Environment.production;
}
