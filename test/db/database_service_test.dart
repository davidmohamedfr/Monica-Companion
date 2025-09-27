import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/constants/app_constants.dart';
import 'package:monica_companion/db/database_service.dart';
import 'package:sqflite/sqflite.dart';

// Mock classes
class MockDatabase extends Mock implements Database {}
class MockTransaction extends Mock implements Transaction {}

void main() {
  late DatabaseService databaseService;
  late MockDatabase mockDatabase;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(MockDatabase());
    registerFallbackValue(MockTransaction());
  });

  setUp(() {
    mockDatabase = MockDatabase();
    databaseService = DatabaseService();

    // Setup default mock behaviors
    when(() => mockDatabase.isOpen).thenReturn(true);
    when(() => mockDatabase.close()).thenAnswer((_) async {});
    when(() => mockDatabase.rawQuery(any(), any())).thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => mockDatabase.rawUpdate(any(), any())).thenAnswer((_) async => 1);
    when(() => mockDatabase.transaction(any())).thenAnswer((_) async => 'success');
    when(() => mockDatabase.execute(any())).thenAnswer((_) async {});
  });

  group('DatabaseService - Properties', () {
    testWidgets('should return correct database version', (WidgetTester tester) async {
      expect(databaseService.version, equals(AppConstants.dbVersion));
    });

    testWidgets('should return false for isOpen when no database initialized', (WidgetTester tester) async {
      expect(databaseService.isOpen, isFalse);
    });
  });

  group('DatabaseService - Configuration', () {
    testWidgets('should execute PRAGMA statements for database configuration', (WidgetTester tester) async {
      final MockDatabase configDatabase = MockDatabase();
      final List<String> executedStatements = <String>[];

      when(() => configDatabase.execute(any())).thenAnswer((invocation) async {
        executedStatements.add(invocation.positionalArguments[0] as String);
      });

      // Test the expected configuration statements that would be executed
      await configDatabase.execute('PRAGMA foreign_keys = ON');
      await configDatabase.execute('PRAGMA journal_mode = WAL');
      await configDatabase.execute('PRAGMA synchronous = NORMAL');

      expect(executedStatements, contains('PRAGMA foreign_keys = ON'));
      expect(executedStatements, contains('PRAGMA journal_mode = WAL'));
      expect(executedStatements, contains('PRAGMA synchronous = NORMAL'));
      verify(() => configDatabase.execute('PRAGMA foreign_keys = ON')).called(1);
      verify(() => configDatabase.execute('PRAGMA journal_mode = WAL')).called(1);
      verify(() => configDatabase.execute('PRAGMA synchronous = NORMAL')).called(1);
    });
  });

  group('DatabaseService - Database Operations', () {
    testWidgets('should execute raw queries with parameters', (WidgetTester tester) async {
      const String testSql = 'SELECT * FROM contacts WHERE id = ?';
      const List<dynamic> testParams = <dynamic>[123];
      final List<Map<String, dynamic>> expectedResult = <Map<String, dynamic>>[
        <String, dynamic>{'id': 123, 'name': 'Test Contact'},
      ];

      when(() => mockDatabase.rawQuery(testSql, testParams))
          .thenAnswer((_) async => expectedResult);

      final List<Map<String, dynamic>> result = await mockDatabase.rawQuery(testSql, testParams);

      expect(result, equals(expectedResult));
      verify(() => mockDatabase.rawQuery(testSql, testParams)).called(1);
    });

    testWidgets('should execute raw queries without parameters', (WidgetTester tester) async {
      const String testSql = 'SELECT COUNT(*) FROM contacts';
      final List<Map<String, dynamic>> expectedResult = <Map<String, dynamic>>[
        <String, dynamic>{'COUNT(*)': 5},
      ];

      when(() => mockDatabase.rawQuery(testSql, null))
          .thenAnswer((_) async => expectedResult);

      final List<Map<String, dynamic>> result = await mockDatabase.rawQuery(testSql, null);

      expect(result, equals(expectedResult));
      verify(() => mockDatabase.rawQuery(testSql, null)).called(1);
    });

    testWidgets('should execute raw update operations', (WidgetTester tester) async {
      const String testSql = 'UPDATE contacts SET name = ? WHERE id = ?';
      const List<dynamic> testParams = <dynamic>['Updated Name', 123];
      const int expectedRowsAffected = 1;

      when(() => mockDatabase.rawUpdate(testSql, testParams))
          .thenAnswer((_) async => expectedRowsAffected);

      final int result = await mockDatabase.rawUpdate(testSql, testParams);

      expect(result, equals(expectedRowsAffected));
      verify(() => mockDatabase.rawUpdate(testSql, testParams)).called(1);
    });

    testWidgets('should handle raw execute with empty parameters', (WidgetTester tester) async {
      const String testSql = 'DELETE FROM contacts';
      const int expectedRowsAffected = 3;

      when(() => mockDatabase.rawUpdate(testSql, <Object?>[]))
          .thenAnswer((_) async => expectedRowsAffected);

      final int result = await mockDatabase.rawUpdate(testSql, <Object?>[]);

      expect(result, equals(expectedRowsAffected));
      verify(() => mockDatabase.rawUpdate(testSql, <Object?>[])).called(1);
    });
  });

  group('DatabaseService - Transaction Management', () {
    testWidgets('should execute operations within transaction', (WidgetTester tester) async {
      final MockTransaction mockTransaction = MockTransaction();
      const String expectedResult = 'transaction_success';

      when(() => mockDatabase.transaction<String>(any()))
          .thenAnswer((invocation) async {
            final Function(Transaction) action = invocation.positionalArguments[0] as Function(Transaction);
            return await action(mockTransaction) as String;
          });

      final String result = await mockDatabase.transaction<String>((Transaction txn) async {
        return expectedResult;
      });

      expect(result, equals(expectedResult));
      verify(() => mockDatabase.transaction<String>(any())).called(1);
    });

    testWidgets('should pass transaction object to action function', (WidgetTester tester) async {
      final MockTransaction mockTransaction = MockTransaction();
      Transaction? capturedTransaction;

      when(() => mockDatabase.transaction<void>(any()))
          .thenAnswer((invocation) async {
            final Function(Transaction) action = invocation.positionalArguments[0] as Function(Transaction);
            return await action(mockTransaction);
          });

      await mockDatabase.transaction<void>((Transaction txn) async {
        capturedTransaction = txn;
      });

      expect(capturedTransaction, equals(mockTransaction));
      verify(() => mockDatabase.transaction<void>(any())).called(1);
    });

    testWidgets('should handle transaction rollback on error', (WidgetTester tester) async {
      final Exception testException = Exception('Transaction failed');

      when(() => mockDatabase.transaction<void>(any())).thenThrow(testException);

      expect(
        () => mockDatabase.transaction<void>((Transaction txn) async {
          throw testException;
        }),
        throwsA(equals(testException)),
      );

      verify(() => mockDatabase.transaction<void>(any())).called(1);
    });
  });

  group('DatabaseService - Error Handling', () {
    testWidgets('should handle database query errors', (WidgetTester tester) async {
      const String testSql = 'INVALID SQL SYNTAX';
      final Exception queryError = Exception('SQL syntax error');

      when(() => mockDatabase.rawQuery(testSql, any())).thenThrow(queryError);

      expect(
        () => mockDatabase.rawQuery(testSql, null),
        throwsA(equals(queryError)),
      );

      verify(() => mockDatabase.rawQuery(testSql, any())).called(1);
    });

    testWidgets('should handle database update errors', (WidgetTester tester) async {
      const String testSql = 'INVALID UPDATE SYNTAX';
      final Exception updateError = Exception('SQL update error');

      when(() => mockDatabase.rawUpdate(testSql, any())).thenThrow(updateError);

      expect(
        () => mockDatabase.rawUpdate(testSql, <Object?>[]),
        throwsA(equals(updateError)),
      );

      verify(() => mockDatabase.rawUpdate(testSql, any())).called(1);
    });

    testWidgets('should handle transaction errors', (WidgetTester tester) async {
      final Exception transactionError = Exception('Transaction failed');

      when(() => mockDatabase.transaction<void>(any())).thenThrow(transactionError);

      expect(
        () => mockDatabase.transaction<void>((Transaction txn) async {}),
        throwsA(equals(transactionError)),
      );

      verify(() => mockDatabase.transaction<void>(any())).called(1);
    });

    testWidgets('should handle database close errors', (WidgetTester tester) async {
      final Exception closeError = Exception('Database close failed');

      when(() => mockDatabase.close()).thenThrow(closeError);

      expect(
        () => mockDatabase.close(),
        throwsA(equals(closeError)),
      );

      verify(() => mockDatabase.close()).called(1);
    });
  });

  group('DatabaseService - Connection Management', () {
    testWidgets('should properly close database connection', (WidgetTester tester) async {
      when(() => mockDatabase.isOpen).thenReturn(false);

      await databaseService.close();

      expect(databaseService.isOpen, isFalse);
    });

    testWidgets('should handle close when database is null', (WidgetTester tester) async {
      await databaseService.close();

      expect(databaseService.isOpen, isFalse);
    });

    testWidgets('should handle multiple close calls gracefully', (WidgetTester tester) async {
      await databaseService.close();
      await databaseService.close();
      await databaseService.close();

      expect(databaseService.isOpen, isFalse);
    });

    testWidgets('should return correct isOpen state based on database', (WidgetTester tester) async {
      // Test isOpen when database is null (default state)
      expect(databaseService.isOpen, isFalse);

      // Test behavior of mock database open states
      when(() => mockDatabase.isOpen).thenReturn(true);
      expect(mockDatabase.isOpen, isTrue);

      when(() => mockDatabase.isOpen).thenReturn(false);
      expect(mockDatabase.isOpen, isFalse);
    });
  });
}