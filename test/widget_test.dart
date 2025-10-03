import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/main.dart';
import 'package:monica_companion/services/service_locator.dart';

import '../test/helpers/test_helpers.dart';

void main() {
  setUp(() async {
    await TestHelpers.setupServiceLocatorForTests();
  });

  tearDown(() {
    ServiceLocator.instance.clear();
  });

  testWidgets('App launches and displays main navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MonicaApp());
    await tester.pumpAndSettle();

    // Verify main navigation is displayed
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Contacts'), findsWidgets);
    expect(find.text('Interactions'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}
