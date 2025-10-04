# Instruction: Contact Details - Extend Contact model with notes field

## Feature

- **Summary**: Add optional `notes` field to Contact model to support storing additional information about contacts for display in contact detail screen
- **Stack**: `Dart 3.9.2`, `Equatable 2.0.5`, `flutter_test`

## Existing files

- @lib/features/contacts/models/contact_model.dart
- @lib/features/contacts/services/contacts_service.dart
- @test/features/contacts/models/contact_model_test.dart

### New file to create

None

## Implementation phases

### Phase 1: Update Contact Model

> Add notes field with proper null safety

1. Add `String? notes` field to Contact class constructor
2. Add `notes` to final field declarations
3. Update `copyWith` method to include `notes` parameter
4. Update `props` getter to include `notes` in equality comparison

### Phase 2: Update ContactsService

> Handle notes field when converting device contacts

1. Add `notes` parameter to Contact instantiation in `getDeviceContacts` method
2. Set notes to `null` for device contacts (no notes source yet)

### Phase 3: Add Unit Tests

> Ensure notes field behavior is properly tested

1. Add test for Contact creation with notes field
2. Add test for Contact creation without notes field (null)
3. Add test for copyWith with notes parameter
4. Add test for equality comparison with different notes values
5. Update props list length assertion from 8 to 9

## Reviewed implementation

- [ ] Phase 1: Update Contact Model
- [ ] Phase 2: Update ContactsService
- [ ] Phase 3: Add Unit Tests

## Validation flow

1. Run unit tests: `flutter test test/features/contacts/models/contact_model_test.dart`
2. Verify all existing tests pass
3. Run full test suite: `flutter test`
4. Verify no compilation errors: `flutter analyze`

## Estimations

- **Confidence**: 10/10 - Straightforward model extension, existing tests provide clear guidance
- **Time to implement**: 15 minutes
- **Risks**: None - simple field addition with comprehensive test coverage
