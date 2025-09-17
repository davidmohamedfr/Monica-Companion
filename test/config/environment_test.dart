import 'package:flutter_test/flutter_test.dart';

import 'package:monica_mobile_app/config/feature_flags.dart';
import 'package:monica_mobile_app/core/config/app_config.dart';
import 'package:monica_mobile_app/core/config/environment.dart';

void main() {
  group('Environment Configuration Tests', () {
    test('should default to development environment', () {
      expect(EnvironmentConfig.currentEnvironment, Environment.development);
      expect(EnvironmentConfig.isDevelopment, true);
      expect(EnvironmentConfig.isStaging, false);
      expect(EnvironmentConfig.isProduction, false);
    });

    test('should have correct dev environment values', () {
      expect(EnvironmentConfig.appDisplayName, 'Monica Dev');
      expect(EnvironmentConfig.packageSuffix, '.dev');
      expect(EnvironmentConfig.apiBaseUrl, 'https://dev-api.monica.com');
    });

    test('should have correct app config values', () {
      expect(AppConfig.appName, 'Monica Dev');
      expect(AppConfig.packageName, 'com.monica.app.dev');
      expect(AppConfig.apiBaseUrl, 'https://dev-api.monica.com');
    });

    test('should have correct feature flags for dev', () {
      expect(FeatureFlags.enableDebugTools, true);
      expect(FeatureFlags.enableConsoleLogging, true);
      expect(FeatureFlags.enableCrashReporting, false);
      expect(FeatureFlags.enableAnalytics, false);
      expect(FeatureFlags.enableExperimentalFeatures, true);
      expect(FeatureFlags.apiTimeoutSeconds, 60);
    });

    test('should return all feature flags as map', () {
      final Map<String, dynamic> flags = FeatureFlags.allFlags;
      expect(flags.keys.length, 8);
      expect(flags.containsKey('enableDebugTools'), true);
      expect(flags.containsKey('enableConsoleLogging'), true);
      expect(flags['enableDebugTools'], true);
    });
  });
}
