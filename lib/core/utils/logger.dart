import 'dart:developer' as developer;

import 'package:monica_mobile_app/core/config/app_config.dart';

/// Centralized logging utility
class Logger {
  Logger._();

  /// Log debug message
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (AppConfig.isDebug) {
      developer.log(
        message,
        name: tag ?? 'DEBUG',
        error: error,
        stackTrace: stackTrace,
        level: 500,
      );
    }
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    developer.log(message, name: tag ?? 'INFO', level: 800);
  }

  /// Log warning message
  static void warning(String message, {String? tag, Object? error}) {
    developer.log(message, name: tag ?? 'WARNING', error: error, level: 900);
  }

  /// Log error message
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? 'ERROR',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
