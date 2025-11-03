import 'dart:developer' as developer;

import 'package:monica_companion/core/config/app_config.dart';

/// Centralized logging utility with sensitive data sanitization
class Logger {
  Logger._();

  /// Sanitize log message to prevent sensitive data leaks
  ///
  /// This method redacts sensitive information from log messages to prevent
  /// accidental exposure of:
  /// - API tokens and authentication credentials
  /// - Email addresses
  /// - Phone numbers
  /// - Password-related fields
  /// - Credit card numbers
  ///
  /// Security rationale:
  /// - Logs may be stored in plain text files
  /// - Logs may be transmitted to crash reporting services
  /// - Logs may be accessible to debugging tools
  /// - Prevents PII (Personally Identifiable Information) leaks
  ///
  /// @param message The log message to sanitize
  /// @return Sanitized message with sensitive data redacted
  static String _sanitizeLogMessage(String message) {
    String sanitized = message;

    // Redact API tokens (common patterns: "token", "bearer", "api_key")
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(token|bearer|api_key|authorization)[:\s=]+[A-Za-z0-9\-_\.]+',
          caseSensitive: false),
      (Match match) => '${match.group(1)}: [REDACTED]',
    );

    // Redact email addresses
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      (Match _) => '[EMAIL_REDACTED]',
    );

    // Redact phone numbers (international format with optional + and spaces/dashes)
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\+?[\d\s\-\(\)]{10,}'),
      (Match match) {
        // Only redact if it looks like a phone number (not a timestamp)
        final String matched = match.group(0)!;
        if (matched.contains('(') || matched.contains('+') ||
            matched.replaceAll(RegExp(r'[\s\-]'), '').length >= 10) {
          return '[PHONE_REDACTED]';
        }
        return matched;
      },
    );

    // Redact password fields
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(password|passwd|pwd)[:\s=]+\S+', caseSensitive: false),
      (Match match) => '${match.group(1)}: [REDACTED]',
    );

    // Redact credit card numbers (basic pattern)
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\b\d{4}[\s\-]?\d{4}[\s\-]?\d{4}[\s\-]?\d{4}\b'),
      (Match _) => '[CARD_REDACTED]',
    );

    return sanitized;
  }

  /// Log debug message
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (AppConfig.isDebug) {
      developer.log(
        _sanitizeLogMessage(message),
        name: tag ?? 'DEBUG',
        error: error,
        stackTrace: stackTrace,
        level: 500,
      );
    }
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    developer.log(
      _sanitizeLogMessage(message),
      name: tag ?? 'INFO',
      level: 800,
    );
  }

  /// Log warning message
  static void warning(String message, {String? tag, Object? error}) {
    developer.log(
      _sanitizeLogMessage(message),
      name: tag ?? 'WARNING',
      error: error,
      level: 900,
    );
  }

  /// Log error message
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      _sanitizeLogMessage(message),
      name: tag ?? 'ERROR',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
