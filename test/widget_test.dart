// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:monica_mobile_app/main.dart';

void main() {
  testWidgets('App launches and displays Monica configuration', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MonicaApp());

    // Verify that our app displays environment configuration
    expect(find.text('Environment Configuration'), findsOneWidget);
    expect(find.text('Feature Flags'), findsOneWidget);
  });
}
