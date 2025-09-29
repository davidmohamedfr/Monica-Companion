# Testing Guidelines

This document outlines the testing strategies and guidelines for the Monica Mobile App Flutter project.

## Test Coverage

- Coverage enabled with `--coverage` flag
- Reports generated in `coverage/lcov.info`
- Threshold validation via lefthook hooks
- Target: 60% minimum coverage (enforced in CI)

## Tools and Frameworks

### Core Testing Tools
- `flutter_test` - SDK testing framework for unit and widget tests
- `integration_test` - SDK integration testing for full app flows
- `mocktail` - Modern mocking library with type safety
- `flutter_lints` - Comprehensive code quality analysis
- `lefthook` - Git hooks for automated testing pipeline

### CI/CD Integration
- **Android Emulator**: API level 30 for integration tests in CI
- **GitHub Actions**: Automated testing on push and PR
- **Coverage reporting**: LCOV format for coverage analysis
- **Test randomization**: `--test-randomize-ordering-seed random` for robustness

### Development Dependencies (pubspec.yaml)
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.7
  mocktail: ^1.0.0
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
```

## Testing Strategy

- **Three-stage approach**: Quality checks → Unit tests → Integration tests
- **Pre-commit**: Format, lint, debug checks, dependency validation
- **Pre-push**: Unit and widget tests with coverage
- **CI/PR**: Integration tests and comprehensive validation
- **TDD-ready**: Structured for test-driven development
- **Types of tests implemented:**
  - **Unit Tests**: Business logic, utilities, core functionality
  - **Widget Tests**: UI components, user interactions, state management
  - **Integration Tests**: Full app flows, end-to-end scenarios
  - **Quality Tests**: Linting, formatting, debugging statement detection

## Test Execution Process

### Automated (via Git Hooks)
- `git commit` - Runs quality checks automatically
- `git push` - Runs unit tests with coverage
- Emergency bypass: `LEFTHOOK=0 git commit`

### Manual Commands
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test directory
flutter test test/core/

# Run integration tests
flutter test integration_test/

# Manual hook execution
lefthook run pre-commit    # Quality checks
lefthook run pre-push      # Test execution
```

### CI/CD Pipeline
- **Push workflow**: `flutter test --coverage --test-randomize-ordering-seed random` (@.github/workflows/push.yml)
- **PR workflow**: `flutter test integration_test/` with Android emulator (@.github/workflows/PR.yml)
- **Release workflow**: `flutter test` for final validation (@.github/workflows/release.yml)
- **Test randomization**: Ensures tests don't depend on execution order
- **Parallel execution**: Tests run in separate jobs for faster feedback

### Git Hooks (lefthook.yml)
```yaml
# Pre-commit: Quality checks
pre-commit:
  - dart-format: Auto-format code and stage changes
  - dart-analyze: Comprehensive lint analysis with fatal warnings
  - no-debug-prints: Prevent debug statements in production code
  - deps-check: Validate dependency versions and constraints

# Pre-push: Test execution
pre-push:
  - flutter test --coverage: Unit and widget tests with coverage
  - coverage-threshold: Enforce minimum 60% coverage
```

## Test Architecture

### Directory Structure
```
test/
├── core/
│   ├── di/                    # Dependency injection tests
│   ├── services/              # Core service tests (app_initialization_service_test.dart)
│   └── utils/                 # Utility function tests (validators_test.dart, logger_test.dart, error_transformer_test.dart)
├── config/                    # Configuration tests (environment_test.dart)
├── db/
│   ├── models/                # Database model tests
│   ├── repositories/          # Repository layer tests (30+ test files)
│   └── migrations/            # Database migration tests (.disabled)
├── features/
│   ├── contacts/              # Contact feature tests (contacts_screen_test.dart)
│   ├── calls/widgets/         # Call feature widget tests
│   └── navigation/            # Navigation tests (main_shell_test.dart)
├── integration/               # Cross-feature integration tests
├── helpers/                   # Test utilities (test_helpers.dart)
├── mocks/                     # Mock implementations (mock_services.dart)
└── services/                  # Service layer tests

integration_test/
├── app_test.dart             # Full app integration tests
├── database_integration_test.dart  # Database CRUD operations
├── navigation_flow_test.dart # Navigation flow tests
└── helpers/                  # Integration test utilities
    └── integration_test_helpers.dart
```

### Test File Status
- **Active tests**: 30 test files (all must pass)
- **Disabled tests**: 6 test files (.disabled extension)
- **Total coverage**: Unit, widget, integration, and quality tests

## Mocking and Stubbing

### Mock Services (`test/mocks/mock_services.dart`)
- `MockDatabaseInterface` - Database operations and SQL queries
- `MockRepositoryRegistry` - Repository pattern mocking
- `MockContactRepository` - Contact-specific repository operations
- `MockApiService` - API interactions (future implementation)
- `MockStorageService` - Local storage operations
- `MockApiResponse<T>` - Structured API responses with success/failure states

### Test Helpers (`test/helpers/test_helpers.dart`)
- `TestHelpers.setupMockFallbacks()` - Configure mocktail fallback values for common types
- `TestHelpers.setupServiceLocatorForTests()` - Initialize service locator with mocked dependencies
- `TestHelpers.createMockDateTime()` - Generate consistent test dates
- `TestHelpers.pumpAndSettle()` - Handle widget test animations and async operations
- `TestHelpers.expectThrows<T>()` - Exception assertion utilities
- `TestHelpers.createTestEntityMap()` - Generate test data with base fields (id, created_at, updated_at)

### Integration Test Helpers (`integration_test/helpers/integration_test_helpers.dart`)
- `IntegrationTestHelpers.setupIntegrationTest()` - Configure binding with live frame policy
- `IntegrationTestHelpers.waitForAppToLoad()` - Handle app initialization delays
- `IntegrationTestHelpers.takeScreenshot()` - Capture test execution screenshots
- `IntegrationTestHelpers.pressBackButton()` - Simulate device navigation
- `IntegrationTestHelpers.scrollToFindWidget()` - Navigate scrollable content
- `IntegrationTestHelpers.fillTextField()` - Handle form interactions
- `IntegrationTestHelpers.expectWidgetVisible()` - Widget state verification

## Testing Patterns and Best Practices

### Repository Testing Pattern
- **Comprehensive method coverage**: Each repository method tested with multiple scenarios
- **Database query verification**: Mock database calls captured and verified
- **Edge case handling**: SQL injection, unicode, extreme values, empty inputs
- **Error propagation**: Database exceptions wrapped in custom `DatabaseException`
- **Data transformation**: `fromMap()` method testing for model conversion
- **Search functionality**: Partial matching, case sensitivity, cross-field search

### Widget Testing Pattern
- **Service locator mocking**: Clean dependency injection for isolated testing
- **State management testing**: Loading, empty, populated, and error states
- **User interaction simulation**: Taps, text input, navigation
- **Widget tree verification**: Specific widget presence and properties
- **Async operation handling**: `pumpAndSettle()` for animations and state changes

### Integration Testing Pattern
- **Real app startup**: Full `MonicaApp` initialization in tests
- **Database operations**: Actual CRUD operations on test database (not mocked)
- **Feature workflows**: End-to-end user journey validation
- **Cross-feature integration**: Navigation between screens and features
- **Screenshot documentation**: Visual regression testing capabilities
- **Widget selector specificity**: Use descendant finders to avoid duplicate widget matches
- **Test data completeness**: Entity models require complete field sets for database operations

### Mock Strategy
- **Interface implementation**: Mocks implement actual service interfaces
- **Fallback registration**: All common types have registered fallback values
- **Behavioral setup**: Default behaviors configured in setUp()
- **Verification patterns**: Method call counting and argument capture
- **Service locator integration**: Centralized dependency mocking

## Database Testing Strategy

### Repository Testing Approach
- **SQLite query testing**: Mock `DatabaseInterface` to verify SQL generation
- **Data transformation testing**: Validate `fromMap()` model conversion
- **Error handling**: Database exceptions properly wrapped and propagated
- **Search functionality**: LIKE queries, exact matches, cross-field search
- **Date operations**: Birthday searches, upcoming events, strftime usage

### Test Data Patterns
```dart
// Mock database response format
final List<Map<String, dynamic>> mockContactsResponse = [
  {
    'id': 1,
    'name': 'John Smith',
    'email': 'john.smith@email.com',
    'phone': '+1-555-0101',
    'created_at': testDate.toIso8601String(),
    'updated_at': testDate.toIso8601String(),
  },
];

// Expected model objects
final List<Contact> expectedContacts = [
  Contact(
    id: 1,
    name: 'John Smith',
    email: 'john.smith@email.com',
    phone: '+1-555-0101',
    createdAt: testDate,
    updatedAt: testDate,
  ),
];
```

### Integration vs Unit Testing
- **Unit tests**: Mock database interface, test SQL generation and data transformation
- **Integration tests**: Real database operations, actual CRUD workflows (never mocked)
- **Coverage**: Repository methods tested at both levels for complete validation
- **Widget Test Specificity**: Navigation tests failing due to 'too many widgets found' should target specific widget types (AppBar, NavigationBar) as ancestors
- **Test Entity Requirements**: Test data for entities must include all required fields for database operations (createdAt, updatedAt, etc.)

## Test Implementation Strategy

### Test Status Management
- **All enabled tests MUST pass at all times** - no failing tests allowed in enabled state
- **Disable tests for unimplemented features** rather than premature implementation
- **Focus test coverage on actually implemented functionality**
- **Use .disabled file extension** to document future test requirements
- **Current status**: 30 active test files, 6 disabled test files

### Test-Driven Development
- **TDD preferred approach** - write tests before implementation when possible
- **Red-Green-Refactor cycle** - failing test → minimal implementation → refactor
- **Test-first for new features** - define behavior through tests before coding
- **Integration tests validate real functionality** - not just mock interactions
- **Repository-first testing**: Database layer tests drive implementation

### Test Data Management
- **Consistent test dates**: Use `TestHelpers.createMockDateTime()` for predictable dates
- **Mock data factories**: Structured test data generation with `createTestEntityMap()`
- **Database isolation**: Each test uses clean database state
- **Contact test data**: Comprehensive contact records with all field variations
- **Edge case data**: Unicode, special characters, null values, extreme ranges

### Test Lifecycle Management
- **Enable tests only when features are implemented** - avoid premature test activation
- **Disabled tests serve as implementation todo list** - clear documentation of missing functionality
- **Test migration pattern**: `disabled` → `enabled` → `passing` as features are built
- **Keep disabled tests updated** - maintain test structure even when not executing
- **Repository tests**: Contact repository fully tested, other repositories awaiting implementation

## Current Test Coverage Status

### Implemented and Tested ✅
- **Contact Repository**: Complete test suite with 15+ test groups covering:
  - `findByName()`: Partial matching with LIKE queries
  - `findByEmail()`: Exact email matching
  - `findByBirthdayMonth()`: Month-based birthday searches
  - `findUpcomingBirthdays()`: Complex date range queries
  - `search()`: Cross-field search (name, email, phone)
  - `fromMap()`: Data transformation and null handling
  - Edge cases: SQL injection, unicode, extreme values
- **Core Services**: App initialization service testing
- **Core Utils**: Validators, logger, error transformer testing
- **Feature Widgets**: Contact screen widget testing
- **Navigation**: Main shell and navigation flow testing
- **Integration**: Database CRUD operations and app flows

### Disabled (Awaiting Implementation) ⏳
- **Repository Tests** (6 files):
  - `sqlite_note_repository_test.dart.disabled`
  - `sqlite_gift_repository_test.dart.disabled`
  - `sqlite_debt_repository_test.dart.disabled`
  - `sqlite_reminder_repository_test.dart.disabled`
  - `repository_registry_test.dart.disabled`
  - `migration_runner_test.dart.disabled`

### Test Quality Metrics
- **Total test files**: 30 active + 6 disabled
- **Repository coverage**: 1/10 repositories fully tested
- **Widget testing**: Contact screens and navigation components
- **Integration testing**: Database operations and app startup
- **CI enforcement**: 60% minimum coverage threshold

## Testing Examples

### Repository Test Example
```dart
// Test file: test/db/repositories/sqlite_contact_repository_test.dart
testWidgets('should find contacts by name with partial matching using LIKE', (WidgetTester tester) async {
  const String searchName = 'John';
  final List<Map<String, dynamic>> johnContacts = mockContactsResponse
      .where((contact) => (contact['name'] as String).contains(searchName))
      .toList();

  when(() => mockDatabase.rawQuery(any(), any())).thenAnswer((_) async => johnContacts);

  final List<Contact> result = await repository.findByName(searchName);

  expect(result, hasLength(2));
  verify(() => mockDatabase.rawQuery(
    '''
    SELECT * FROM contacts
    WHERE name LIKE ?
    ORDER BY name ASC
  ''',
    <dynamic>['%$searchName%'],
  )).called(1);
});
```

### Widget Test Example
```dart
// Test file: test/features/contacts/contacts_screen_test.dart
testWidgets('should display loading indicator initially', (WidgetTester tester) async {
  when(() => mockContactRepository.findAll())
      .thenAnswer((_) async => <Contact>[]);

  await tester.pumpWidget(
    const MaterialApp(
      home: ContactsScreen(),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### Integration Test Example
```dart
// Test file: integration_test/database_integration_test.dart
testWidgets('should perform full CRUD operations on contacts', (WidgetTester tester) async {
  await tester.pumpWidget(const MonicaApp());
  await tester.pumpAndSettle();

  // IMPORTANT: Complete entity with all required fields
  final Contact testContact = Contact(
    name: 'Integration Test User',
    email: 'integration@test.com',
    phone: '+1234567890',
    createdAt: DateTime.now(),  // Required for database operations
    updatedAt: DateTime.now(),  // Required for database operations
  );

  // CREATE
  final int contactId = await contactRepository.insert(testContact);
  expect(contactId, isPositive);

  // READ
  final Contact? retrievedContact = await contactRepository.findById(contactId);
  expect(retrievedContact, isNotNull);
  expect(retrievedContact!.name, testContact.name);
});
```

## Integration Test Guidelines

### Widget Selector Best Practices
```dart
// ❌ WRONG: Generic text finder causing duplicates
expect(find.text('Contacts'), findsOneWidget);

// ✅ CORRECT: Specific descendant finder
expect(
  find.descendant(
    of: find.byType(AppBar),
    matching: find.text('Contacts')
  ),
  findsOneWidget,
);

// ✅ CORRECT: Target navigation specifically
await tester.tap(find.descendant(
  of: find.byType(NavigationBar),
  matching: find.text('Settings'),
));
```

### Database Integration Requirements
- **Real database operations**: Integration tests must use actual database, never mocks
- **Complete entities**: All entity models must have required fields (id, createdAt, updatedAt)
- **Transaction handling**: Database repository methods must handle concurrent operations properly
- **Cleanup**: Tests should clean up database state after execution