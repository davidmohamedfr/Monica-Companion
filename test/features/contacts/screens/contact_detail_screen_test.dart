import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_bloc.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_event.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_state.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:monica_companion/features/contacts/screens/contact_detail_screen.dart';
import 'package:monica_companion/features/shared/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';
import '../../../helpers/test_helpers.dart';

class MockContactsBloc extends Mock implements ContactsBloc {}

class MockContactsRepository extends Mock implements ContactsRepository {}

void main() {
  group('ContactDetailScreen Tests', () {
    late Contact testContact;
    late MockContactsBloc mockContactsBloc;
    late MockContactsRepository mockContactsRepository;

    setUpAll(() {
      TestHelpers.setupMockFallbacks();
      registerFallbackValue(const ContactsState());
      registerFallbackValue(
        const UpdateContactEvent(Contact(id: 'fallback', name: 'Fallback')),
      );
    });

    setUp(() {
      testContact = const Contact(
        id: 'test-id-123',
        name: 'John Doe',
        phone: '+1234567890',
        email: 'john.doe@example.com',
      );
      mockContactsBloc = MockContactsBloc();
      mockContactsRepository = MockContactsRepository();

      when(() => mockContactsBloc.state).thenReturn(const ContactsState());
      when(
        () => mockContactsBloc.stream,
      ).thenAnswer((_) => Stream<ContactsState>.empty());

      // Mock repository to return writable (not read-only) by default
      when(
        () => mockContactsRepository.isContactReadOnly(any()),
      ).thenAnswer((_) async => false);
    });

    Widget createTestWidget(Contact contact) => MaterialApp(
      home: Provider<ContactsRepository>.value(
        value: mockContactsRepository,
        child: BlocProvider<ContactsBloc>.value(
          value: mockContactsBloc,
          child: ContactDetailScreen(contact: contact),
        ),
      ),
    );

    testWidgets('should display contact name in app bar', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(testContact));

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have scrollable content area', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(testContact));

      // Assert - allow multiple scrollable widgets (EmptyStateWidget also has one)
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('should have back button when navigated to', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ContactsBloc>.value(
            value: mockContactsBloc,
            child: Builder(
              builder: (BuildContext context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ContactDetailScreen(contact: testContact),
                      ),
                    );
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap button to navigate
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('should display Recent Interactions section header', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(testContact));

      // Assert
      expect(find.text('Recent Interactions'), findsOneWidget);
    });

    testWidgets('should display empty state for interactions', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(testContact));

      // Assert
      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No interactions yet'), findsOneWidget);
    });

    testWidgets('should display interactions section below contact info', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(testContact));
      await tester.pumpAndSettle();

      // Assert
      final Finder contactInfo = find.byType(CircleAvatar);
      final Finder interactionsHeader = find.text('Recent Interactions');

      expect(contactInfo, findsOneWidget);
      expect(interactionsHeader, findsOneWidget);

      // Verify interactions section is below contact info
      final double contactInfoY = tester.getTopLeft(contactInfo).dy;
      final double interactionsY = tester.getTopLeft(interactionsHeader).dy;

      expect(interactionsY, greaterThan(contactInfoY));
    });

    testWidgets('should display edit button in app bar', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(testContact));
      await tester.pumpAndSettle(); // Wait for async _checkReadOnlyStatus

      // Assert
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should display disabled exclusion button in app bar', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(testContact));

      // Assert
      expect(find.byIcon(Icons.block), findsOneWidget);

      final IconButton button = tester.widget<IconButton>(
        find.byType(IconButton).last,
      );
      expect(button.icon, isA<Icon>());
      expect(button.onPressed, isNull);
    });

    testWidgets('should show tooltip on exclusion button', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(testContact));

      final Finder exclusionButton = find.byIcon(Icons.block);

      // Long press to show tooltip
      await tester.longPress(exclusionButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Coming soon - Add to exclusion list'), findsOneWidget);
    });

    testWidgets('should show snackbar when tapping disabled exclusion button', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(testContact));

      // Tap the disabled button area
      await tester.tap(find.byIcon(Icons.block));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Feature coming soon - see issue #65'), findsOneWidget);
    });
  });
}
