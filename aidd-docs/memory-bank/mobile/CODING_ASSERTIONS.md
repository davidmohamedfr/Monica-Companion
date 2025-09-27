# Coding Guidelines

> Those rules must be minimal because they MUST be checked after EVERY CODE GENERATION.

## Requirements to complete a feature

**A feature is really completed if ALL of the above are satisfied: if not, iterate to fix all until all are green.**

## Steps to follow

Here are all the commands that must be run after each feature implementation, in order:

```markdown
| Order | Command               | Description                  |
|-------|-----------------------|------------------------------|
| 1     | `dart format .`       | Format all Dart code        |
| 2     | `dart analyze --fatal-warnings` | Analyze code for issues |
| 3     | `flutter test`        | Run all unit tests           |
| 4     | `flutter build apk --debug` | Build debug APK        |
| 5     | `flutter clean`       | Clean build artifacts        |
```

## Code Conventions & Style

### File Naming
- Use `snake_case.dart` for all Dart files
- Use `PascalCase` for class names: `MonicaApp`, `FeatureState`
- Use `camelCase` for functions/methods: `build`, `buildConfigItem`
- Use `camelCase` for variables: `apiBaseUrl`, `currentEnvironment`
- Private constructors: `Validators._()`

### Type Safety
- **ALWAYS** specify explicit types: `final String message = 'error';`
- Use `strict-casts: true` and `strict-inference: true`
- No `dynamic` types or implicit casts allowed
- Constructor parameters must specify types: `const AppException(this.message, [this.code]);`
- Use `always_specify_types` linter rule

### Import Strategy
- **ALWAYS** use package imports: `package:monica_companion/core/config/app_config.dart`
- **NEVER** use relative imports: avoid `../` or `./`
- Import grouping: Organize by layer (core, db, features, services)
- Consistent package prefix: `package:monica_companion/` for all internal imports
- Specific interface imports: `package:monica_companion/db/interfaces/contact_repository.dart`
- Use `always_use_package_imports` linter rule

## Project Structure Patterns

### Feature-First Architecture
- Feature modules in `lib/features/` directory
- Features organized by: `screens/`, `widgets/`, optionally `models/`
- Shared components in `lib/features/shared/` (models, utils, widgets)
- Core utilities in `lib/core/` directory
- Database layer in `lib/db/` with models, repositories, interfaces
- Services in `lib/services/` with interfaces and implementations

### Directory Structure
- Mirror test structure: `test/` mirrors `lib/`
- Database interfaces in `lib/db/interfaces/`
- Database models in `lib/db/models/`
- Repository implementations in `lib/db/repositories/`
- Feature widgets in `lib/features/{feature_name}/widgets/`
- Feature screens in `lib/features/{feature_name}/screens/`

## Widget Patterns

### Constructor Patterns
- All widgets must have `super.key` parameter: `const AppErrorWidget({super.key})`
- Use `const` constructors wherever possible
- Required parameters first, optional with named parameters
- Theme access: `final ThemeData theme = Theme.of(context);`

### Widget Structure
- Extract theme early: `final ThemeData theme = Theme.of(context);`
- Use spread operator for conditional widgets: `if (onRetry != null) ...<Widget>[]`
- Extract complex build methods: `Widget _buildConfigItem()`
- Use `FilledButton.icon()` for modern Material 3 buttons

### Material 3 Theme
- Use `useMaterial3: true` in `ThemeData`
- Access colors via `Theme.of(context).colorScheme`
- Use `ColorScheme.fromSeed()` for consistent theming
- Brand color: `Color(0xFF6366F1)` (Monica purple)

## State Management Practices

### State Classes Pattern
- Base class: `FeatureState extends Equatable` in `lib/features/shared/models/`
- Standard states: `InitialState`, `LoadingState`, `SuccessState<T>`, `ErrorState`, `EmptyState`
- All states implement `props` getter for `Equatable`
- Use typed generic: `SuccessState<T>` with data parameter
- Optional message parameters for LoadingState and EmptyState

### Service Locator Pattern
- Singleton registration: `ServiceLocator.instance.registerSingleton<T>(service)`
- Factory registration: `ServiceLocator.instance.registerFactory<T>(() => factory)`
- Service resolution: `ServiceLocator.instance.get<T>()`
- Service verification: `ServiceLocator.instance.isRegistered<T>()`
- Service cleanup: `ServiceLocator.instance.unregister<T>()`
- Clear all services: `ServiceLocator.instance.clear()`

## Error Handling Patterns

### Exception Hierarchy
- Base: `abstract class AppException implements Exception`
- Specific types: `NetworkException`, `DatabaseException`, `AuthenticationException`, `PermissionException`, `ValidationException`, `ServerException`, `CacheException`
- Always provide message: `const NetworkException(super.message, [super.code])`
- Optional error codes: `[this.code]` parameter
- ServerException supports status codes: `ServerException.withStatusCode(message, statusCode, [code])`

### Error Widget Pattern
- Use `AppErrorWidget` for consistent error display
- Required `message` parameter, optional `onRetry` callback
- Theme-aware error colors: `theme.colorScheme.error`
- Standard structure: icon, title, message, optional retry button

### Failure Classes
- Clean architecture pattern: separate `Exception` (domain) from `Failure` (presentation)
- Implement `Equatable` with `props` getter
- Use typed failures: `NetworkFailure`, `ServerFailure`, `DatabaseFailure`

## Validation Patterns

### Validator Utilities
- Static utility class: `Validators._()` private constructor
- Static methods: `static bool isValidEmail(String email)`
- Common validators: `isValidEmail`, `isValidUrl`, `isValidPhoneNumber`, `isNotEmpty`, `isValidApiToken`
- Use regex for format validation: `RegExp emailRegex = RegExp(r'^pattern$')`

## Testing Standards

### Test Organization
- Use `group()` for logical test grouping: `group('SqliteContactRepository', () {})`
- Descriptive test names: `'should return contact when valid ID provided'`
- Test both positive and negative cases with comprehensive data
- Use clear matchers: `expect(result, isTrue)`, `expect(result, equals(expected))`
- Setup test data: Create realistic mock data with all required and optional fields
- Test fixtures: Define reusable test objects like `expectedContacts` list

### Test File Management
- Active tests: `.dart` extension for enabled tests
- Disabled tests: `.dart.disabled` extension for temporarily disabled tests
- Test scope: Mirror actual implementation patterns in test structure
- Mock setup: Use `late` keyword for mock objects initialized in `setUp()`

### Mock Patterns
- Use `mocktail` for mocking: `class MockDatabaseInterface extends Mock implements DatabaseInterface`
- Centralized mocks in `/test/mocks/mock_services.dart`
- Mock API responses: `MockApiResponse<T>` with `statusCode`, `data`, and `message`
- Include `isSuccess` getter for response validation
- Mock repositories: `MockContactRepository extends Mock implements ContactRepository`
- Register fallback values: `registerFallbackValue()` in test setup

## Database Patterns

### Model Implementation
- Base class: `BaseModel extends Equatable` with common fields: `id`, `createdAt`, `updatedAt`
- Required methods: `toMap()`, `static fromMap(Map<String, dynamic> map)`, `copyWith()`
- DateTime serialization: `toIso8601String()` for storage, `DateTime.parse()` for retrieval
- Explicit type casting: `map['field'] as Type` or `map['field'] as Type?` for nullable fields
- All models extend BaseModel and implement required abstract methods

### Repository Implementation
- Base class: `BaseRepository<T extends BaseModel, ID>` implements `RepositoryInterface<T, ID>`
- Generic CRUD operations: `insert()`, `update()`, `delete()`, `findById()`, `findAll()`
- Transaction support: `insertAll()` uses database transactions for bulk operations
- Error handling: Wrap all database operations in try-catch, throw `DatabaseException`
- Raw SQL execution: Use `database.rawQuery()` and `database.rawExecute()`
- Table-specific implementations: `SqliteContactRepository extends BaseRepository<Contact, int>`

### Database Interface Pattern
- Abstract interface: `DatabaseInterface` defines core database operations
- Standard methods: `initialize()`, `close()`, `rawQuery()`, `rawExecute()`, `transaction()`
- Implementation agnostic: Support for different database backends through interface
- Service injection: Register as singleton in `DatabaseModule.initialize()`

### Repository Registry Pattern
- Centralized repository management: `RepositoryRegistry` holds all repository instances
- Dependency injection: Inject `DatabaseInterface` into registry constructor
- Lifecycle management: `initialize()` and `dispose()` methods for proper cleanup
- Service locator integration: Register as singleton for application-wide access

### Interface Segregation Pattern
- Domain-specific interfaces: `ContactRepository`, `InteractionRepository`, `ActivityRepository`
- Base repository interface: `RepositoryInterface<T, ID>` with generic CRUD operations
- Interface inheritance: Domain repositories extend base repository interface
- Implementation separation: `SqliteContactRepository implements ContactRepository`
- Package imports only: `package:monica_companion/db/interfaces/contact_repository.dart`

## Dependency Injection Patterns

### Module-Based Registration
- Module pattern: `DatabaseModule` for database-related services
- Async initialization: `await DatabaseModule.initialize()` in app startup
- Proper disposal: `DatabaseModule.dispose()` for cleanup
- Service registration order: Database service first, then dependent services

### Service Locator Usage
- Private constructor pattern: `ServiceLocator._()` with static instance getter
- Type-safe registration: Generic types `<T extends Object>` for compile-time safety
- Exception on missing service: Throw detailed exception when service not found
- Debug logging: Log all registration and resolution operations

## Linting Rules Enforcement

### Required Rules
- `require_trailing_commas` - all function calls and collections
- `prefer_single_quotes` - use single quotes for strings
- `prefer_const_constructors` - const constructors when possible
- `avoid_print` - use `Logger` class instead
- `always_use_package_imports` - no relative imports
- `avoid_dynamic_calls` - explicit typing required

## Android Build Configuration

### Java Version Requirements
- Use Java 17 for Android builds to avoid obsolete version warnings
- Update `compileOptions` and `kotlinOptions` to `JavaVersion.VERSION_17`
- Ensure Android SDK tools support Java 17

### Build Flavor Strategy
- Simplify Android build flavors during development - add complexity incrementally
- Ensure flutter run works before adding complex flavor configurations
- APK location consistency more important than multiple build variants in early stages
- Remove complex `productFlavors` and `applicationIdSuffix` that prevent basic app functionality

### Build System Priorities
- Prioritize working `flutter run` over advanced build configurations
- Gradle build success more important than flavor complexity during development phase
- Add build variants incrementally as app functionality stabilizes