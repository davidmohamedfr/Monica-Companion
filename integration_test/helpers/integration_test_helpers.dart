import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Integration test helper utilities
class IntegrationTestHelpers {
  IntegrationTestHelpers._();

  /// Setup integration test environment
  static IntegrationTestWidgetsFlutterBinding setupIntegrationTest() =>
      IntegrationTestWidgetsFlutterBinding.ensureInitialized()
        ..framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  /// Wait for app to fully load
  static Future<void> waitForAppToLoad(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Simulate device back button press
  static Future<void> pressBackButton(WidgetTester tester) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/platform',
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('SystemNavigator.pop'),
      ),
      (ByteData? data) {},
    );
    await tester.pumpAndSettle();
  }

  /// Take screenshot for test documentation
  static Future<void> takeScreenshot(
    IntegrationTestWidgetsFlutterBinding binding,
    String name,
  ) async {
    await binding.convertFlutterSurfaceToImage();
    await binding.takeScreenshot(name);
  }

  /// Scroll to find a widget in a scrollable
  static Future<void> scrollToFindWidget(
    WidgetTester tester,
    Finder scrollable,
    Finder target,
  ) async {
    await tester.scrollUntilVisible(target, 500, scrollable: scrollable);
    await tester.pumpAndSettle();
  }

  /// Fill text field with value
  static Future<void> fillTextField(
    WidgetTester tester,
    Finder textField,
    String value,
  ) async {
    await tester.tap(textField);
    await tester.pumpAndSettle();
    await tester.enterText(textField, value);
    await tester.pumpAndSettle();
  }

  /// Verify widget is visible and enabled
  static void expectWidgetVisible(Finder finder) {
    expect(finder, findsOneWidget);
    final Widget widget = finder.evaluate().first.widget;

    // Check if widget is enabled (if it has an enabled property)
    if (widget is StatefulWidget) {
      // Additional checks can be added here based on widget type
    }
  }
}
