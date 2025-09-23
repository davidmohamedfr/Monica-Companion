# Implementation Plan: Local Database Infrastructure & Navigation Skeleton

## Project Overview

**Current State**: Flutter app with clean architecture foundation, Material 3 theming, and WelcomeScreen
**Target State**: Offline-first app with SQLite database, repository pattern, and 4-tab bottom navigation

**Key Requirements Met**:
- SQLite database with Monica PRM schema (10 core entities)
- Repository pattern following existing clean architecture
- Bottom navigation with 4 tabs (Contacts, Calls, Settings, Sync)
- Replace WelcomeScreen with main navigation
- Maintain Material 3 theming and Monica brand colors
- Offline-first design with future sync compatibility

---

## Phase 1: Database Foundation
**Estimated Duration**: 3-4 days | **Complexity**: High

### Dependencies Setup
**Task 1.1**: Add SQLite Dependencies
- **Files**: `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/pubspec.yaml`
- **Action**: Add dependencies: `sqflite: ^2.3.0`, `path: ^1.8.3`
- **Complexity**: Low
- **Dependencies**: None

### Database Configuration
**Task 1.2**: Database Configuration Service
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/database_config.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/database_service.dart`
- **Action**: Create database configuration and connection management
- **Complexity**: Medium
- **Dependencies**: Task 1.1

**Task 1.3**: Migration System
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/migrations/migration_runner.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/migrations/v1_initial_schema.dart`
- **Action**: Implement database migration system for schema versioning
- **Complexity**: High
- **Dependencies**: Task 1.2

### Schema Definition
**Task 1.4**: Core Entity Tables
- **Files**: `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/schema/tables.dart`
- **Action**: Define SQL DDL for all 10 Monica PRM entities
- **Complexity**: High
- **Dependencies**: Task 1.3

### Acceptance Criteria - Phase 1:
- [ ] SQLite database initializes successfully
- [ ] All 10 entity tables created with proper constraints
- [ ] Migration system can upgrade/downgrade schema versions
- [ ] Database connection pooling works correctly
- [ ] No memory leaks in database connections

---

## Phase 2: Data Layer Implementation
**Estimated Duration**: 5-6 days | **Complexity**: High

### Entity Models
**Task 2.1**: Core Entity Models
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/models/contact.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/models/interaction.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/models/life_event.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/models/note.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/models/task.dart`
- **Action**: Create entity models with JSON serialization
- **Complexity**: Medium
- **Dependencies**: Phase 1 complete

**Task 2.2**: Secondary Entity Models
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/models/gift.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/models/activity.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/models/debt.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/models/reminder.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/models/relationship.dart`
- **Action**: Create remaining entity models
- **Complexity**: Medium
- **Dependencies**: Task 2.1

### Repository Pattern
**Task 2.3**: Repository Interfaces
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/interfaces/contact_repository.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/interfaces/interaction_repository.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/interfaces/base_repository.dart`
- **Action**: Define repository contracts for CRUD operations
- **Complexity**: Medium
- **Dependencies**: Task 2.2

**Task 2.4**: Repository Implementations
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/repositories/sqlite_contact_repository.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/repositories/sqlite_interaction_repository.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/db/repositories/repository_registry.dart`
- **Action**: Implement SQLite-backed repositories
- **Complexity**: High
- **Dependencies**: Task 2.3

### Acceptance Criteria - Phase 2:
- [ ] All entity models serialize/deserialize correctly
- [ ] Repository pattern follows clean architecture principles
- [ ] CRUD operations work for all entities
- [ ] Database transactions handle errors properly
- [ ] Repository registry manages dependency injection

---

## Phase 3: Navigation Infrastructure
**Estimated Duration**: 3-4 days | **Complexity**: Medium

### Navigation Shell
**Task 3.1**: Main App Shell
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/features/navigation/screens/main_shell.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/features/navigation/widgets/bottom_navigation_bar.dart`
- **Action**: Create main app shell with bottom navigation
- **Complexity**: Medium
- **Dependencies**: None

**Task 3.2**: Update Main App Entry
- **Files**: `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/main.dart`
- **Action**: Replace WelcomeScreen with MainShell
- **Complexity**: Low
- **Dependencies**: Task 3.1

### Feature Screens
**Task 3.3**: Contacts Feature
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/features/contacts/screens/contacts_screen.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/features/contacts/widgets/contact_list_item.dart`
- **Action**: Create placeholder contacts screen with list view
- **Complexity**: Low
- **Dependencies**: Task 3.2

**Task 3.4**: Calls Feature
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/features/calls/screens/calls_screen.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/features/calls/widgets/call_log_item.dart`
- **Action**: Create placeholder calls screen
- **Complexity**: Low
- **Dependencies**: Task 3.2

**Task 3.5**: Settings Feature
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/features/settings/screens/settings_screen.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/features/settings/widgets/settings_section.dart`
- **Action**: Create placeholder settings screen
- **Complexity**: Low
- **Dependencies**: Task 3.2

**Task 3.6**: Sync Feature
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/features/sync/screens/sync_screen.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/features/sync/widgets/sync_status_card.dart`
- **Action**: Create placeholder sync screen
- **Complexity**: Low
- **Dependencies**: Task 3.2

### Acceptance Criteria - Phase 3:
- [ ] Bottom navigation works between all 4 tabs
- [ ] Material 3 theming applied consistently
- [ ] Monica brand colors maintained
- [ ] Screens responsive to different device sizes
- [ ] Navigation state preserved correctly

---

## Phase 4: Integration & Testing
**Estimated Duration**: 2-3 days | **Complexity**: Medium

### Service Integration
**Task 4.1**: Dependency Injection Setup
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/core/di/service_locator.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/lib/core/di/database_module.dart`
- **Action**: Set up dependency injection for repositories and services
- **Complexity**: Medium
- **Dependencies**: Phase 2 complete

**Task 4.2**: Connect Data Layer to UI
- **Files**: Modify existing feature screens
- **Action**: Integrate repository pattern with placeholder screens
- **Complexity**: Medium
- **Dependencies**: Task 4.1, Phase 3 complete

### Testing Strategy
**Task 4.3**: Unit Tests
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/test/db/repositories/contact_repository_test.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/test/db/models/contact_test.dart`
- **Action**: Create unit tests for models and repositories
- **Complexity**: Medium
- **Dependencies**: Phase 2 complete

**Task 4.4**: Widget Tests
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/test/features/contacts/contacts_screen_test.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/test/features/navigation/main_shell_test.dart`
- **Action**: Create widget tests for navigation and screens
- **Complexity**: Medium
- **Dependencies**: Phase 3 complete

**Task 4.5**: Integration Tests
- **Files**:
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/integration_test/database_integration_test.dart`
  - `/Users/davidmohamed/dev/src/perso/MonicaMobileApp/integration_test/navigation_flow_test.dart`
- **Action**: Create end-to-end integration tests
- **Complexity**: High
- **Dependencies**: All previous phases

### Acceptance Criteria - Phase 4:
- [ ] All unit tests pass (>90% coverage for data layer)
- [ ] Widget tests validate UI behavior
- [ ] Integration tests cover critical user flows
- [ ] Performance benchmarks within acceptable limits
- [ ] No memory leaks or performance issues

---

## Monica PRM Entity Schema Details

### Core Entities (10 total):

1. **Contacts** - People in personal network (family, friends, colleagues)
   - Fields: id, name, email, phone, avatar, birthday, address, notes, created_at, updated_at

2. **Interactions** - Communication records (calls, messages, meetings)
   - Fields: id, contact_id, type, date, duration, notes, location, created_at

3. **Life Events** - Important occasions (birthdays, anniversaries, job changes)
   - Fields: id, contact_id, event_type, date, description, importance, created_at

4. **Notes** - Private observations about contacts
   - Fields: id, contact_id, content, category, is_private, created_at, updated_at

5. **Tasks** - Relationship-related follow-ups
   - Fields: id, contact_id, title, description, due_date, completed, priority, created_at

6. **Gifts** - Presents given or received
   - Fields: id, contact_id, name, description, date_given, occasion, value, created_at

7. **Activities** - Shared experiences or events
   - Fields: id, contact_ids, title, description, date, location, participants, created_at

8. **Debts** - Financial interactions between user and contacts
   - Fields: id, contact_id, amount, currency, type, date, description, paid, created_at

9. **Reminders** - Automated notifications for relationship maintenance
   - Fields: id, contact_id, title, description, due_date, frequency, active, created_at

10. **Relationships** - Connection definitions between user and contacts
    - Fields: id, contact_id, relationship_type, start_date, description, created_at

---

## Testing Strategy

### Unit Testing
- **Models**: Serialization, validation, equality
- **Repositories**: CRUD operations, error handling
- **Services**: Database connections, migrations

### Widget Testing
- **Navigation**: Tab switching, state preservation
- **Screens**: Rendering, user interactions
- **Components**: Reusable widgets

### Integration Testing
- **Database Flow**: Full CRUD operations end-to-end
- **Navigation Flow**: Complete user journey
- **Offline Scenarios**: App behavior without network

---

## Risk Mitigation

### High-Risk Areas
1. **Database Migrations**: Test thoroughly on different devices
2. **Memory Management**: Monitor SQLite connection lifecycle
3. **Performance**: Large datasets in repositories

### Mitigation Strategies
- Implement rollback mechanisms for failed migrations
- Use connection pooling and proper disposal patterns
- Add pagination and lazy loading for large datasets
- Comprehensive error handling at all layers

---

## Success Metrics

### Technical Metrics
- Database operations complete within 100ms for typical queries
- App startup time under 3 seconds on mid-range devices
- Memory usage stable under 100MB during normal operation
- Zero critical bugs in core navigation and database operations

### Functional Metrics
- All 4 navigation tabs accessible and functional
- Database persists data correctly across app restarts
- Offline functionality works without network connectivity
- Material 3 theming consistent across all screens

---

## Implementation Notes for Developer

### Existing Architecture to Follow
- **Clean Architecture**: Follow the established pattern in `/lib/core/`, `/lib/features/`, `/lib/services/`
- **Material 3**: Use existing theming setup and Monica brand colors (`Color(0xFF6366F1)`)
- **Testing**: Follow existing test structure in `/test/` directory
- **Dependencies**: Update `/pubspec.yaml` following existing patterns

### File Structure Convention
- All new files should follow the established snake_case naming
- Place database files in `/lib/db/` following the prepared structure
- Feature screens go in `/lib/features/{feature_name}/screens/`
- Widgets go in `/lib/features/{feature_name}/widgets/`

### Key Implementation Points
1. **Start with Phase 1** - Database foundation is critical
2. **Follow clean architecture** - Use existing interfaces and patterns
3. **Test each phase** - Don't move to next phase without tests passing
4. **Maintain offline-first** - All features must work without network
5. **Preserve existing theming** - Keep Monica brand consistency

This plan provides a complete roadmap for implementing the local database infrastructure and navigation skeleton while maintaining the existing code quality and architectural standards.