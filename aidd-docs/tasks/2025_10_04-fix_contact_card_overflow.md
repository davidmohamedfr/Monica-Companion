# Instruction: Fix Contact Card UI Overflow

## Feature

- **Summary**: Fix RenderFlex overflow errors (91-183px) in ContactCardItem by simplifying vertical content and applying proper text constraints
- **Stack**: `Flutter 3.35.0`, `Dart 3.8.0`, `flutter_test`, `integration_test`

## Existing files

- lib/features/contacts/widgets/contact_card_item.dart
- lib/features/contacts/widgets/contact_grid_item.dart
- lib/features/contacts/widgets/contact_list_item.dart
- integration_test/contacts_integration_test.dart
- integration_test/contacts_simple_test.dart

### New file to create

None required

## Implementation phases

### Phase 1: Refactor ContactCardItem layout

> Simplify vertical content to prevent overflow

1. Reduce avatar radius from 28 to 20 (40px diameter)
2. Remove nested Column in _buildContactDetails method
3. Show only name + ONE contact method (phone OR email, prioritize phone)
4. Apply maxLines: 1 and overflow: TextOverflow.ellipsis to name text
5. Apply maxLines: 1 and overflow: TextOverflow.ellipsis to contact method text
6. Remove lastContactedAt display from card view
7. Remove needsInteractionSoon chip from card view
8. Keep favorite icon indicator in name row
9. Reduce padding if needed to fit 49px height constraint

### Phase 2: Verify other contact widgets

> Ensure grid and list views maintain proper constraints

1. Verify ContactListItem already uses maxLines and ellipsis (currently correct)
2. Verify ContactGridItem uses maxLines and ellipsis (currently correct)
3. No changes needed if constraints are already applied

### Phase 3: Run and fix integration tests

> Validate fixes with real contact data

1. Import contacts using contacts_with_photos_80.vcf to device
2. Run integration tests: make test-integration
3. Verify contacts_integration_test.dart passes (2 tests)
4. Verify contacts_simple_test.dart passes (1 test)
5. Check for any remaining overflow errors
6. Fix any edge cases discovered during testing

## Reviewed implementation

- [ ] Phase 1
- [ ] Phase 2
- [ ] Phase 3

## Validation flow

1. Import contacts_with_photos_80.vcf to test device
2. Launch app and navigate to contacts screen
3. Switch to card view mode
4. Scroll through contacts and verify no overflow errors
5. Test with contacts having long names (>30 characters)
6. Test with contacts having both phone and email
7. Test with contacts having only phone or only email
8. Verify name truncates with ellipsis when too long
9. Verify contact method truncates with ellipsis when too long
10. Run full integration test suite and verify all pass

## Estimations

- Confidence: 10/10
  - ✅ Root cause clearly identified (excessive vertical content in ContactCardItem)
  - ✅ Solution is straightforward (simplify content, add text constraints)
  - ✅ Other widgets (list/grid) already implement correct patterns
  - ✅ Clear test validation path with existing integration tests
  - ✅ No new dependencies or complex refactoring required
- Time to implement: 15-30 minutes
  - Simple refactoring of single widget
  - Test execution and validation
