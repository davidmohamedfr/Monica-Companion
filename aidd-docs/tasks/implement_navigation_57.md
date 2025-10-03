# Implementation Plan: #57 - Navigation Foundation - 3-Tab Bottom Navigation

**Issue:** #57
**Priority:** P1 - Foundation
**Created:** 2025-10-03

## Goal
Replace WelcomeScreen with 3-tab navigation (Contacts, Interactions, Settings)

## Current State Analysis

### ✅ What exists
- MainShell with bottom navigation infrastructure
- NavigationBar using Material 3
- All three screen implementations (Contacts, Interactions, Settings)
- ContactsBloc properly set up

### ❌ Issues to fix
- Has 4 tabs (Contacts, Calls, Settings, Sync) - need 3
- Broken import: `features/calls/screens/calls_screen.dart` doesn't exist
- Class named `CallsScreen` instead of `InteractionsScreen`
- WelcomeScreen is home instead of MainShell

## Implementation Steps

### 1. Rename CallsScreen → InteractionsScreen
**File:** `lib/features/interactions/screens/interactions_screen.dart`
- Change class name from `CallsScreen` to `InteractionsScreen`
- Update AppBar title from "Calls" to "Interactions"
- Update widget comment

### 2. Update MainShell (3-tab navigation)
**File:** `lib/features/navigation/screens/main_shell.dart`
- Fix import: `package:monica_companion/features/calls/screens/calls_screen.dart` → `package:monica_companion/features/interactions/screens/interactions_screen.dart`
- Remove `import 'package:monica_companion/features/sync/screens/sync_screen.dart';`
- Remove case 3 (SyncScreen) from `_getScreen()` switch statement
- Update case 1 to return `const InteractionsScreen()` instead of `const CallsScreen()`

### 3. Update Bottom Navigation Bar
**File:** `lib/features/navigation/widgets/bottom_navigation_bar.dart`
- Remove 4th NavigationDestination (Sync)
- Update 2nd destination label: "Calls" → "Interactions"
- Keep icons as-is: contacts_outlined, call_outlined, settings_outlined

### 4. Replace WelcomeScreen with MainShell
**File:** `lib/main.dart`
- Import MainShell: `import 'package:monica_companion/features/navigation/screens/main_shell.dart';`
- Import ContactsBloc dependencies
- Change MaterialApp `home:` from `const WelcomeScreen()` to:
```dart
home: BlocProvider<ContactsBloc>(
  create: (BuildContext context) =>
      ServiceLocator.instance.get<ContactsBloc>(),
  child: const MainShell(),
),
```

### 5. Verify & Test
- Run app and confirm 3 tabs appear
- Test tab switching works
- Verify active tab highlighting
- Check Material 3 styling applies
- Ensure Contacts screen loads properly with data

## Acceptance Criteria

From #57:
- [x] Given: User opens the app
- [x] When: App loads successfully
- [x] Then: Bottom navigation displays 3 tabs (Contacts, Interactions, Settings)
- [x] And: Material 3 navigation bar styling is applied
- [x] And: Active tab is visually highlighted
- [x] And: Tapping a tab navigates to the corresponding screen

## Files Modified (4 files)

1. `lib/features/interactions/screens/interactions_screen.dart`
2. `lib/features/navigation/screens/main_shell.dart`
3. `lib/features/navigation/widgets/bottom_navigation_bar.dart`
4. `lib/main.dart`

## Technical Notes

- ContactsListScreen requires BlocProvider<ContactsBloc> in widget tree
- ServiceLocator already initialized in AppInitializationService
- Material 3 NavigationBar already configured properly
- No database migrations needed
- No API changes needed

## Related Issues

- #58: Contacts Tab - List View with Search (already implemented)
- #59: Contacts Tab - Contact Details View (next priority)
- #60: Contacts Tab - Add/Edit Contact Form (next priority)
- #61: Interactions Tab - Interaction Log with Filters (future)
- #62: Interactions Tab - Manual Interaction Entry (future)
- #63: Settings Tab - Account Management (future)

## Estimated Effort

**Time:** 30-45 minutes
**Complexity:** Low
**Risk:** Low (mostly renaming and wiring)
