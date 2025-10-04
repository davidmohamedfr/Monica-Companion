# TDD Plan: Fix Contact Card UI Overflow

## Overview

Fix RenderFlex overflow errors in ContactCardItem widget using Test-Driven Development approach. Follow Kent Beck's TDD cycle: Red → Green → Refactor.

## Test Implementation Order

### Test 1: Contact card should respect height constraints ❌ RED

**File**: `test/features/contacts/widgets/contact_card_item_test.dart`

**Test name**: `should respect maximum height constraints when rendering`

**Purpose**: Verify widget fits within 49px height constraint

**Implementation**:
- Wrap ContactCardItem in ConstrainedBox with maxHeight: 49
- Pump widget and verify no overflow errors
- Use expectLater with RendersWithoutOverflow matcher

**Expected behavior**: Widget should render without RenderFlex overflow errors

---

### Test 2: Avatar should be 40x40 pixels ❌ RED

**File**: `test/features/contacts/widgets/contact_card_item_test.dart`

**Test name**: `should display avatar with 40px diameter`

**Purpose**: Verify avatar radius is 20 (40px diameter)

**Implementation**:
- Render ContactCardItem with test contact
- Find CircleAvatar widget
- Assert radius equals 20

**Expected behavior**: Avatar radius should be 20

---

### Test 3: Name should use single line with ellipsis ❌ RED

**File**: `test/features/contacts/widgets/contact_card_item_test.dart`

**Test name**: `should display name with single line and ellipsis overflow`

**Purpose**: Verify name text is constrained to prevent overflow

**Implementation**:
- Create contact with very long name (>50 characters)
- Render ContactCardItem
- Find name Text widget
- Assert maxLines equals 1
- Assert overflow equals TextOverflow.ellipsis

**Expected behavior**: Name text should have maxLines: 1 and overflow: ellipsis

---

### Test 4: Should show only ONE contact method ❌ RED

**File**: `test/features/contacts/widgets/contact_card_item_test.dart`

**Test name**: `should display only one contact method prioritizing phone`

**Purpose**: Verify only phone OR email is shown, not both

**Implementation**:
- Create contact with both phone and email
- Render ContactCardItem
- Find phone icon and text
- Assert phone is displayed
- Assert email is NOT displayed

**Expected behavior**: Only phone should be visible when both exist

---

### Test 5: Contact method should use single line with ellipsis ❌ RED

**File**: `test/features/contacts/widgets/contact_card_item_test.dart`

**Test name**: `should display contact method with single line and ellipsis overflow`

**Purpose**: Verify contact method text is constrained

**Implementation**:
- Create contact with very long phone number
- Render ContactCardItem
- Find contact method Text widget
- Assert maxLines equals 1
- Assert overflow equals TextOverflow.ellipsis

**Expected behavior**: Contact method text should have maxLines: 1 and overflow: ellipsis

---

### Test 6: Should NOT display lastContactedAt ❌ RED

**File**: `test/features/contacts/widgets/contact_card_item_test.dart`

**Test name**: `should not display last contacted date in card view`

**Purpose**: Verify lastContactedAt is removed to save space

**Implementation**:
- Create contact with lastContactedAt date
- Render ContactCardItem
- Search for 'Last contact' text
- Assert not found

**Expected behavior**: Last contacted date should not be visible

---

### Test 7: Should NOT display interaction chip ❌ RED

**File**: `test/features/contacts/widgets/contact_card_item_test.dart`

**Test name**: `should not display needs interaction chip in card view`

**Purpose**: Verify interaction chip is removed to save space

**Implementation**:
- Create contact with needsInteractionSoon: true
- Render ContactCardItem
- Search for 'Needs interaction soon' text
- Assert not found

**Expected behavior**: Interaction chip should not be visible

---

### Test 8: Should maintain favorite icon ❌ RED

**File**: `test/features/contacts/widgets/contact_card_item_test.dart`

**Test name**: `should display favorite icon for favorite contacts`

**Purpose**: Verify favorite functionality is preserved

**Implementation**:
- Create favorite contact
- Render ContactCardItem
- Find favorite Icon widget
- Assert it exists

**Expected behavior**: Favorite icon should be displayed

---

### Test 9: Should handle contact with only email ❌ RED

**File**: `test/features/contacts/widgets/contact_card_item_test.dart`

**Test name**: `should display email when phone is not available`

**Purpose**: Verify email is shown as fallback when phone is null

**Implementation**:
- Create contact with email but no phone
- Render ContactCardItem
- Assert email icon and text are displayed
- Assert phone icon is not displayed

**Expected behavior**: Email should be displayed when phone is null

---

### Test 10: Integration test validation ❌ RED

**File**: Run existing integration tests

**Test name**: `contacts_integration_test.dart` and `contacts_simple_test.dart`

**Purpose**: Verify integration tests pass with real contacts

**Implementation**:
- Run `make test-integration`
- Verify all 3 previously failing tests now pass

**Expected behavior**: All integration tests should pass without overflow errors

---

## Implementation Strategy

### Red Phase (Write Failing Tests)
1. Create `test/features/contacts/widgets/contact_card_item_test.dart`
2. Write all 9 widget tests (Tests 1-9)
3. Run tests and verify they all fail (RED)
4. Commit: `test: add failing tests for ContactCardItem overflow fix`

### Green Phase (Make Tests Pass)
1. Refactor `lib/features/contacts/widgets/contact_card_item.dart`
2. Reduce avatar radius to 20
3. Simplify _buildContactDetails to show ONE contact method
4. Add maxLines: 1 and overflow: ellipsis to all text
5. Remove lastContactedAt display
6. Remove needsInteractionSoon chip
7. Run unit tests until all pass (GREEN)
8. Commit: `fix: refactor ContactCardItem to prevent overflow`

### Refactor Phase (Improve Structure)
1. Extract contact method selection logic to separate method
2. Simplify widget structure if possible
3. Run all tests to ensure no regressions
4. Commit: `refactor: simplify ContactCardItem contact method display`

### Validation Phase (Integration Tests)
1. Import contacts_with_photos_80.vcf to test device
2. Run `make test-integration`
3. Verify all tests pass
4. Commit: `test: verify integration tests pass with refactored ContactCardItem`

---

## Test Execution Commands

```bash
# Run unit tests for ContactCardItem
flutter test test/features/contacts/widgets/contact_card_item_test.dart

# Run all unit tests
flutter test

# Run integration tests
make test-integration
```

---

## Success Criteria

- ✅ All 9 unit tests pass
- ✅ No RenderFlex overflow errors
- ✅ All 3 integration tests pass
- ✅ Widget respects 49px height constraint
- ✅ Text truncates gracefully with ellipsis
- ✅ Code follows Dart/Flutter best practices

---

## Current Status

- [x] Test 1: Height constraints
- [x] Test 2: Avatar size
- [x] Test 3: Name text constraints
- [x] Test 4: Single contact method
- [x] Test 5: Contact method text constraints
- [x] Test 6: No lastContactedAt
- [x] Test 7: No interaction chip
- [x] Test 8: Favorite icon preserved
- [x] Test 9: Email fallback
- [x] Test 10: Integration tests pass

## Implementation Complete

All tests passing. TDD cycle complete:
- RED phase: 16 widget tests written, all failing initially
- GREEN phase: ContactCardItem refactored, all tests passing
- REFACTOR phase: Code structure reviewed, no further improvements needed
- VALIDATION phase: Integration tests pass (13/13)

---

## Next Steps

1. Say "go" to start with Test 1
2. Follow TDD cycle strictly: Red → Green → Refactor
3. Commit after each phase
4. Move to next test only when current test passes
