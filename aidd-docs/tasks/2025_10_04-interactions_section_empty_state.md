# Instruction: Contact Details - Add interactions section (empty state)

## Feature

- **Summary**: Add "Recent Interactions" section to contact detail screen with empty state placeholder, positioned below contact info with clear visual separation
- **Stack**: `Flutter 3.35.3`, `Dart 3.9.2`, `Material Design 3`, `flutter_test`

## Existing files

- @lib/features/contacts/screens/contact_detail_screen.dart
- @lib/features/contacts/widgets/contact_info_section.dart
- @lib/features/shared/widgets/empty_state_widget.dart (to be reused)

### New file to create

None - will modify existing ContactDetailScreen

## Implementation phases

### Phase 1: Add Section Header

> Create "Recent Interactions" section header with visual separation

1. Add Divider or spacing separator after contact info section
2. Add section header Text widget with "Recent Interactions" title
3. Use appropriate typography (titleMedium or titleLarge)
4. Add proper padding/spacing around header

### Phase 2: Integrate EmptyStateWidget

> Display empty state for interactions

1. Import EmptyStateWidget from shared widgets
2. Add EmptyStateWidget with appropriate icon (Icons.history)
3. Set message to "No interactions yet"
4. Add subtitle explaining future implementation
5. Ensure EmptyStateWidget styling matches design system

### Phase 3: Layout and Positioning

> Position section correctly in detail screen

1. Update ContactDetailScreen body layout
2. Position interactions section below ContactInfoSection
3. Add proper spacing between sections
4. Ensure scrollable behavior works with new section
5. Make layout responsive

### Phase 4: Add Widget Tests

> Test interactions section displays correctly

1. Test section header displays
2. Test empty state widget appears
3. Test section is positioned below contact info
4. Test proper spacing between sections
5. Test scrolling behavior

## Reviewed implementation

- [ ] Phase 1: Add Section Header
- [ ] Phase 2: Integrate EmptyStateWidget
- [ ] Phase 3: Layout and Positioning
- [ ] Phase 4: Add Widget Tests

## Validation flow

1. Run app: `flutter run`
2. Navigate to a contact detail screen
3. Verify: "Recent Interactions" header displays
4. Verify: Empty state widget shows with message
5. Verify: Section appears below contact info
6. Verify: Visual separation is clear
7. Verify: Scrolling works smoothly
8. Run tests: `flutter test test/features/contacts/screens/contact_detail_screen_test.dart`

## Estimations

- **Confidence**: 10/10 - Simple widget integration with existing components
- **Time to implement**: 15 minutes
- **Risks**: None - straightforward addition of existing widget
