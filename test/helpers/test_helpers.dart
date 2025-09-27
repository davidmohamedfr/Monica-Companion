import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/models/contact.dart';
import 'package:monica_companion/db/repositories/repository_registry.dart';
import 'package:monica_companion/services/service_locator.dart';

import '../mocks/mock_services.dart';

/// Test helper utilities and common setup functions
class TestHelpers {
  TestHelpers._();

  /// Setup mock fallback values for mocktail
  static void setupMockFallbacks() {
    // Register fallback values for common types
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<String>[]);
    registerFallbackValue(DateTime.now());
    registerFallbackValue(Duration.zero);
  }

  /// Setup service locator with mock services for widget tests
  static Future<void> setupServiceLocatorForTests() async {
    final ServiceLocator locator = ServiceLocator.instance;

    // Clear any existing services
    locator.clear();

    // Create mock database interface
    final MockDatabaseInterface mockDatabase = MockDatabaseInterface();
    when(mockDatabase.initialize).thenAnswer((_) async {});
    when(mockDatabase.close).thenAnswer((_) async {});

    // Create mock contact repository
    final MockContactRepository mockContactRepository = MockContactRepository();
    when(mockContactRepository.findAll).thenAnswer((_) async => <Contact>[]);

    // Create mock repository registry
    final MockRepositoryRegistry mockRegistry = MockRepositoryRegistry();
    when(mockRegistry.initialize).thenAnswer((_) async {});
    when(mockRegistry.dispose).thenAnswer((_) async {});
    when(
      () => mockRegistry.contactRepository,
    ).thenReturn(mockContactRepository);

    // Register services
    locator.registerSingleton<DatabaseInterface>(mockDatabase);
    locator.registerSingleton<RepositoryRegistry>(mockRegistry);
  }

  /// Create a mock DateTime for consistent testing
  static DateTime createMockDateTime({
    int year = 2023,
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
  }) => DateTime(year, month, day, hour, minute, second);

  /// Wait for async operations to complete in tests
  static Future<void> pumpAndSettle(
    WidgetTester tester, [
    Duration? duration,
  ]) async {
    await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 100));
  }

  /// Verify that a function throws a specific exception
  static void expectThrows<T extends Exception>(
    dynamic Function() function,
    T matcher,
  ) {
    expect(function, throwsA(isA<T>()));
  }

  /// Create test data for database entities
  static Map<String, dynamic> createTestEntityMap({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additional,
  }) {
    final Map<String, dynamic> baseMap = <String, dynamic>{
      'id': id ?? 1,
      'created_at': (createdAt ?? createMockDateTime()).toIso8601String(),
      'updated_at': (updatedAt ?? createMockDateTime()).toIso8601String(),
    };

    if (additional != null) {
      baseMap.addAll(additional);
    }

    return baseMap;
  }
}
