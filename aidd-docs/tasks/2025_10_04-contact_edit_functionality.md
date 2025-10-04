# Instruction: Contact Details - Add edit functionality (basic)

## Feature

- **Summary**: Add edit button to contact detail screen with form dialog for updating contact fields (name, phone, email, notes) with validation and local state updates
- **Stack**: `Flutter 3.35.3`, `Dart 3.9.2`, `Material Design 3`, `flutter_bloc 8.1.6`, `flutter_test`

## Existing files

- @lib/features/contacts/screens/contact_detail_screen.dart
- @lib/features/contacts/bloc/contacts_bloc.dart
- @lib/features/contacts/bloc/contacts_event.dart
- @lib/features/contacts/bloc/contacts_state.dart
- @lib/core/utils/validators.dart (for email validation)

### New file to create

- lib/features/contacts/widgets/edit_contact_dialog.dart

## Implementation phases

### Phase 1: Add UpdateContact Event to Bloc

> Create new event and handler for updating contacts

1. Add UpdateContactRequested event to contacts_event.dart
2. Add event handler in ContactsBloc
3. Update local state with modified contact
4. Emit success state after update
5. Handle errors and emit error state if needed

### Phase 2: Create Edit Contact Dialog Widget

> Build form dialog for editing contact fields

1. Create EditContactDialog widget with Form
2. Add TextFormField for name (required)
3. Add TextFormField for phone (optional)
4. Add TextFormField for email (optional, with validation)
5. Add TextFormField for notes (optional, multiline)
6. Pre-fill fields with current contact data
7. Add Save and Cancel buttons
8. Implement form validation

### Phase 3: Integrate Edit Button in Detail Screen

> Add edit button to app bar and handle dialog

1. Add IconButton with Icons.edit to app bar actions
2. Implement _showEditDialog method
3. Show EditContactDialog when edit button tapped
4. Pass current contact to dialog
5. Handle dialog result (save/cancel)

### Phase 4: Handle Save and Update

> Process form submission and update contact

1. Validate form on save
2. Create UpdateContactRequested event with updated contact
3. Add event to ContactsBloc
4. Close dialog on success
5. Show SnackBar with success message
6. Update detail screen with new contact data

### Phase 5: Add Widget Tests

> Test edit functionality

1. Test edit button appears in app bar
2. Test tapping edit opens dialog
3. Test form fields are pre-filled
4. Test save button validates and updates contact
5. Test cancel button closes dialog without changes
6. Test email validation
7. Test success snackbar appears

## Reviewed implementation

- [ ] Phase 1: Add UpdateContact Event to Bloc
- [ ] Phase 2: Create Edit Contact Dialog Widget
- [ ] Phase 3: Integrate Edit Button in Detail Screen
- [ ] Phase 4: Handle Save and Update
- [ ] Phase 5: Add Widget Tests

## Validation flow

1. Run app: `flutter run`
2. Navigate to a contact detail screen
3. Verify: Edit button appears in app bar
4. Tap edit button
5. Verify: Dialog opens with pre-filled form
6. Edit contact fields
7. Tap Save
8. Verify: Dialog closes, snackbar shows, contact updated
9. Tap edit again, verify changes persisted
10. Test cancel button closes without saving
11. Run tests: `flutter test test/features/contacts/`

## Estimations

- **Confidence**: 9/10 - Standard form dialog with bloc integration
- **Time to implement**: 45 minutes
- **Risks**:
  - Form validation needs proper error handling (low risk)
  - State management needs to update both bloc and detail screen (medium risk - ensure proper BlocListener)
