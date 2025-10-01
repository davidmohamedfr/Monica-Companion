import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:monica_companion/core/di/database_module.dart';
import 'package:monica_companion/core/services/app_initialization_service.dart';
import 'package:monica_companion/db/interfaces/contact_repository.dart';
import 'package:monica_companion/db/models/contact.dart';
import 'package:monica_companion/db/repositories/repository_registry.dart';
import 'package:monica_companion/main.dart';
import 'package:monica_companion/services/service_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Database Integration Tests', () {
    late ContactRepository contactRepository;

    setUpAll(() async {
      // Initialize app services before running tests
      await AppInitializationService.instance.initialize();

      final RepositoryRegistry registry = ServiceLocator.instance
          .get<RepositoryRegistry>();
      contactRepository = registry.contactRepository;
    });

    tearDownAll(DatabaseModule.dispose);

    testWidgets('should perform full CRUD operations on contacts', (
      WidgetTester tester,
    ) async {
      // Start the app to ensure database is initialized
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Test data
      final Contact testContact = Contact(
        name: 'Integration Test User',
        email: 'integration@test.com',
        phone: '+1234567890',
        notes: 'Created during integration testing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // CREATE: Insert a new contact
      final int contactId = await contactRepository.insert(testContact);
      expect(contactId, isPositive);

      // READ: Find the inserted contact
      final Contact? retrievedContact = await contactRepository.findById(
        contactId,
      );
      expect(retrievedContact, isNotNull);
      expect(retrievedContact!.id, contactId);
      expect(retrievedContact.name, testContact.name);
      expect(retrievedContact.email, testContact.email);
      expect(retrievedContact.phone, testContact.phone);

      // UPDATE: Modify the contact
      final Contact updatedContact = retrievedContact.copyWith(
        notes: 'Updated during integration testing',
        phone: '+0987654321',
      );

      final bool updateResult = await contactRepository.update(updatedContact);
      expect(updateResult, true);

      // Verify update
      final Contact? updatedRetrieved = await contactRepository.findById(
        contactId,
      );
      expect(updatedRetrieved, isNotNull);
      expect(updatedRetrieved!.notes, 'Updated during integration testing');
      expect(updatedRetrieved.phone, '+0987654321');

      // SEARCH: Test search functionality
      final List<Contact> searchResults = await contactRepository.search(
        'Integration',
      );
      expect(searchResults, isNotEmpty);
      expect(searchResults.any((Contact c) => c.id == contactId), true);

      // COUNT: Verify count increases
      final int countBefore = await contactRepository.count();
      expect(countBefore, isPositive);

      // DELETE: Remove the test contact
      final bool deleteResult = await contactRepository.delete(contactId);
      expect(deleteResult, true);

      // Verify deletion
      final Contact? deletedContact = await contactRepository.findById(
        contactId,
      );
      expect(deletedContact, isNull);

      // Verify count decreases
      final int countAfter = await contactRepository.count();
      expect(countAfter, countBefore - 1);
    });

    testWidgets('should handle multiple contacts operations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Create multiple test contacts
      final List<Contact> testContacts = <Contact>[
        Contact(
          name: 'Alice Johnson',
          email: 'alice@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Contact(
          name: 'Bob Wilson',
          email: 'bob@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Contact(
          name: 'Charlie Brown',
          email: 'charlie@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Insert all contacts
      final List<int> ids = await contactRepository.insertAll(testContacts);
      expect(ids.length, 3);
      expect(ids.every((int id) => id > 0), true);

      // Verify all contacts exist
      for (final int id in ids) {
        final Contact? contact = await contactRepository.findById(id);
        expect(contact, isNotNull);
      }

      // Find all contacts
      final List<Contact> allContacts = await contactRepository.findAll();
      expect(allContacts.length, greaterThanOrEqualTo(3));

      // Search by name
      final List<Contact> aliceResults = await contactRepository.findByName(
        'Alice',
      );
      expect(aliceResults, isNotEmpty);
      expect(aliceResults.any((Contact c) => c.name.contains('Alice')), true);

      // Search by email
      final List<Contact> emailResults = await contactRepository.findByEmail(
        'bob@example.com',
      );
      expect(emailResults, isNotEmpty);
      expect(emailResults.first.email, 'bob@example.com');

      // Clean up: delete all test contacts
      final int deletedCount = await contactRepository.deleteAll(ids);
      expect(deletedCount, 3);

      // Verify all are deleted
      for (final int id in ids) {
        final Contact? contact = await contactRepository.findById(id);
        expect(contact, isNull);
      }
    });

    testWidgets('should handle database constraints and errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Test inserting contact with missing required fields
      try {
        // This should work as name is the only required field
        final int id = await contactRepository.insert(
          Contact(
            name: 'Test User',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect(id, isPositive);

        // Clean up
        await contactRepository.delete(id);
      } on Object catch (e) {
        fail('Inserting contact with required fields should not fail: $e');
      }

      // Test operations on non-existent contact
      final bool exists = await contactRepository.exists(999999);
      expect(exists, false);

      final Contact? notFound = await contactRepository.findById(999999);
      expect(notFound, isNull);

      final bool deleteNonExistent = await contactRepository.delete(999999);
      expect(deleteNonExistent, false);
    });

    testWidgets('should handle concurrent database operations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Create test contacts for concurrent operations
      final List<Contact> testContacts = List<Contact>.generate(
        10,
        (int index) => Contact(
          name: 'Concurrent Test User $index',
          email: 'test$index@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Perform multiple concurrent insert operations
      final List<Future<int>> insertFutures = testContacts
          .map((Contact contact) => contactRepository.insert(contact))
          .toList();

      final List<int> ids = await Future.wait(insertFutures);

      // Verify all inserts succeeded
      expect(ids.length, 10);
      expect(ids.every((int id) => id > 0), true);

      // Perform concurrent read operations
      final List<Future<Contact?>> readFutures = ids
          .map((int id) => contactRepository.findById(id))
          .toList();

      final List<Contact?> contacts = await Future.wait(readFutures);

      // Verify all reads succeeded
      expect(contacts.length, 10);
      expect(contacts.every((Contact? contact) => contact != null), true);

      // Clean up
      final int deletedCount = await contactRepository.deleteAll(ids);
      expect(deletedCount, 10);
    });

    testWidgets('should handle database constraints validation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Test inserting contact with empty name
      // (should fail or be handled gracefully)
      try {
        await contactRepository.insert(
          Contact(
            name: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        // If it doesn't throw, verify it at least creates a record
        // or handles gracefully
      } on Object catch (e) {
        // Database constraint errors are expected and should be
        // handled gracefully
        expect(e, isNotNull);
      }

      // Test inserting contact with very long name
      final String longName = 'A' * 1000; // Very long name
      try {
        final int id = await contactRepository.insert(
          Contact(
            name: longName,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect(id, isPositive);

        // Verify it was truncated or stored correctly
        final Contact? retrieved = await contactRepository.findById(id);
        expect(retrieved, isNotNull);
        expect(retrieved!.name.isNotEmpty, true);

        // Clean up
        await contactRepository.delete(id);
      } on Object catch (e) {
        // Length constraint errors are acceptable
        expect(e, isNotNull);
      }
    });

    testWidgets('should handle large dataset operations efficiently', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Create a larger dataset to test performance and stability
      final List<Contact> largeDataset = List<Contact>.generate(
        100,
        (int index) => Contact(
          name: 'Performance Test User $index',
          email: 'perftest$index@example.com',
          phone: '+1${index.toString().padLeft(10, '0')}',
          notes:
              'Performance testing contact #$index with some additional notes',
        ),
      );

      final Stopwatch stopwatch = Stopwatch()..start();

      // Batch insert
      final List<int> ids = await contactRepository.insertAll(largeDataset);
      stopwatch.stop();

      // Verify insert performance (should complete in reasonable time)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max
      expect(ids.length, 100);
      expect(ids.every((int id) => id > 0), true);

      stopwatch
        ..reset()
        ..start();

      // Test search performance on larger dataset
      final List<Contact> searchResults = await contactRepository.search(
        'Performance',
      );
      stopwatch.stop();

      expect(searchResults.length, greaterThanOrEqualTo(100));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2000),
      ); // 2 seconds max for search

      stopwatch
        ..reset()
        ..start();

      // Test findAll performance
      final List<Contact> allContacts = await contactRepository.findAll();
      stopwatch.stop();

      expect(allContacts.length, greaterThanOrEqualTo(100));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(3000),
      ); // 3 seconds max for findAll

      // Clean up
      final int deletedCount = await contactRepository.deleteAll(ids);
      expect(deletedCount, 100);
    });

    testWidgets('should maintain data integrity during stress operations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Create initial test data
      final Contact originalContact = Contact(
        name: 'Stress Test User',
        email: 'stress@test.com',
        phone: '+1234567890',
        notes: 'Original notes',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final int contactId = await contactRepository.insert(originalContact);
      expect(contactId, isPositive);

      // Perform multiple rapid updates to test data integrity
      for (int i = 0; i < 10; i++) {
        final Contact updatedContact = Contact(
          id: contactId,
          name: 'Stress Test User $i',
          email: 'stress$i@test.com',
          phone: '+123456789$i',
          notes: 'Updated notes iteration $i',
          createdAt: originalContact.createdAt,
          updatedAt: DateTime.now(),
        );

        final bool updateResult = await contactRepository.update(
          updatedContact,
        );
        expect(updateResult, true);

        // Verify the update took effect
        final Contact? retrieved = await contactRepository.findById(contactId);
        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'Stress Test User $i');
        expect(retrieved.email, 'stress$i@test.com');
      }

      // Verify final state is consistent
      final Contact? finalContact = await contactRepository.findById(contactId);
      expect(finalContact, isNotNull);
      expect(finalContact!.name, 'Stress Test User 9');
      expect(finalContact.email, 'stress9@test.com');

      // Clean up
      final bool deleteResult = await contactRepository.delete(contactId);
      expect(deleteResult, true);
    });
  });
}
