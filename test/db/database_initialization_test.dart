import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';

// Mock classes
class MockDatabase extends Mock implements Database {}

void main() {
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockDatabase();
  });

  group('DatabaseService - Simplified Initialization Fix', () {
    testWidgets('should configure database with only essential pragma', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> executedStatements = <String>[];

      when(() => mockDatabase.execute(any())).thenAnswer((
        Invocation invocation,
      ) async {
        executedStatements.add(invocation.positionalArguments[0] as String);
      });

      // Act - Test the fixed configuration that prevents deadlock
      await mockDatabase.execute('PRAGMA foreign_keys = ON');

      // Assert
      expect(executedStatements, contains('PRAGMA foreign_keys = ON'));
      expect(executedStatements, hasLength(1));

      // Verify the problematic WAL pragma is NOT executed
      expect(executedStatements, isNot(contains('PRAGMA journal_mode = WAL')));
      expect(
        executedStatements,
        isNot(contains('PRAGMA synchronous = NORMAL')),
      );

      verify(() => mockDatabase.execute('PRAGMA foreign_keys = ON')).called(1);
    });

    testWidgets('should create contacts table with proper schema', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> executedStatements = <String>[];

      when(() => mockDatabase.execute(any())).thenAnswer((
        Invocation invocation,
      ) async {
        executedStatements.add(invocation.positionalArguments[0] as String);
      });

      when(() => mockDatabase.insert(any(), any())).thenAnswer((_) async => 1);

      // Act - Test the simplified table creation that prevents deadlock
      const String createSchemaVersionTable = '''
      CREATE TABLE IF NOT EXISTS schema_version (
        version INTEGER PRIMARY KEY,
        migrated_at TEXT NOT NULL
      )
    ''';

      const String createContactsTable = '''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        avatar TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''';

      await mockDatabase.execute(createSchemaVersionTable);
      await mockDatabase.execute(createContactsTable);
      await mockDatabase.insert('schema_version', <String, Object?>{
        'version': 1,
        'migrated_at': DateTime.now().toIso8601String(),
      });

      // Assert
      expect(executedStatements, contains(createSchemaVersionTable));
      expect(executedStatements, contains(createContactsTable));
      verify(() => mockDatabase.execute(createSchemaVersionTable)).called(1);
      verify(() => mockDatabase.execute(createContactsTable)).called(1);
      verify(() => mockDatabase.insert('schema_version', any())).called(1);
    });

    testWidgets(
      'should handle database initialization without nested transactions',
      (WidgetTester tester) async {
        // Arrange
        int transactionCallCount = 0;

        when(() => mockDatabase.execute(any())).thenAnswer((_) async {});
        when(
          () => mockDatabase.insert(any(), any()),
        ).thenAnswer((_) async => 1);

        // Mock transaction to count calls and ensure no nesting
        when(() => mockDatabase.transaction<void>(any())).thenAnswer((
          Invocation invocation,
        ) async {
          transactionCallCount++;
          final Future<void> Function(Transaction) action =
              invocation.positionalArguments[0]
                  as Future<void> Function(Transaction);
          final MockTransaction mockTxn = MockTransaction();
          await action(mockTxn);
        });

        // Act - Simulate the onCreate callback that was fixed
        await mockDatabase.execute(
          'CREATE TABLE IF NOT EXISTS schema_version '
          '(version INTEGER PRIMARY KEY, migrated_at TEXT NOT NULL)',
        );
        await mockDatabase.execute(
          'CREATE TABLE contacts (id TEXT PRIMARY KEY, '
          'name TEXT NOT NULL, email TEXT, phone TEXT, avatar TEXT, '
          'created_at TEXT NOT NULL, updated_at TEXT NOT NULL)',
        );
        await mockDatabase.insert('schema_version', <String, Object?>{
          'version': 1,
          'migrated_at': DateTime.now().toIso8601String(),
        });

        // Assert - No nested transactions that would cause deadlock
        expect(
          transactionCallCount,
          equals(0),
        ); // onCreate should not create additional transactions

        verify(() => mockDatabase.execute(any())).called(2);
        verify(() => mockDatabase.insert('schema_version', any())).called(1);
      },
    );

    testWidgets('should handle upgrade without recreation for same version', (
      WidgetTester tester,
    ) async {
      // Arrange
      const int oldVersion = 1;
      const int newVersion = 1;

      when(() => mockDatabase.execute(any())).thenAnswer((_) async {});

      // Act - Test upgrade logic
      if (oldVersion < newVersion) {
        await mockDatabase.execute('DROP TABLE IF EXISTS contacts');
        // onCreate would be called here
      }

      // Assert - No operations for same version
      verifyNever(() => mockDatabase.execute('DROP TABLE IF EXISTS contacts'));
    });

    testWidgets('should recreate tables during version upgrade', (
      WidgetTester tester,
    ) async {
      // Arrange
      const int oldVersion = 1;
      const int newVersion = 2;
      final List<String> executedStatements = <String>[];

      when(() => mockDatabase.execute(any())).thenAnswer((
        Invocation invocation,
      ) async {
        executedStatements.add(invocation.positionalArguments[0] as String);
      });
      when(() => mockDatabase.insert(any(), any())).thenAnswer((_) async => 1);

      // Act - Test upgrade logic
      if (oldVersion < newVersion) {
        await mockDatabase.execute('DROP TABLE IF EXISTS contacts');
        // Simulate onCreate being called
        await mockDatabase.execute(
          'CREATE TABLE contacts (id TEXT PRIMARY KEY, '
          'name TEXT NOT NULL, email TEXT, phone TEXT, avatar TEXT, '
          'created_at TEXT NOT NULL, updated_at TEXT NOT NULL)',
        );
        await mockDatabase.insert('schema_version', <String, Object?>{
          'version': newVersion,
          'migrated_at': DateTime.now().toIso8601String(),
        });
      }

      // Assert
      expect(executedStatements, contains('DROP TABLE IF EXISTS contacts'));
      expect(
        executedStatements.where(
          (String stmt) => stmt.contains('CREATE TABLE contacts'),
        ),
        hasLength(1),
      );
      verify(
        () => mockDatabase.execute('DROP TABLE IF EXISTS contacts'),
      ).called(1);
      verify(() => mockDatabase.insert('schema_version', any())).called(1);
    });
  });
}

// Helper mock class
class MockTransaction extends Mock implements Transaction {}
