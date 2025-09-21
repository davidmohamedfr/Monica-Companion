# AGENTS.md

## Build/Lint/Test Commands
- **Format**: `make format` or `dart format .`
- **Analyze**: `make analyze` or `dart analyze --fatal-warnings`
- **Test all**: `make test` or `flutter test`
- **Test single file**: `flutter test test/path/to/file_test.dart`
- **Build debug**: `make build-debug` or `flutter build apk --debug`

## Code Style Guidelines

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Functions/Variables: `camelCase`
- Constants: `camelCase` or `UPPER_CASE`

### Type Safety & Formatting
- **Always specify types**: `final String name = 'value';`
- **Strict mode**: `strict-casts: true`, `implicit-dynamic: false`
- **Single quotes**: `prefer_single_quotes`
- **Trailing commas**: `require_trailing_commas`
- **Expression bodies**: `prefer_expression_function_bodies`

### Imports & Organization
- **Package imports only**: `avoid_relative_lib_imports`
- **Import order**: dart → flutter → packages → local
- **Exclude generated**: `**/*.g.dart`, `**/*.freezed.dart`

### Error Handling
- **Exceptions**: Extend `AppException` with error codes
- **Failures**: Use `Failure` classes for clean architecture
- **No print**: Use `Logger` instead of `print()`

### Flutter Specific
- **Material 3**: `useMaterial3: true`
- **Const constructors**: `prefer_const_constructors`
- **Widget keys**: All widgets must have `super.key` parameter