# Instruction: Contact List UI with Multiple View Modes and Search

## Feature

- **Summary**: Implement contact list display with three view modes (list, grid, card), real-time search functionality, and filtering capabilities for local device contacts
- **Stack**: `Flutter 3.35.0+, Dart 3.8.0+, Equatable 2.0.5, contacts_service (to add), shared_preferences (to add)`

## Existing files

- @lib/features/shared/models/feature_state.dart
- @lib/features/shared/widgets/empty_state_widget.dart
- @lib/features/shared/widgets/error_widget.dart
- @lib/features/shared/widgets/loading_widget.dart
- @lib/core/config/app_config.dart

### New file to create

- lib/features/contacts/models/contact_model.dart
- lib/features/contacts/models/contact_view_mode.dart
- lib/features/contacts/models/contact_filter.dart
- lib/features/contacts/services/contacts_service.dart
- lib/features/contacts/repositories/contacts_repository.dart
- lib/features/contacts/bloc/contacts_bloc.dart
- lib/features/contacts/bloc/contacts_state.dart
- lib/features/contacts/bloc/contacts_event.dart
- lib/features/contacts/widgets/contact_list_item.dart
- lib/features/contacts/widgets/contact_grid_item.dart
- lib/features/contacts/widgets/contact_card_item.dart
- lib/features/contacts/widgets/contacts_search_bar.dart
- lib/features/contacts/widgets/contacts_view_mode_selector.dart
- lib/features/contacts/widgets/contacts_filter_bar.dart
- lib/features/contacts/screens/contacts_list_screen.dart

## Implementation phases

### Phase 1: Core Contact Models and Data Layer

> Establish contact data structures and device contacts access

1. Create Contact model with name, phone, email, photo, metadata fields
2. Create ContactViewMode enum for list/grid/card modes
3. Create ContactFilter enum for favorites/recent/interaction filters
4. Add contacts_service dependency to pubspec.yaml
5. Implement ContactsService to fetch device contacts with permission handling
6. Create ContactsRepository with search and filter methods
7. Add contact permissions to Android/iOS configurations

### Phase 2: State Management with BLoC Pattern

> Implement BLoC pattern for contact state management

1. Create ContactsEvent classes for load, search, filter, view mode changes
2. Create ContactsState classes extending FeatureState for different UI states
3. Implement ContactsBloc with event handling and state emission
4. Add shared_preferences dependency for view mode persistence
5. Integrate search debouncing for real-time search performance
6. Handle loading, success, error states for contacts operations

### Phase 3: UI Components for Different View Modes

> Create reusable contact display widgets for each view mode

1. Create ContactListItem widget for vertical list display
2. Create ContactGridItem widget for grid layout display
3. Create ContactCardItem widget for card-based display
4. Implement ContactsSearchBar with real-time search input
5. Create ContactsViewModeSelector for switching between view modes
6. Create ContactsFilterBar for favorites/recent/interaction filters
7. Add contact photo placeholder handling and circular avatars

### Phase 4: Main Contacts Screen and Navigation

> Assemble components into complete contacts list screen

1. Create ContactsListScreen as main container widget
2. Integrate BlocProvider and BlocBuilder for state management
3. Implement view mode switching with preserved state
4. Add infinite scroll functionality with pagination logic
5. Integrate search functionality with debounced API calls preparation
6. Handle empty states, loading states, and error scenarios
7. Add navigation structure and routing integration

## Reviewed implementation

- [ ] Phase 1: Core Contact Models and Data Layer
- [ ] Phase 2: State Management with BLoC Pattern
- [ ] Phase 3: UI Components for Different View Modes
- [ ] Phase 4: Main Contacts Screen and Navigation

## Validation flow

1. Install and run app on device with contacts permission granted
2. Navigate to contacts list screen and verify contacts load from device
3. Test search functionality by typing contact names, phones, emails
4. Switch between list, grid, and card view modes and verify layouts
5. Apply different filters (favorites, recent, interaction) and verify results
6. Scroll through large contact list and verify infinite scroll performance
7. Test empty states when no contacts match search or filter criteria
8. Verify view mode preference persists between app sessions

## Estimations

- **Confidence**: 9/10 - Well-defined requirements, clear Flutter patterns, existing shared widgets
- **Time to implement**: 2-3 days for experienced Flutter developer (16-24 hours)