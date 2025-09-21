# Instruction: Fix All Linting Issues in Codebase

## Feature

- **Summary**: Fix all 77 linting violations to ensure CI analyze step passes and improve code quality
- **Stack**: `Flutter 3.35.3, Dart, flutter_lints 6.0.0`

## Existing files

- @integration_test/app_test.dart
- @integration_test/helpers/integration_test_helpers.dart
- @lib/config/feature_flags.dart
- @lib/core/config/app_config.dart
- @lib/core/config/environment.dart
- @lib/core/errors/exceptions.dart
- @lib/core/errors/failures.dart
- @lib/core/utils/logger.dart
- @lib/core/utils/validators.dart
- @lib/db/database_config.dart
- @lib/db/interfaces/database_interface.dart
- @lib/db/models/base_model.dart
- @lib/db/repositories/base_repository.dart
- @lib/features/shared/models/feature_state.dart
- @lib/features/shared/utils/feature_utils.dart
- @lib/features/shared/widgets/empty_state_widget.dart
- @lib/features/shared/widgets/error_widget.dart
- @lib/features/shared/widgets/loading_widget.dart
- @lib/main.dart
- @lib/services/implementations/base_service_impl.dart
- @lib/services/interfaces/api_service.dart
- @lib/services/interfaces/storage_service.dart
- @lib/services/service_locator.dart
- @test/config/environment_test.dart
- @test/helpers/test_helpers.dart

### New file to create

- None

## Implementation phases

### Phase 1: Fix trailing comma violations

> Add required trailing commas in multi-line function calls and declarations

1. Add trailing commas in integration_test/app_test.dart line 43
2. Add trailing commas in lib/config/feature_flags.dart line 79
3. Add trailing commas in lib/core/utils/logger.dart lines 11, 44
4. Add trailing commas in lib/db/database_config.dart line 44
5. Add trailing commas in lib/db/interfaces/database_interface.dart line 17
6. Add trailing commas in lib/services/implementations/base_service_impl.dart lines 15, 25, 43
7. Add trailing commas in test/helpers/test_helpers.dart line 31

### Phase 2: Fix type annotation violations

> Add explicit type annotations where missing

1. Add type annotations in lib/config/feature_flags.dart line 98
2. Add type annotations in lib/core/errors/failures.dart lines 11, 32
3. Add type annotations in lib/db/models/base_model.dart line 32
4. Add type annotations in lib/db/repositories/base_repository.dart lines 64, 78, 105, 145
5. Add type annotations in lib/features/shared/models/feature_state.dart lines 8, 23, 34, 46, 56
6. Add type annotations in lib/main.dart lines 40, 60, 73, 93
7. Add type annotations in test/config/environment_test.dart line 37

### Phase 3: Fix function body style violations

> Convert block function bodies to expression bodies where appropriate

1. Convert to expression body in lib/config/feature_flags.dart line 68
2. Convert to expression body in lib/core/utils/validators.dart lines 30, 35
3. Convert to expression body in lib/db/database_config.dart line 50
4. Convert to expression body in lib/features/shared/widgets/loading_widget.dart line 49
5. Convert to expression body in lib/main.dart lines 14, 30, 68, 89
6. Convert to expression body in lib/services/service_locator.dart line 43
7. Convert to expression body in test/helpers/test_helpers.dart line 25

### Phase 4: Fix environment usage violations

> Remove or replace invalid environment declaration usages

1. Fix environment usage in lib/config/feature_flags.dart lines 69, 78
2. Fix environment usage in lib/core/config/app_config.dart line 15
3. Fix environment usage in lib/core/config/environment.dart lines 14, 42, 47, 52
4. Document proper environment handling approach

### Phase 5: Fix numeric literal violations

> Replace unnecessary double literals with int literals

1. Fix double literals in integration_test/helpers/integration_test_helpers.dart line 53
2. Fix double literals in lib/features/shared/widgets/empty_state_widget.dart line 24
3. Fix double literals in lib/features/shared/widgets/error_widget.dart line 22
4. Fix double literals in lib/features/shared/widgets/loading_widget.dart lines 26, 51, 54
5. Fix double literals in lib/main.dart lines 37, 70, 91

### Phase 6: Fix code organization violations

> Sort imports, move constructors, fix other organization issues

1. Sort directives in lib/core/config/app_config.dart line 2
2. Sort directives in lib/main.dart line 4
3. Sort directives in test/config/environment_test.dart lines 3-4
4. Move constructors in lib/core/errors/exceptions.dart line 44
5. Move constructors in lib/core/errors/failures.dart line 25
6. Fix cascade invocations in integration_test/helpers/integration_test_helpers.dart line 16
7. Fix cascade invocations in lib/db/repositories/base_repository.dart line 22

### Phase 7: Fix remaining violations

> Address miscellaneous style issues

1. Remove redundant argument values in lib/config/feature_flags.dart lines 69, 79
2. Fix line length in lib/db/database_config.dart line 46
3. Fix line length in lib/features/shared/utils/feature_utils.dart lines 62, 64
4. Fix control body placement in lib/db/repositories/base_repository.dart lines 88, 107
5. Fix unnecessary lambdas in lib/db/repositories/base_repository.dart line 121
6. Fix catch clause in lib/core/utils/validators.dart line 18
7. Remove unnecessary dynamic annotations in lib/main.dart line 89
8. Remove unnecessary dynamic annotations in lib/services/interfaces/api_service.dart lines 39, 46, 59
9. Fix boolean parameter in lib/services/interfaces/storage_service.dart line 18

## Reviewed implementation

- [ ] Phase 1
- [ ] Phase 2
- [ ] Phase 3
- [ ] Phase 4
- [ ] Phase 5
- [ ] Phase 6
- [ ] Phase 7

## Validation flow

1. Run `dart format --output=none --set-exit-if-changed .` locally
2. Run `dart analyze --fatal-infos --fatal-warnings` locally
3. Verify no linting issues remain
4. Run tests to ensure functionality preserved
5. Push to feature branch
6. Verify CI analyze step passes
7. Merge to main branch

## Estimations

- Confidence: 10/10 - Clear linting issues with straightforward fixes
- Time to implement: 45-60 minutes