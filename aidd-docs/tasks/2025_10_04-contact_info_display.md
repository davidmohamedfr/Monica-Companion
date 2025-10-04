# Instruction: Contact Details - Implement contact info display

## Feature

- **Summary**: Display comprehensive contact information in detail screen with avatar, all contact fields, proper formatting, and graceful handling of optional fields
- **Stack**: `Flutter 3.35.3`, `Dart 3.9.2`, `Material Design 3`, `flutter_test`, `intl` (for date formatting)

## Existing files

- @lib/features/contacts/screens/contact_detail_screen.dart (currently shows placeholder text)
- @lib/features/contacts/models/contact_model.dart (has all fields including notes)
- @lib/features/contacts/widgets/contact_list_item.dart (reference for avatar display)

### New file to create

- lib/features/contacts/widgets/contact_info_section.dart

## Implementation phases

### Phase 1: Create Avatar Widget

> Display contact photo or initials avatar

1. Create CircleAvatar with contact photo if available
2. Fallback to initials (first letter of name) if no photo
3. Use appropriate size (80x80) and styling
4. Add favorite icon overlay if contact is favorite
5. Center avatar at top of screen

### Phase 2: Create Contact Info Items

> Display contact fields with icons and formatting

1. Create info item widget (icon + label + value)
2. Display phone with phone icon (if available)
3. Display email with email icon (if available)
4. Display last contacted date with calendar icon (if available)
5. Display notes in expandable card (if available)
6. Hide items for null/empty optional fields
7. Use proper text formatting and truncation

### Phase 3: Add Favorite Indicator

> Show favorite status visually

1. Add star icon to avatar if isFavorite is true
2. Use gold/yellow color for favorite star
3. Position star as badge on avatar

### Phase 4: Layout and Styling

> Organize information in clean, readable layout

1. Use Column with proper spacing
2. Add Card or Container for info section
3. Apply Material Design 3 spacing (16dp padding)
4. Ensure text is readable with proper typography
5. Make layout responsive (no overflow)

### Phase 5: Add Widget Tests

> Test all display scenarios

1. Test contact with all fields populated
2. Test contact with only required fields
3. Test contact with photo
4. Test contact without photo (initials)
5. Test favorite contact shows star
6. Test optional fields are hidden when null
7. Test date formatting for lastContactedAt

## Reviewed implementation

- [ ] Phase 1: Create Avatar Widget
- [ ] Phase 2: Create Contact Info Items
- [ ] Phase 3: Add Favorite Indicator
- [ ] Phase 4: Layout and Styling
- [ ] Phase 5: Add Widget Tests

## Validation flow

1. Run app: `flutter run`
2. Navigate to a contact detail screen
3. Verify: Avatar displays (photo or initials)
4. Verify: All available contact fields show with icons
5. Verify: Optional empty fields are hidden
6. Verify: Favorite star appears for favorite contacts
7. Verify: Text is readable, no overflow
8. Verify: Last contacted date is formatted properly
9. Run tests: `flutter test test/features/contacts/widgets/contact_info_section_test.dart`

## Estimations

- **Confidence**: 9/10 - Standard widget composition
- **Time to implement**: 30 minutes
- **Risks**:
  - Date formatting might need `intl` package (low risk - already in pubspec)
  - Avatar initials logic needs proper handling of empty names (low risk)
