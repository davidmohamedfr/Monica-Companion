# Testing Guidelines

This document outlines the testing strategies and guidelines for the Monica Mobile App Flutter project.

## Test Coverage

- Target: 60% minimum coverage (enforced in CI)
- Coverage reports: Generated via `flutter test --coverage`
- CI uploads coverage artifacts for review

## Tools and Frameworks

- **flutter_test**: Flutter's built-in testing framework for unit and widget tests
- **integration_test**: Flutter's integration testing package for end-to-end tests
- **mocktail**: Modern mocking framework for Dart
- **Android Emulator**: API level 30 for integration tests in CI

## Testing Strategy

- **Test-driven approach**: Tests run on every push and PR
- **Automated CI/CD**: Full test suite execution in GitHub Actions
- **Types of tests implemented:**
  - **Unit Tests**: Core utilities, validators, services
  - **Widget Tests**: UI components and app startup
  - **Integration Tests**: Full app workflows with Android emulator
  - **Mocking**: Services and external dependencies

## Test Execution Process

### Local Development
```bash
# Run unit tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Run specific test file
flutter test test/core/utils/validators_test.dart
```

### CI/CD Pipeline
- **Push workflow**: Runs unit tests, linting, and coverage (@.github/workflows/push.yml)
- **PR workflow**: Runs integration tests with Android emulator (@.github/workflows/PR.yml)
- **Caching**: Flutter SDK, dependencies, and analysis cache optimized
- **Parallel execution**: Tests run in separate jobs for faster feedback

## Test Structure

```
test/
├── @test/widget_test.dart                 # Main app widget tests
├── @test/core/utils/validators_test.dart  # Utility function tests
├── @test/core/utils/logger_test.dart      # Logger functionality tests
├── @test/config/environment_test.dart     # Environment config tests
├── @test/helpers/test_helpers.dart        # Common test utilities
├── @test/mocks/mock_services.dart         # Mock implementations
└── @test/db/                              # Database layer tests

integration_test/
├── @integration_test/app_test.dart        # End-to-end app tests
├── @integration_test/helpers/             # Integration test utilities
└── @integration_test/tests/               # Additional integration tests
```

## Mocking and Stubbing

- **mocktail framework**: Used for creating mocks of services and interfaces
- **Mock services**: @test/mocks/mock_services.dart contains MockApiService, MockDatabaseInterface, MockStorageService
- **Fallback registration**: @test/helpers/test_helpers.dart handles mocktail setup
- **Test data generation**: Helper methods for consistent test entity creation
- **Mock responses**: Structured MockApiResponse class for API testing

## Key Testing Patterns

- **Group-based organization**: Tests grouped by functionality
- **Mock setup helpers**: Centralized mock configuration in TestHelpers
- **Widget testing**: WidgetTester utilities for UI component testing
- **Integration screenshots**: Automated screenshot capture during integration tests
- **Async testing**: Proper pump and settle handling for async operations