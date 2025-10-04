# Instruction: Common Test Setup with Permission Verification

## Feature

- **Summary**: Add shared permission verification setup for integration tests to fail fast when contact permissions are missing
- **Stack**: `Flutter 3.35.0`, `Dart 3.8.0`, `permission_handler 11.3.1`, `integration_test (SDK)`

## Existing files

- @integration_test/helpers/integration_test_helpers.dart
- @integration_test/app_test.dart

### New file to create

- None (all required files exist from #75)

## Implementation phases

### Phase 1: Verify existing implementation

> Confirm #75 implementation meets all requirements

1. Review `setupWithPermissions()` in integration_test_helpers.dart
2. Verify it checks contact permissions only
3. Verify it throws clear exception with descriptive message on missing permissions
4. Verify it stops test execution on failure
5. Confirm reusability across test files

### Phase 2: Update integration tests to use permission verification

> Apply shared setup to existing integration tests

1. Update integration_test/app_test.dart to call setupWithPermissions() in setUpAll
2. Verify existing integration tests still pass
3. Document usage pattern in code comments

### Phase 3: Validate fail-fast behavior

> Test that permission verification works as expected

1. Run integration test without permissions granted
2. Verify test fails immediately with clear error message
3. Grant permissions and verify test passes
4. Confirm error message includes instructions to fix

## Reviewed implementation

- [ ] Phase 1
- [ ] Phase 2
- [ ] Phase 3

## Validation flow

1. Developer writes new integration test
2. Developer adds setupWithPermissions() to setUpAll
3. Developer runs test without granting permissions
4. Test fails immediately with clear error showing how to grant permissions
5. Developer grants permissions via test driver or ADB
6. Test runs successfully

## Estimations

- Confidence: 10/10 - Implementation already exists from #75, only need to verify and apply
- Time to implement: 15 minutes - Primarily verification and documentation
