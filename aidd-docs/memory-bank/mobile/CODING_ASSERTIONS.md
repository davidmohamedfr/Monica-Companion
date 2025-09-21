# Coding Guidelines

> Those rules must be minimal because the MUST be checked after EVERY CODE GENERATION.

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

## Code Style Rules

### File Naming
- Use `snake_case` for file names: `user_repository.dart`
- Use `PascalCase` for class names: `UserRepository`
- Private constructors use named constructor: `Logger._()`

### Type Safety
- **ALWAYS** specify explicit types: `final String message = 'error';`
- Use strict analyzer settings with `strict-casts: true`
- No implicit casts or dynamic types allowed
- Constructor parameters must specify types: `const AppException(this.message, [this.code]);`

### Error Handling
- Use custom exception hierarchy extending `AppException`
- Separate `Exception` classes for throwing and `Failure` classes for clean architecture
- Always provide error codes: `const NetworkException('Connection failed', 'NET_001')`
- Implement `Equatable` for failure classes with `props` getter

### Widget Development
- All widgets must have `super.key` parameter: `const AppErrorWidget({super.key})`
- Use `const` constructors wherever possible
- Extract theme access: `final ThemeData theme = Theme.of(context);`
- Use spread operator for conditional widgets: `if (onRetry != null) ...<Widget>[]`

### Code Organization
- Utility classes must be private constructor: `Validators._()`
- Static methods for utilities: `static bool isValidEmail(String email)`
- Group related functionality in single files
- Use absolute imports: `package:monica_mobile_app/core/config/app_config.dart`

### Documentation
- Use `///` for public API documentation
- Document class purpose at the top
- Use descriptive variable names without redundant comments

### Testing Standards
- Group tests logically: `group('Validators', () {})`
- Descriptive test names: `'should return true for valid email addresses'`
- Use `expect()` with clear matchers: `expect(result, isTrue)`
- Test both positive and negative cases

### Linting Rules
- Enforce trailing commas: `require_trailing_commas`
- Single quotes for strings: `prefer_single_quotes`
- Expression function bodies: `prefer_expression_function_bodies`
- Const constructors: `prefer_const_constructors`
- No print statements: `avoid_print` - use Logger instead

### Imports
- Always use package imports, never relative: `avoid_relative_lib_imports`
- Order imports: dart, flutter, packages, local
- Exclude generated files from analysis: `**/*.g.dart`, `**/*.freezed.dart`

### Flutter-Specific
- Use `useMaterial3: true` for Material 3 design
- Access theme via `Theme.of(context)` not direct colors
- Use `FilledButton.icon()` for modern button styles
- Extract build methods for complex widgets: `Widget _buildConfigItem()`