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
- Order: dart, flutter, packages, local
- Use `always_use_package_imports` linter rule

## Project Structure Patterns

### Feature-First Architecture
- Feature modules in `lib/features/` directory
- Each feature has `domain`, `data`, `presentation` layers ready
- Core utilities in `lib/core/` directory
- Services in `lib/services/` with interfaces and implementations

### Directory Structure
- Mirror test structure: `test/` mirrors `lib/`
- Interfaces in dedicated `interfaces/` subdirectories
- Models in dedicated `models/` subdirectories
- Widgets in dedicated `widgets/` subdirectories

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
- Base class: `FeatureState extends Equatable`
- Standard states: `InitialState`, `LoadingState`, `SuccessState<T>`, `ErrorState`, `EmptyState`
- All states implement `props` getter for `Equatable`
- Use typed generic: `SuccessState<T>` with data parameter

### Service Locator Pattern
- Singleton registration: `ServiceLocator.instance.registerSingleton<T>(service)`
- Factory registration: `ServiceLocator.instance.registerFactory<T>(() => factory)`
- Service resolution: `ServiceLocator.instance.get<T>()`
- Clear services in tests: `ServiceLocator.instance.clear()`

## Error Handling Patterns

### Exception Hierarchy
- Base: `abstract class AppException implements Exception`
- Specific types: `NetworkException`, `DatabaseException`, `AuthenticationException`
- Always provide message: `const NetworkException(super.message, [super.code])`
- Optional error codes: `[this.code]` parameter

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
- Use `group()` for logical test grouping: `group('Validators', () {})`
- Descriptive test names: `'should return true for valid email addresses'`
- Test both positive and negative cases
- Use clear matchers: `expect(result, isTrue)`

### Mock Patterns
- Use `mocktail` for mocking: `class MockApiService extends Mock implements ApiService`
- Create mock responses: `MockApiResponse<T>` with `statusCode` and `data`
- Register fallback values: `registerFallbackValue()` in test setup
- Centralized mocks: `/test/mocks/mock_services.dart`

## Linting Rules Enforcement

### Required Rules
- `require_trailing_commas` - all function calls and collections
- `prefer_single_quotes` - use single quotes for strings
- `prefer_const_constructors` - const constructors when possible
- `avoid_print` - use `Logger` class instead
- `always_use_package_imports` - no relative imports
- `avoid_dynamic_calls` - explicit typing required