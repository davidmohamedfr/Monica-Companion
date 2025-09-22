# Testing Guidelines

This document outlines the testing strategies and guidelines for the Monica Mobile App Flutter project.

## Test Coverage

- Coverage enabled with `--coverage` flag
- Reports generated in `coverage/lcov.info`
- Threshold validation via lefthook hooks
- Target: 60% minimum coverage (enforced in CI)

## Tools and Frameworks

- `flutter_test` - SDK testing framework
- `integration_test` - SDK integration testing
- `mocktail` - Mocking library
- `flutter_lints` - Code quality analysis
- `lefthook` - Git hooks for automated testing
- **Android Emulator**: API level 30 for integration tests in CI

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
- **Push workflow**: Runs unit tests, linting, and coverage (@.github/workflows/push.yml)
- **PR workflow**: Runs integration tests with Android emulator (@.github/workflows/PR.yml)
- **Caching**: Flutter SDK, dependencies, and analysis cache optimized
- **Parallel execution**: Tests run in separate jobs for faster feedback

## Test Architecture

- `test/` - Unit and widget tests
- `test/core/` - Core functionality tests (`validators_test.dart`, `logger_test.dart`)
- `test/config/` - Configuration tests (`environment_test.dart`)
- `test/helpers/` - Test utilities and common functions (`test_helpers.dart`)
- `test/mocks/` - Mock services and interfaces (`mock_services.dart`)
- `integration_test/` - Integration tests (`app_test.dart`)
- `integration_test/helpers/` - Integration test utilities

## Mocking and Stubbing

### Mock Services
- `MockDatabaseInterface` - Database operations
- `MockApiService` - API interactions
- `MockStorageService` - Local storage
- `MockApiResponse<T>` - Structured API responses

### Test Helpers
- `TestHelpers.setupMockFallbacks()` - Configure mocktail defaults
- `TestHelpers.createMockDateTime()` - Consistent test dates
- `TestHelpers.pumpAndSettle()` - Widget test animations
- `TestHelpers.expectThrows<T>()` - Exception testing
- `TestHelpers.createTestEntityMap()` - Test data generation

### Integration Test Helpers
- `IntegrationTestHelpers.setupIntegrationTest()` - Test binding setup
- `IntegrationTestHelpers.waitForAppToLoad()` - App initialization wait
- `IntegrationTestHelpers.takeScreenshot()` - Test documentation

## Test Patterns

- Mock services implement actual interfaces
- Test helpers provide reusable utilities
- Integration tests verify real app behavior
- Coverage reports ensure comprehensive testing
- Conventional commit format enforced for test commits