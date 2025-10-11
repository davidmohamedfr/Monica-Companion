# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Contact Edit Persistence**: Full contact editing with 4 fields support (name, phone, email, notes)
- **WRITE_CONTACTS Permission**: Permission request flow with denial counter and read-only mode
- **Permission Dialog**: Clear explanation interface for WRITE_CONTACTS permission
- **Read-Only Mode Detection**: Automatic detection after 2 permission denials
- **Contact Creation**: Support for creating new device contacts
- Dependency injection for testability (service locator pattern)
- SharedPreferences for state persistence
- 31 unit tests following TDD methodology
- 7 widget tests for EditContactDialog
- 1 end-to-end integration test for persistence flow

### Fixed
- Provider propagation through navigation (BLoC and Repository)
- `withAccounts` flag to enable Android contact updates
- Name handling (split displayName into first/last name)
- PermissionService injection in ContactsServiceImpl
- BLoC refresh after update to display real data
- Integration test graceful exit when no contacts exist on CI emulator
- Non-existent test file reference in integration test script

### Changed
- AndroidManifest.xml updated with WRITE_CONTACTS permission
- Clean architecture with abstract interfaces
- Backward compatible with existing flow

### Technical
- Total: 58 tests passing, 2 skipped (documented)
- TDD methodology: Red-Green-Refactor cycle followed
- CI workflow: All checks passing

## [0.0.1] - Initial Release

### Added
- Initial project setup
- Basic Flutter application structure
- Material Design 3 theming
- SQLite database integration
- Contact list view with READ_CONTACTS permission
- Contact details screen
- Repository pattern architecture
- BLoC state management
