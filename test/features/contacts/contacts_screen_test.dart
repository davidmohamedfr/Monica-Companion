import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/db/interfaces/contact_repository.dart';
import 'package:monica_companion/db/models/contact.dart';
import 'package:monica_companion/db/repositories/repository_registry.dart';
import 'package:monica_companion/features/contacts/screens/contacts_screen.dart';
import 'package:monica_companion/features/contacts/widgets/contact_list_item.dart';
import 'package:monica_companion/services/service_locator.dart';

class MockContactRepository extends Mock implements ContactRepository {}

class MockRepositoryRegistry extends Mock implements RepositoryRegistry {}

void main() {
  late MockContactRepository mockContactRepository;
  late MockRepositoryRegistry mockRepositoryRegistry;

  setUp(() {
    mockContactRepository = MockContactRepository();
    mockRepositoryRegistry = MockRepositoryRegistry();

    // Setup service locator mock
    when(
      () => mockRepositoryRegistry.contactRepository,
    ).thenReturn(mockContactRepository);

    ServiceLocator.instance.registerSingleton<RepositoryRegistry>(
      mockRepositoryRegistry,
    );
  });

  tearDown(() {
    ServiceLocator.instance.clear();
  });

  group('ContactsScreen Widget Tests', () {
    testWidgets('should display loading indicator initially', (
      WidgetTester tester,
    ) async {
      when(
        () => mockContactRepository.findAll(),
      ).thenAnswer((_) async => <Contact>[]);

      await tester.pumpWidget(const MaterialApp(home: ContactsScreen()));

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when no contacts', (
      WidgetTester tester,
    ) async {
      when(
        () => mockContactRepository.findAll(),
      ).thenAnswer((_) async => <Contact>[]);

      await tester.pumpWidget(const MaterialApp(home: ContactsScreen()));

      // Wait for loading to complete
      await tester.pump();

      // Should show empty state message
      expect(find.text('No contacts yet'), findsOneWidget);
    });

    testWidgets('should display contacts list when contacts exist', (
      WidgetTester tester,
    ) async {
      final List<Contact> contacts = <Contact>[
        const Contact(id: 1, name: 'John Doe', email: 'john@example.com'),
        const Contact(id: 2, name: 'Jane Smith', phone: '+1234567890'),
      ];

      when(
        () => mockContactRepository.findAll(),
      ).thenAnswer((_) async => contacts);

      await tester.pumpWidget(const MaterialApp(home: ContactsScreen()));

      // Wait for loading to complete
      await tester.pump();

      // Should display contact names
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);

      // Should display contact details
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('+1234567890'), findsOneWidget);
    });

    testWidgets('should display app bar with title and actions', (
      WidgetTester tester,
    ) async {
      when(
        () => mockContactRepository.findAll(),
      ).thenAnswer((_) async => <Contact>[]);

      await tester.pumpWidget(const MaterialApp(home: ContactsScreen()));

      await tester.pump();

      // Should have app bar with title
      expect(find.text('Contacts'), findsOneWidget);

      // Should have search and add buttons
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNWidgets(2));
    });

    testWidgets('should show error message when loading fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockContactRepository.findAll(),
      ).thenThrow(Exception('Database error'));

      await tester.pumpWidget(const MaterialApp(home: ContactsScreen()));

      // Wait for loading to complete and didChangeDependencies to trigger
      await tester.pump();
      // Wait for post frame callback to execute
      await tester.pump();

      // Should show snackbar with error message
      expect(find.byType(SnackBar), findsOneWidget);
      // There will be 2 instances - one in SnackBar and one in error state, so we expect findsWidgets
      expect(
        find.textContaining('A database error occurred. Please try again.'),
        findsWidgets,
      );
    });

    testWidgets('should handle contact tap', (WidgetTester tester) async {
      final List<Contact> contacts = <Contact>[
        const Contact(id: 1, name: 'John Doe'),
      ];

      when(
        () => mockContactRepository.findAll(),
      ).thenAnswer((_) async => contacts);

      await tester.pumpWidget(const MaterialApp(home: ContactsScreen()));

      await tester.pump();

      // Tap on contact
      await tester.tap(find.text('John Doe'));
      await tester.pump();

      // Verify the tap doesn't crash and UI remains stable
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.byType(ContactsScreen), findsOneWidget);
      // Note: Navigation to contact details not yet implemented in ContactsScreen
    });

    testWidgets('should handle search button tap', (WidgetTester tester) async {
      when(
        () => mockContactRepository.findAll(),
      ).thenAnswer((_) async => <Contact>[]);

      await tester.pumpWidget(const MaterialApp(home: ContactsScreen()));

      await tester.pump();

      // Tap search button
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Verify the tap doesn't crash (search functionality not yet implemented)
      expect(find.byType(ContactsScreen), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should handle add button tap', (WidgetTester tester) async {
      when(
        () => mockContactRepository.findAll(),
      ).thenAnswer((_) async => <Contact>[]);

      await tester.pumpWidget(const MaterialApp(home: ContactsScreen()));

      await tester.pump();

      // Tap add button
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();

      // Verify the tap doesn't crash (add functionality not yet implemented)
      expect(find.byType(ContactsScreen), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNWidgets(2));
    });

    testWidgets('should display contact list items correctly', (
      WidgetTester tester,
    ) async {
      final List<Contact> contacts = <Contact>[
        const Contact(id: 1, name: 'John Doe', email: 'john@example.com'),
        const Contact(id: 2, name: 'Jane Smith', phone: '+1234567890'),
      ];

      when(
        () => mockContactRepository.findAll(),
      ).thenAnswer((_) async => contacts);

      await tester.pumpWidget(const MaterialApp(home: ContactsScreen()));

      await tester.pump();

      // Verify ListView is present
      expect(find.byType(ListView), findsOneWidget);

      // Verify correct number of contact items
      expect(find.byType(ContactListItem), findsNWidgets(2));

      // Verify contact details are displayed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('+1234567890'), findsOneWidget);
    });
  });
}
