# Instruction: Contact Details - Add exclusion button (disabled placeholder)

## Feature

- **Summary**: Add disabled "Add to exclusion list" button to contact detail screen as UI placeholder for future functionality (blocked by #65)
- **Stack**: `Flutter 3.35.3`, `Dart 3.9.2`, `Material Design 3`, `flutter_test`

## Existing files

- @lib/features/contacts/screens/contact_detail_screen.dart

### New file to create

None - will modify existing ContactDetailScreen

## Implementation phases

### Phase 1: Add Disabled Exclusion Button to App Bar

> Add IconButton with disabled state to app bar actions

1. Add IconButton with Icons.block to app bar actions
2. Set onPressed to null for disabled state
3. Add tooltip: "Coming soon - Add to exclusion list"
4. Position after edit button in actions list
5. Ensure Material Design 3 disabled styling (grayed out)

### Phase 2: Add Tap Handler for Disabled State Feedback

> Show snackbar when user taps disabled button

1. Wrap IconButton with GestureDetector or InkWell
2. Add onTap handler that shows snackbar
3. Snackbar message: "Feature coming soon - see issue #65"
4. Ensure accessible (screen reader support)

### Phase 3: Add Widget Tests

> Test button appearance and behavior

1. Test button appears in app bar
2. Test button is visually disabled
3. Test tooltip text is correct
4. Test tapping shows snackbar message
5. Test button positioned after edit button

## Reviewed implementation

- [ ] Phase 1: Add Disabled Exclusion Button to App Bar
- [ ] Phase 2: Add Tap Handler for Disabled State Feedback
- [ ] Phase 3: Add Widget Tests

## Validation flow

1. Run app: `flutter run`
2. Navigate to contact detail screen
3. Verify: Exclusion button appears in app bar (grayed out)
4. Verify: Button positioned after edit button
5. Hover over button (or long-press on mobile)
6. Verify: Tooltip shows "Coming soon - Add to exclusion list"
7. Tap the disabled button
8. Verify: Snackbar appears with "Feature coming soon - see issue #65"
9. Verify: Button remains disabled (no action triggered)
10. Run tests: `flutter test test/features/contacts/screens/contact_detail_screen_test.dart`

## Estimations

- **Confidence**: 10/10 - Simple UI placeholder with disabled state
- **Time to implement**: 10 minutes
- **Risks**: None - straightforward disabled button with tooltip and snackbar feedback
