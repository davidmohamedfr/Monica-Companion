# Instruction: Contact Details - Create contact detail screen structure

## Feature

- **Summary**: Create basic ContactDetailScreen widget with navigation from contacts list, displaying contact name in app bar with scrollable content area
- **Stack**: `Flutter 3.35.3`, `Dart 3.9.2`, `Material Design 3`, `flutter_test`

## Existing files

- @lib/features/contacts/screens/contacts_list_screen.dart (line 196-204: navigation TODO)
- @lib/features/contacts/models/contact_model.dart

### New file to create

- lib/features/contacts/screens/contact_detail_screen.dart

## Implementation phases

### Phase 1: Create ContactDetailScreen Widget

> Basic screen structure with StatefulWidget and Contact parameter

1. Create new file `contact_detail_screen.dart`
2. Define StatefulWidget `ContactDetailScreen` with Contact parameter
3. Add Scaffold with AppBar displaying contact name
4. Add scrollable body with SingleChildScrollView
5. Follow Material Design 3 patterns from existing screens

### Phase 2: Implement Navigation

> Replace TODO in contacts_list_screen with actual navigation

1. Update `_navigateToContactDetail` method in contacts_list_screen.dart
2. Use Navigator.push with MaterialPageRoute
3. Pass Contact object to ContactDetailScreen constructor
4. Remove SnackBar placeholder

### Phase 3: Add Widget Tests

> Test navigation and screen rendering

1. Create widget test for ContactDetailScreen
2. Test screen renders with contact name in app bar
3. Test back navigation works
4. Test scrollable content area exists
5. Add navigation test from contacts list to detail screen

## Reviewed implementation

- [ ] Phase 1: Create ContactDetailScreen Widget
- [ ] Phase 2: Implement Navigation
- [ ] Phase 3: Add Widget Tests

## Validation flow

1. Run app: `flutter run`
2. Navigate to Contacts tab
3. Tap on a contact from the list
4. Verify: Detail screen appears with contact name in app bar
5. Verify: Can scroll content area
6. Verify: Back button/gesture returns to list
7. Run tests: `flutter test test/features/contacts/screens/contact_detail_screen_test.dart`

## Estimations

- **Confidence**: 10/10 - Straightforward widget creation following existing patterns
- **Time to implement**: 20 minutes
- **Risks**: None - standard Flutter navigation and widget structure
- **Note**: Issue #79 (UI overflow) is still open but doesn't block this implementation
