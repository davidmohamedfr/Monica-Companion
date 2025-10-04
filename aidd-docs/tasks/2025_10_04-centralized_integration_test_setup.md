# Instruction: Migrate All Integration Tests to Use Centralized Setup

## Feature

- **Summary**: Standardize integration test setup by removing redundant code, documenting patterns, and ensuring consistent initialization across all test files
- **Stack**: `Flutter 3.x`, `Dart 3.x`, `integration_test`, `permission_handler`

## Existing files

- @integration_test/app_test.dart
- @integration_test/contacts_integration_test.dart
- @integration_test/database_integration_test.dart
- @integration_test/contacts_simple_test.dart
- @integration_test/helpers/integration_test_helpers.dart
- @lib/core/services/app_initialization_service.dart

### New file to create

None

## Implementation phases

### Phase 1: Analyze Current Setup Patterns

> Identify which tests need AppInitializationService and which don't

1. Review app_test.dart and database_integration_test.dart to understand why they call AppInitializationService
2. Review contacts_integration_test.dart and contacts_simple_test.dart to understand why they don't
3. Identify pattern: tests using app.main() vs tests using pumpWidget(MonicaApp())
4. Document finding: app.main() already initializes app, pumpWidget requires manual initialization

### Phase 2: Centralize Optional Initialization Helper

> Add optional app initialization to helper for tests that need it

1. Add setupWithPermissionsAndApp() method to IntegrationTestHelpers
2. Method should call setupWithPermissions() then conditionally initialize AppInitializationService
3. Keep existing setupWithPermissions() for tests that call app.main()
4. Document when to use each helper method with clear inline comments

### Phase 3: Standardize Test Files

> Apply consistent setup pattern based on test type

1. Update app_test.dart: use setupWithPermissions() only (app.main() handles initialization)
2. Update contacts_integration_test.dart: use setupWithPermissions() only (app.main() handles initialization)
3. Update contacts_simple_test.dart: use setupWithPermissions() only (app.main() handles initialization)
4. Update database_integration_test.dart: use setupWithPermissionsAndApp() (pumpWidget requires manual initialization)
5. Add documentation comments to each setUpAll() block explaining the setup choice

### Phase 4: Clean Up Redundant Code

> Remove duplicate initialization and add clear documentation

1. Remove redundant AppInitializationService.instance.initialize() from app_test.dart
2. Verify database_integration_test.dart uses centralized helper instead of inline initialization
3. Remove any commented-out permission handling code
4. Add consistent header comments to all test files documenting setup requirements

### Phase 5: Verification and Documentation

> Ensure all tests pass and create documentation template

1. Run all integration tests individually to verify they pass
2. Run all integration tests together to verify no conflicts
3. Add usage documentation to IntegrationTestHelpers class docstring
4. Create inline examples showing both setup patterns
5. Verify tearDown/tearDownAll patterns are consistent across all tests

## Reviewed implementation

- [ ] Phase 1
- [ ] Phase 2
- [ ] Phase 3
- [ ] Phase 4
- [ ] Phase 5

## Validation flow

1. Run integration_test/app_test.dart and verify it passes
2. Run integration_test/contacts_integration_test.dart and verify it passes
3. Run integration_test/contacts_simple_test.dart and verify it passes
4. Run integration_test/database_integration_test.dart and verify it passes
5. Run all integration tests together and verify no initialization conflicts
6. Review helper documentation and confirm setup patterns are clear
7. Verify no redundant code remains in any test file

## Estimations

- Confidence: 9/10 - Clear pattern identified, straightforward refactoring with existing working code
- Time to implement: 30-45 minutes
