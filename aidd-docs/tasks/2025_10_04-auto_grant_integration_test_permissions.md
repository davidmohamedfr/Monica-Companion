# Instruction: Auto-grant Permissions for Integration Tests

## Feature

- **Summary**: Configure Android integration tests to automatically grant READ_CONTACTS permission without user prompts, ensuring tests run smoothly in CI/CD and local environments
- **Stack**: `Flutter 3.35.0`, `Dart 3.8.0`, `Android Gradle Plugin`, `ADB`, `integration_test package`

## Existing files

- @android/app/src/debug/AndroidManifest.xml
- @android/app/src/main/AndroidManifest.xml
- @android/app/build.gradle
- @integration_test/contacts_integration_test.dart
- @integration_test/app_test.dart
- @integration_test/database_integration_test.dart

### New file to create

- integration_test_driver.dart - Driver file to execute ADB commands before tests run

## Implementation phases

### Phase 1: Configure Debug Manifest

> Add READ_CONTACTS permission to debug build variant manifest

1. Update android/app/src/debug/AndroidManifest.xml with READ_CONTACTS permission
2. Verify permission merges correctly with main manifest during debug builds

### Phase 2: Create Integration Test Driver

> Set up test driver to grant permissions via ADB before running tests

1. Create test_driver/integration_test_driver.dart with ADB permission granting logic
2. Add Process.run() calls to execute "adb shell pm grant" for READ_CONTACTS
3. Extract package name from environment or hardcode as fallback
4. Handle errors gracefully with clear error messages

### Phase 3: Update Test Execution Flow

> Ensure integration tests use driver for permission setup

1. Verify integration tests can be run with driver using flutter drive command
2. Document new test execution command in TESTING_STRATEGY.md
3. Update CI configuration if flutter drive is needed instead of flutter test

### Phase 4: Add Fail-Fast Validation

> Verify permissions are granted before tests proceed

1. Add permission check in integration_test/helpers/integration_test_helpers.dart
2. Create setupWithPermissions() helper that verifies READ_CONTACTS is granted
3. Throw descriptive exception if permissions not available
4. Document usage pattern for test files

## Reviewed implementation

- [x] Phase 1 - Debug manifest configured
- [x] Phase 2 - Integration test script enhanced with permission monitor
- [x] Phase 3 - Documentation updated, Makefile configured
- [x] Phase 4 - Permission validation helpers added

## Validation flow

1. Run flutter clean and flutter pub get
2. Connect Android device or start emulator
3. Execute integration tests: `make test-integration` or `./scripts/run_integration_tests.sh`
4. Verify no permission dialogs appear during test execution
5. Confirm tests access device contacts successfully
6. Verify permission monitor grants permissions every 2 seconds
7. Check tests complete successfully without manual intervention
8. Run in CI pipeline (.github/workflows/PR.yml already configured)

## CI Integration

CI workflow already configured in `.github/workflows/PR.yml`:
- Line 173-174: Uses the integration test script
- Runs on Android emulator (API level 30)
- Automatic permission granting via background monitor
- No changes needed - works out of the box!

## Estimations

- **Confidence**: 10/10 ✅ **VALIDATED**
  - ✅ Permission monitor approach successfully tested locally
  - ✅ `make test-integration` works without permission prompts
  - ✅ CI already configured and ready to use
  - ✅ Script handles multiple devices and test targets
  - ✅ Background monitor ensures permissions always granted
  - ✅ Clean implementation with proper error handling

- **Actual time**: ~2 hours
  - 20 min: Update debug manifest
  - 45 min: Enhanced integration test script with monitor
  - 15 min: Test locally and validate
  - 20 min: Update documentation and Makefile
  - 20 min: Add permission validation helpers
