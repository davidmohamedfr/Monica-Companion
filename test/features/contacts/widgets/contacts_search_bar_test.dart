import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/features/contacts/widgets/contacts_search_bar.dart';

void main() {
  group('ContactsSearchBar Widget Tests', () {
    group('Rendering and Initial State', () {
      testWidgets('should render with default hint text', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ContactsSearchBar(onSearchChanged: (_) {})),
          ),
        );

        // Assert
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search contacts...'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should render with custom hint text', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(
                onSearchChanged: (_) {},
                hintText: 'Custom hint',
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Custom hint'), findsOneWidget);
      });

      testWidgets('should pre-populate with initial value', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(
                onSearchChanged: (_) {},
                initialValue: 'John',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, equals('John'));
      });

      testWidgets('should not show clear button when empty', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ContactsSearchBar(onSearchChanged: (_) {})),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.clear), findsNothing);
      });

      testWidgets('should show clear button with initial value', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(
                onSearchChanged: (_) {},
                initialValue: 'Test',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.clear), findsOneWidget);
      });
    });

    group('Text Input Behavior', () {
      testWidgets('should call onSearchChanged when text is entered', (
        WidgetTester tester,
      ) async {
        // Arrange
        String? searchValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(
                onSearchChanged: (value) {
                  searchValue = value;
                },
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), 'John Doe');
        await tester.pump();

        // Assert
        expect(searchValue, equals('John Doe'));
      });

      testWidgets('should show clear button after entering text', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ContactsSearchBar(onSearchChanged: (_) {})),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), 'Test');
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('should update on each character typed', (
        WidgetTester tester,
      ) async {
        // Arrange
        final List<String> searchValues = <String>[];
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(onSearchChanged: searchValues.add),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), 'J');
        await tester.pump();
        await tester.enterText(find.byType(TextField), 'Jo');
        await tester.pump();
        await tester.enterText(find.byType(TextField), 'Joh');
        await tester.pump();

        // Assert
        expect(searchValues, contains('J'));
        expect(searchValues, contains('Jo'));
        expect(searchValues, contains('Joh'));
      });
    });

    group('Clear Button Behavior', () {
      testWidgets('should clear text when clear button is tapped', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(
                onSearchChanged: (_) {},
                initialValue: 'Test',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
      });

      testWidgets(
        'should call onSearchChanged with empty string when cleared',
        (WidgetTester tester) async {
          // Arrange
          String? lastSearchValue;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ContactsSearchBar(
                  onSearchChanged: (value) {
                    lastSearchValue = value;
                  },
                  initialValue: 'Test',
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Act
          await tester.tap(find.byIcon(Icons.clear));
          await tester.pump();

          // Assert
          expect(lastSearchValue, equals(''));
        },
      );

      testWidgets('should hide clear button after clearing', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(
                onSearchChanged: (_) {},
                initialValue: 'Test',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.clear), findsNothing);
      });
    });

    group('Controller Lifecycle', () {
      testWidgets('should dispose controller properly', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ContactsSearchBar(onSearchChanged: (_) {})),
          ),
        );
        await tester.pumpAndSettle();

        // Act: Dispose widget
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pumpAndSettle();

        // Assert: Should dispose without errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('should properly remove and add listener', (
        WidgetTester tester,
      ) async {
        // Arrange
        int callCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(
                onSearchChanged: (_) {
                  callCount++;
                },
              ),
            ),
          ),
        );

        // Act: Enter text
        await tester.enterText(find.byType(TextField), 'Test');
        await tester.pump();

        final int firstCallCount = callCount;

        // Dispose and recreate
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(
                onSearchChanged: (_) {
                  callCount++;
                },
              ),
            ),
          ),
        );

        // Enter text again
        await tester.enterText(find.byType(TextField), 'New');
        await tester.pump();

        // Assert: Callback should work correctly
        expect(callCount, greaterThan(firstCallCount));
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle rapid text changes', (
        WidgetTester tester,
      ) async {
        // Arrange
        final List<String> searchValues = <String>[];
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(onSearchChanged: searchValues.add),
            ),
          ),
        );

        // Act: Rapidly change text
        for (int i = 0; i < 10; i++) {
          await tester.enterText(find.byType(TextField), 'Test$i');
          await tester.pump(const Duration(milliseconds: 10));
        }

        // Assert: Should handle all changes
        expect(searchValues.length, greaterThanOrEqualTo(10));
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle special characters in search', (
        WidgetTester tester,
      ) async {
        // Arrange
        String? searchValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(
                onSearchChanged: (value) {
                  searchValue = value;
                },
              ),
            ),
          ),
        );

        // Act
        const specialText = '@#\$%^&*(){}[]|\\/<>?';
        await tester.enterText(find.byType(TextField), specialText);
        await tester.pump();

        // Assert
        expect(searchValue, equals(specialText));
      });

      testWidgets('should handle empty string input', (
        WidgetTester tester,
      ) async {
        // Arrange
        String? searchValue = 'initial';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsSearchBar(
                onSearchChanged: (value) {
                  searchValue = value;
                },
                initialValue: 'Test',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(find.byType(TextField), '');
        await tester.pump();

        // Assert
        expect(searchValue, equals(''));
        expect(find.byIcon(Icons.clear), findsNothing);
      });
    });

    group('UI Styling', () {
      testWidgets('should have correct text input action', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ContactsSearchBar(onSearchChanged: (_) {})),
          ),
        );

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.textInputAction, equals(TextInputAction.search));
      });

      testWidgets('should display search icon as prefix', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ContactsSearchBar(onSearchChanged: (_) {})),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.search), findsOneWidget);
      });
    });
  });
}
