# TDD Plan: Contacts Search Feature (Issue #58)

**Branch:** feature/58-contacts-search
**Start Date:** 2025-10-04
**TDD Methodology:** Red → Green → Refactor

## TDD Cycle Rules

1. **RED**: Write a failing test first
2. **GREEN**: Write minimum code to pass the test
3. **REFACTOR**: Clean up while keeping tests green
4. **COMMIT**: Only when all tests pass

## Phase 1: Fix Search Debouncing (HIGH PRIORITY)

### Test 1.1: Search event updates searchQuery in state immediately
- [ ] RED: Write test `shouldUpdateSearchQueryImmediatelyWhenSearchEventAdded`
- [ ] GREEN: Verify existing implementation passes
- [ ] REFACTOR: None needed if passing
- [ ] COMMIT: Structural changes (if any)

### Test 1.2: Empty search query returns all contacts with current filter
- [ ] RED: Write test `shouldReturnAllContactsWhenSearchQueryIsEmpty`
- [ ] GREEN: Verify existing implementation passes
- [ ] REFACTOR: None needed if passing
- [ ] COMMIT: Structural changes (if any)

### Test 1.3: Search debounces within 300ms window
- [ ] RED: Write test `shouldDebounceSearchWithin300Milliseconds`
- [ ] GREEN: Implement proper debouncing with Completer
- [ ] REFACTOR: Extract debounce logic if needed
- [ ] COMMIT: Behavioral change - "fix: implement proper search debouncing"

### Test 1.4: Rapid search input only triggers one repository call
- [ ] RED: Write test `shouldOnlyTriggerOneRepositoryCallForRapidInput`
- [ ] GREEN: Verify debouncing prevents multiple calls
- [ ] REFACTOR: Simplify debounce cancellation logic
- [ ] COMMIT: Structural changes (if any)

### Test 1.5: Search state consistency - query matches results
- [ ] RED: Write test `shouldMaintainConsistencyBetweenQueryAndResults`
- [ ] GREEN: Add state.searchQuery == event.query check before emit
- [ ] REFACTOR: Extract consistency check to helper method
- [ ] COMMIT: Behavioral change - "fix: ensure search state consistency"

### Test 1.6: Search handles errors gracefully
- [ ] RED: Write test `shouldEmitErrorStateWhenSearchFails`
- [ ] GREEN: Verify existing error handling
- [ ] REFACTOR: None needed if passing
- [ ] COMMIT: None

---

## Phase 2: Date Formatter Utility (MEDIUM PRIORITY)

### Test 2.1: Format null date returns empty string
- [ ] RED: Write test `shouldReturnEmptyStringForNullDate`
- [ ] GREEN: Return empty string when date is null
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add date formatter for null dates"

### Test 2.2: Format today's date returns "Today"
- [ ] RED: Write test `shouldReturnTodayForCurrentDate`
- [ ] GREEN: Check if difference.inDays == 0, return "Today"
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add today date formatting"

### Test 2.3: Format yesterday's date returns "Yesterday"
- [ ] RED: Write test `shouldReturnYesterdayForOneDayAgo`
- [ ] GREEN: Check if difference.inDays == 1, return "Yesterday"
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add yesterday date formatting"

### Test 2.4: Format dates within a week returns "N days ago"
- [ ] RED: Write test `shouldReturnDaysAgoForDatesWithinWeek`
- [ ] GREEN: Return "${difference.inDays} days ago" for < 7 days
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add days ago date formatting"

### Test 2.5: Format dates within a month returns "N weeks ago"
- [ ] RED: Write test `shouldReturnWeeksAgoForDatesWithinMonth`
- [ ] GREEN: Calculate weeks and return with proper pluralization
- [ ] REFACTOR: Extract pluralization logic
- [ ] COMMIT: Behavioral change - "feat: add weeks ago date formatting"

### Test 2.6: Format dates within a year returns "N months ago"
- [ ] RED: Write test `shouldReturnMonthsAgoForDatesWithinYear`
- [ ] GREEN: Calculate months and return with proper pluralization
- [ ] REFACTOR: Reuse pluralization helper
- [ ] COMMIT: Behavioral change - "feat: add months ago date formatting"

### Test 2.7: Format dates over a year returns "N years ago"
- [ ] RED: Write test `shouldReturnYearsAgoForDatesOverYear`
- [ ] GREEN: Calculate years and return with proper pluralization
- [ ] REFACTOR: Reuse pluralization helper
- [ ] COMMIT: Behavioral change - "feat: add years ago date formatting"

### Test 2.8: Dual format includes absolute date
- [ ] RED: Write test `shouldIncludeAbsoluteDateInDualFormat`
- [ ] GREEN: Add DateFormat('MMM d, y').format(date)
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add absolute date to dual format"

### Test 2.9: Dual format combines relative and absolute with separator
- [ ] RED: Write test `shouldCombineRelativeAndAbsoluteWithBulletSeparator`
- [ ] GREEN: Return '$relative • $absolute'
- [ ] REFACTOR: Extract separator to constant
- [ ] COMMIT: Structural change - "refactor: extract date separator constant"

---

## Phase 3: Contact List Item Date Display (MEDIUM PRIORITY)

### Test 3.1: ContactListItem displays date when lastContactedAt is not null
- [ ] RED: Write test `shouldDisplayLastContactedDateInSubtitle`
- [ ] GREEN: Add date to subtitleParts in _buildSubtitle
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: display last contacted date in contact list"

### Test 3.2: ContactListItem does not add empty date string to subtitle
- [ ] RED: Write test `shouldNotDisplayEmptyDateString`
- [ ] GREEN: Check if dateStr.isNotEmpty before adding
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "fix: prevent empty date in subtitle"

### Test 3.3: ContactListItem subtitle allows 2 lines for longer content
- [ ] RED: Write test `shouldAllowTwoLinesForSubtitle`
- [ ] GREEN: Change maxLines from 1 to 2
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: allow two lines for contact subtitle"

---

## Phase 4: Sorting Infrastructure (MEDIUM PRIORITY)

### Test 4.1: ContactSortOrder enum has correct display names
- [ ] RED: Write test `shouldReturnCorrectDisplayNamesForSortOrders`
- [ ] GREEN: Create enum with displayName getter
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add ContactSortOrder enum"

### Test 4.2: ContactsState includes currentSortOrder field
- [ ] RED: Write test `shouldIncludeCurrentSortOrderInState`
- [ ] GREEN: Add currentSortOrder to ContactsState
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add sort order to contacts state"

### Test 4.3: ContactsState copyWith handles sortOrder
- [ ] RED: Write test `shouldCopyWithSortOrder`
- [ ] GREEN: Add currentSortOrder to copyWith method
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: support sort order in state copy"

### Test 4.4: ContactsState props includes sortOrder
- [ ] RED: Write test `shouldIncludeSortOrderInEquality`
- [ ] GREEN: Add currentSortOrder to props list
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "fix: include sort order in state equality"

---

## Phase 5: Sorting Logic (MEDIUM PRIORITY)

### Test 5.1: Sort contacts by name ascending (A-Z)
- [ ] RED: Write test `shouldSortContactsByNameAscending`
- [ ] GREEN: Implement _applySorting with nameAscending case
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add name ascending sort"

### Test 5.2: Sort contacts by name descending (Z-A)
- [ ] RED: Write test `shouldSortContactsByNameDescending`
- [ ] GREEN: Add nameDescending case to _applySorting
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add name descending sort"

### Test 5.3: Sort contacts by last interaction (recent first)
- [ ] RED: Write test `shouldSortContactsByLastInteractionRecent`
- [ ] GREEN: Add lastInteractionRecent case with null handling
- [ ] REFACTOR: Extract null handling logic
- [ ] COMMIT: Behavioral change - "feat: add last interaction recent sort"

### Test 5.4: Sort contacts by last interaction (oldest first)
- [ ] RED: Write test `shouldSortContactsByLastInteractionOldest`
- [ ] GREEN: Add lastInteractionOldest case
- [ ] REFACTOR: Reuse null handling helper
- [ ] COMMIT: Behavioral change - "feat: add last interaction oldest sort"

### Test 5.5: Sort places contacts without dates at the end
- [ ] RED: Write test `shouldPlaceContactsWithoutDatesAtEnd`
- [ ] GREEN: Verify null handling in sort comparators
- [ ] REFACTOR: None
- [ ] COMMIT: None

### Test 5.6: ChangeSortOrderEvent triggers sorting
- [ ] RED: Write test `shouldApplySortingWhenSortOrderEventAdded`
- [ ] GREEN: Create ChangeSortOrderEvent and handler
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add sort order change event"

### Test 5.7: Sort order persists in SharedPreferences
- [ ] RED: Write test `shouldPersistSortOrderPreference`
- [ ] GREEN: Save sort order index to SharedPreferences
- [ ] REFACTOR: Extract preference key to constant
- [ ] COMMIT: Behavioral change - "feat: persist sort order preference"

### Test 5.8: Sort order loads from SharedPreferences on init
- [ ] RED: Write test `shouldLoadSavedSortOrderOnInit`
- [ ] GREEN: Load saved sort order in constructor
- [ ] REFACTOR: Extract load logic to helper method
- [ ] COMMIT: Structural change - "refactor: extract sort order loading"

---

## Phase 6: Empty States (LOW PRIORITY)

### Test 6.1: Show "Create contact" button when no contacts exist
- [ ] RED: Write test `shouldShowCreateContactButtonWhenNoContacts`
- [ ] GREEN: Check state.contacts.isEmpty and show appropriate widget
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add create contact empty state"

### Test 6.2: Show "Clear filters" button when search/filter active
- [ ] RED: Write test `shouldShowClearFiltersButtonWhenSearchOrFilterActive`
- [ ] GREEN: Check search query or filter and show appropriate widget
- [ ] REFACTOR: Extract empty state logic to helper method
- [ ] COMMIT: Behavioral change - "feat: add clear filters empty state"

### Test 6.3: Create contact button shows snackbar (placeholder)
- [ ] RED: Write test `shouldShowSnackbarWhenCreateContactTapped`
- [ ] GREEN: Add SnackBar with "Coming soon" message
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: add create contact placeholder"

---

## Phase 7: Edge Cases (LOW PRIORITY)

### Test 7.1: Long contact names display without truncation
- [ ] RED: Write test `shouldDisplayLongNamesWithoutTruncation`
- [ ] GREEN: Change maxLines to 2 for title Text
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "feat: allow long names to wrap"

### Test 7.2: Search includes contacts with "Unknown" name when other fields match
- [ ] RED: Write test `shouldSearchUnknownContactsByEmailAndPhone`
- [ ] GREEN: Update search logic to skip name match for "Unknown"
- [ ] REFACTOR: Extract name matching logic
- [ ] COMMIT: Behavioral change - "fix: search unknown contacts by other fields"

---

## Phase 8: Integration Testing

### Test 8.1: End-to-end search workflow
- [ ] RED: Write integration test for complete search flow
- [ ] GREEN: Verify all components work together
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "test: add search integration test"

### Test 8.2: Sort preference persistence across app restarts
- [ ] RED: Write integration test for sort persistence
- [ ] GREEN: Verify sort order survives restart
- [ ] REFACTOR: None
- [ ] COMMIT: Behavioral change - "test: add sort persistence integration test"

---

## Running Tests Command

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/contacts/bloc/contacts_bloc_search_test.dart

# Run with coverage
flutter test --coverage
```

---

## Commit Convention

**Structural commits:**
- `refactor: <description>` - Code reorganization without behavior change
- `chore: <description>` - Maintenance tasks

**Behavioral commits:**
- `feat: <description>` - New feature
- `fix: <description>` - Bug fix
- `test: <description>` - Adding tests

---

## Current Progress Tracker

**Phase 1: Search Debouncing**
- [x] Test 1.1 - Search query immediate update ✅ PASSES (existing implementation correct)
- [x] Test 1.2 - Empty search returns all ✅ PASSES (existing implementation correct)
- [ ] Test 1.3 - Debounce within 300ms
- [ ] Test 1.4 - Rapid input single call
- [ ] Test 1.5 - State consistency
- [ ] Test 1.6 - Error handling

**Phase 2: Date Formatter**
- [ ] Test 2.1 - Null date
- [ ] Test 2.2 - Today
- [ ] Test 2.3 - Yesterday
- [ ] Test 2.4 - Days ago
- [ ] Test 2.5 - Weeks ago
- [ ] Test 2.6 - Months ago
- [ ] Test 2.7 - Years ago
- [ ] Test 2.8 - Absolute date
- [ ] Test 2.9 - Dual format

**Phase 3: Date Display**
- [ ] Test 3.1 - Display date in subtitle
- [ ] Test 3.2 - Skip empty dates
- [ ] Test 3.3 - Two-line subtitle

**Phase 4: Sort Infrastructure**
- [ ] Test 4.1 - Enum display names
- [ ] Test 4.2 - State field
- [ ] Test 4.3 - State copyWith
- [ ] Test 4.4 - State props

**Phase 5: Sort Logic**
- [ ] Test 5.1 - Name ascending
- [ ] Test 5.2 - Name descending
- [ ] Test 5.3 - Last interaction recent
- [ ] Test 5.4 - Last interaction oldest
- [ ] Test 5.5 - Null dates at end
- [ ] Test 5.6 - Sort event
- [ ] Test 5.7 - Persist preference
- [ ] Test 5.8 - Load preference

**Phase 6: Empty States**
- [ ] Test 6.1 - Create contact button
- [ ] Test 6.2 - Clear filters button
- [ ] Test 6.3 - Create placeholder

**Phase 7: Edge Cases**
- [ ] Test 7.1 - Long names
- [ ] Test 7.2 - Unknown contacts search

**Phase 8: Integration**
- [ ] Test 8.1 - E2E search
- [ ] Test 8.2 - Sort persistence

---

## Notes

- Always run full test suite before committing
- Keep test names descriptive and behavior-focused
- Refactor only when tests are green
- Commit structural and behavioral changes separately
- Use `flutter analyze` to catch warnings before committing
