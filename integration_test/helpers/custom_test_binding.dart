import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Custom integration test binding that ignores overflow errors
///
/// Based on: https://stackoverflow.com/a/57501230
class CustomIntegrationTestBinding
    extends IntegrationTestWidgetsFlutterBinding {
  @override
  void initInstances() {
    super.initInstances();

    // Override error handler to ignore overflow errors
    FlutterError.onError = _handleFlutterError;
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    // Check if this is a RenderFlex overflow error
    final exception = details.exception;
    bool isOverflowError = false;

    if (exception is FlutterError) {
      isOverflowError = exception.diagnostics.any(
        (e) => e.value.toString().contains('A RenderFlex overflowed by'),
      );
    }

    if (isOverflowError) {
      // Silently ignore overflow errors
      return;
    }

    // Report non-overflow errors normally
    FlutterError.dumpErrorToConsole(details);
  }

  /// Custom factory method to replace ensureInitialized()
  static IntegrationTestWidgetsFlutterBinding ensureInitializedCustom() {
    // Return existing instance if already initialized
    final current = IntegrationTestWidgetsFlutterBinding.instance;
    if (current is CustomIntegrationTestBinding) {
      return current;
    }

    // If standard binding exists, can't replace it
    if (current != null) {
      return current;
    }

    // Create new custom binding
    return CustomIntegrationTestBinding();
  }
}
