# AGENTS.md

This file contains a collection of config, context, rules, information etc for a project.

The goal is to provide to the ASSISTANT a clear understanding of the project's context, including its structure, dependencies, and any specific conventions that should be followed.

All instructions and information above are willing to be up to date, but always remind yourself that USER can be wrong, be critical of the information provided, and verify it against the project's actual state.

- Current date: !`date`
- When dealing with github, use `gh` cli

Rules:

- **Avoid complexity**: stay simple, pragmatic, effective
- **No over-engineering**: focus on requirements
- No silent error, throw exceptions early
-

---

## MEMORY BANK

This section contains project-specific memory bank information, including context, architecture decisions, and implementation details.

The goal is to provide the ASSISTANT with a comprehensive understanding of the project's current state, past decisions, and ongoing context.

All information should be kept up to date and reflect the actual state of the project.


### Architecture

#### Frontend

- **Framework**: Flutter 3 → @pubspec.yaml - Material Design 3 with `useMaterial3: true`
- **Environment Config**: Custom flavor system with `Environment` enum - dev/staging/production
- **Feature Flags**: Environment-based feature toggles in `FeatureFlags` class
- **Validation**: Core validators with `Validators` class - email, phone, required field validation
- **Error Handling**: Custom exceptions with `AppException` and `Failure` classes
- **Logging**: Custom logger with environment-based console logging
- **Build Tool**: Flutter Build with Android flavors - dev flavor implemented
- **Structure**: Feature-First DDD pattern - features/*/domain|data|presentation layers

#### Backend

- **Language/Framework**: No Backend Service - Integrates with external MonicaHQ API
- **API Style**: REST Consumer - Consumes MonicaHQ REST API endpoints
- **Architecture**: Mobile-First - Logic embedded in Flutter application
- **Database**: Interface-based design with `DatabaseInterface` and `RepositoryInterface`
- **Models**: Base model pattern with `BaseModel` class for domain entities
- **Services**: Service locator pattern with interface-based dependency injection
- **Testing**: Flutter Test framework with unit tests and integration tests implemented

#### Mobile

- **Framework**: Flutter 3 (Dart) → @pubspec.yaml - SDK >=3.1.0
- **Platform**: Android with Gradle 8.9, AGP 8.6.0, Kotlin 2.1.0
- **Flavors**: Android product flavors - dev flavor with `.dev` suffix implemented
- **Icons**: Vector-based adaptive icons with XML launcher icons

#### Database

- **Architecture**: Interface-based with `DatabaseInterface` abstraction layer
- **Configuration**: `DatabaseConfig` class for connection management
- **Repositories**: Base repository pattern with `BaseRepository` implementation
- **Models**: Domain entities extend `BaseModel` with common fields
- **Testing**: Mock database services for unit testing

#### Authentication & Authorization

- **Services**: Interface-based with `StorageService` and `ApiService` abstractions
- **Authorization**: External MonicaHQ - Authorization handled by MonicaHQ instance
- **Base Services**: `BaseService` implementation with common service functionality

#### Core Patterns

- **Feature Architecture**: DDD-inspired pattern with domain/data/presentation layers
- **Repository Pattern**: Interface-based data access with `RepositoryInterface`
- **Service Locator**: Dependency injection with `ServiceLocator` class
- **Base Classes**: Common functionality with `BaseModel`, `BaseRepository`, `BaseService`
- **Error Handling**: Exception hierarchy with `AppException` and `Failure` classes
- **Feature State**: Shared state management with `FeatureState` model

#### Dependencies

- **Core**: `equatable: ^2.0.5` - Value equality for models
- **Development**: `flutter_lints: ^3.0.0` - Dart/Flutter linting rules
- **Testing**: `mocktail: ^1.0.0` - Mock generation for unit tests
- **Code Generation**: `json_serializable: ^6.7.1`, `build_runner: ^2.4.7` - JSON serialization
- **Integration Testing**: `integration_test` - End-to-end testing framework

#### Services communication

```mermaid
graph TD
    A[AIDD Tooling] --> B[Flutter Mobile App]
    B --> C[Local SQLite DB]
    B --> D[MonicaHQ API]
    B --> E[Android Contacts]
    B --> F[Android Call Log]
    
    C --> G[Contacts Cache]
    C --> H[Call History]
    C --> I[Sync Queue]
    C --> J[Journal Events]
    
    D --> K[Monica Contacts API]
    D --> L[Monica Activities API]
    
    subgraph "Background Services"
        M[WorkManager] --> N[Sync Service]
        N --> D
        N --> C
    end
    
    subgraph "Security Layer"
        O[Android Keystore] --> P[API Token]
        O --> Q[DB Encryption Key]
    end
```

##### External Services

- **MonicaHQ API**: Primary data source and sync target
  - Authentication: Bearer token stored in Android Keystore
  - Rate limits: Respectful sync intervals with exponential backoff
  - Fallback strategy: Local queue with retry mechanism, offline mode support

- **Android System APIs**: Contact and call log access
  - Authentication: Runtime permissions (Contacts, Phone)
  - Rate limits: System-imposed, respectful polling intervals
  - Fallback strategy: Reduced mode without bidirectional sync if permissions denied

### CI/CD Implementation Guidelines

#### Version Management

##### Consistency Rules
- Use environment variables for all version specifications across CI jobs
- Pin Flutter/Dart versions in pubspec.yaml and reference in CI workflows
- Validate version consistency across all workflow jobs during implementation
- Never hardcode versions in individual job steps

##### Example Implementation
```yaml
env:
  JAVA_VERSION: "17"

jobs:
  lint:
    steps:
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version-file: pubspec.yaml
```

#### Test Strategy

##### Test-Implementation Alignment
- Align test expectations with actual implementation behavior
- Fix tests when implementation is correct, not vice versa
- Validate test cases against business requirements before implementation
- Use descriptive test names that reflect actual behavior

##### Test Organization
- Separate unit tests from integration tests in CI jobs
- Run fast tests (lint, unit) before slow tests (integration, build)
- Provide clear failure messages and debugging information
- Use test randomization to catch order-dependent failures

##### Example Test Structure
```dart
group('isNotEmpty', () {
  test('should return true for non-empty strings', () {
    // Test actual implementation behavior, not assumptions
    expect(Validators.isNotEmpty('test with spaces'), isTrue);
  });
});
```

#### Build Configuration

##### Android Requirements
- Android minSdk should target reasonable compatibility (API 24+ recommended)
- Generate Android project files if missing via `flutter create --platforms android`
- Configure minSdkVersion explicitly in build.gradle.kts
- Support multiple environment branches (main, dev, staging)

##### Platform Support
- Document which platforms are currently supported (Android-only vs multi-platform)
- Use appropriate build commands for target platforms
- Handle platform-specific configuration in CI

##### Example Android Configuration
```kotlin
// android/app/build.gradle.kts
defaultConfig {
    minSdk = 24  // Android 7.0 for modern features
    targetSdk = flutter.targetSdkVersion
}
```

#### Job Dependencies

##### Pipeline Structure
- Structure jobs in logical order: lint → test → build → integration
- Use proper `needs` declarations for job sequencing
- Include all relevant jobs in final integration step
- Ensure proper failure propagation through dependency chain

##### Parallel Execution
- Run independent jobs in parallel for performance
- Group related checks in single jobs when beneficial
- Use job matrices for multi-platform builds
- Balance parallelism with resource constraints

##### Example Job Structure
```yaml
jobs:
  lint: # Fast feedback
  test: # Parallel with lint
  build:
    needs: [lint, test] # Only after quality gates
  integration:
    needs: [lint, test, build] # Final validation
```

#### Performance Optimization

##### Caching Strategy
- Cache Flutter SDK installations across jobs
- Cache Gradle dependencies for Android builds
- Cache pub dependencies between runs
- Use appropriate cache keys for invalidation

##### Timeout Management
- Set reasonable timeouts for each job type
- Allow longer timeouts for integration tests and builds
- Monitor actual execution times and adjust accordingly
- Fail fast on obvious errors

##### Artifact Management
- Upload build artifacts for debugging
- Set appropriate retention periods (7 days for debug builds)
- Compress large artifacts when possible
- Store coverage reports and test results

#### Error Handling

##### Failure Scenarios
- Handle missing dependencies gracefully
- Provide clear error messages for common failures
- Include troubleshooting information in CI output
- Use conditional execution to prevent cascading failures

##### Debug Information
- Log important configuration values
- Include version information in CI output
- Capture relevant logs for failed builds
- Provide links to relevant documentation

#### Environment Configuration

##### Branch Strategy
- Support development workflows with multiple branches
- Configure appropriate triggers for different branch types
- Use environment-specific configurations when needed
- Document branch protection rules and requirements

##### Secret Management
- Use GitHub secrets for sensitive configuration
- Avoid hardcoding credentials or tokens in workflows
- Document required secrets for project setup
- Use least-privilege access for CI tokens

#### Quality Gates

##### Code Quality Checks
- Enforce formatting consistency across all code
- Run static analysis with appropriate error levels
- Check for security vulnerabilities in dependencies
- Validate documentation and code comments

##### Test Coverage
- Monitor test coverage trends over time
- Set reasonable coverage thresholds (60%+ recommended)
- Generate coverage reports as artifacts
- Include coverage information in PR comments

##### Build Verification
- Verify builds complete successfully for target platforms
- Check build artifact sizes and warn on excessive growth
- Validate app startup and basic functionality
- Test deployment readiness for release builds

### Codebase Structure

#### Current State: Flutter Mobile App with AIDD Tooling

##### Flutter Naming Conventions (Implemented)

- **Files**: snake_case.dart (standard Dart convention)
- **Classes**: PascalCase (MonicaApp, HomePage, AppConfig, EnvironmentConfig)
- **Functions/Methods**: camelCase (build, main, runApp)
- **Variables**: camelCase (currentEnvironment, apiBaseUrl, allFlags)
- **Constants**: lowerCamelCase (AppConfig constants)
- **Configuration files**: snake_case.yaml, kebab-case.yml

##### Flutter Module Dependencies (Implemented)

- **Module Graph**: Core-first architecture with feature directories prepared
- **Circular Dependencies**: None - clean separation between core, features, and services
- **Import/Export Strategy**: Package imports for cross-module, relative imports within modules

##### Flutter Code Organization Principles (Implemented)

- **Separation of Concerns**: Core utilities separated from features and configuration
- **Feature-Based Structure**: Directory structure prepared for feature modules
- **Configuration Management**: Environment-aware configuration with flavor support

#### Implemented Directory Structure

```
/
├── .github/
│   └── workflows/
│       ├── ci.yml                   # CI pipeline with linting and tests
│       ├── code_quality.yml         # Code quality checks
│       ├── lint.yml                 # Linting workflow
│       └── release.yml              # Release workflow
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   ├── main/                # Main Android configuration
│   │   │   ├── debug/               # Debug build configuration
│   │   │   ├── profile/             # Profile build configuration
│   │   │   └── release/             # Release build configuration
│   │   └── build.gradle             # Android build config with dev flavor
│   └── gradle/
│       └── wrapper/                 # Gradle wrapper
├── docs/
│   ├── FLAVORS.md                   # Flavor configuration documentation
│   └── LINTING.md                   # Linting setup documentation
├── integration_test/
│   ├── app_test.dart                # Main integration test suite
│   ├── helpers/                     # Test helper utilities
│   └── tests/                       # Additional integration tests
├── lib/
│   ├── main.dart                    # App entry point with Material 3 theme
│   ├── config/
│   │   └── feature_flags.dart       # Feature flag configuration
│   ├── core/                        # Core application utilities
│   │   ├── config/
│   │   │   ├── app_config.dart      # App configuration constants
│   │   │   └── environment.dart     # Environment detection and configuration
│   │   ├── constants/
│   │   │   └── app_constants.dart   # Application constants
│   │   ├── errors/
│   │   │   ├── exceptions.dart      # Custom exception definitions
│   │   │   └── failures.dart        # Failure types for error handling
│   │   └── utils/
│   │       ├── logger.dart          # Logging utilities
│   │       └── validators.dart      # Input validation utilities
│   ├── db/                          # Database layer (prepared structure)
│   │   ├── database_config.dart     # Database configuration
│   │   ├── interfaces/
│   │   │   ├── database_interface.dart
│   │   │   └── repository_interface.dart
│   │   ├── models/
│   │   │   └── base_model.dart      # Base model for data entities
│   │   └── repositories/
│   │       └── base_repository.dart # Base repository implementation
│   ├── features/                    # Feature modules (prepared structure)
│   │   ├── calls/                   # Call logging feature (directory prepared)
│   │   ├── contacts/                # Contact management feature (directory prepared)
│   │   ├── settings/                # Settings feature (directory prepared)
│   │   ├── shared/                  # Shared feature components
│   │   │   ├── models/
│   │   │   │   └── feature_state.dart
│   │   │   ├── utils/
│   │   │   │   └── feature_utils.dart
│   │   │   └── widgets/
│   │   │       ├── empty_state_widget.dart
│   │   │       ├── error_widget.dart
│   │   │       └── loading_widget.dart
│   │   └── sync/                    # Synchronization feature (directory prepared)
│   └── services/                    # Technical services (prepared structure)
│       ├── service_locator.dart     # Service locator for dependency injection
│       ├── implementations/         # Service implementations (directory prepared)
│       └── interfaces/              # Service interfaces (directory prepared)
├── scripts/
│   ├── setup-linting.sh             # Linting setup script
│   └── verify_config.md             # Configuration verification documentation
├── templates/                       # Project templates (directory prepared)
├── test/                            # Unit tests (mirroring lib structure)
│   ├── config/
│   ├── core/
│   │   ├── config/
│   │   ├── constants/
│   │   ├── errors/
│   │   └── utils/
│   ├── db/
│   │   ├── interfaces/
│   │   ├── models/
│   │   └── repositories/
│   ├── features/
│   │   └── shared/
│   │       ├── models/
│   │       ├── utils/
│   │       └── widgets/
│   ├── helpers/                     # Test helper utilities
│   ├── mocks/                       # Mock objects for testing
│   └── services/
│       ├── implementations/
│       └── interfaces/
├── aidd/                            # AIDD framework (symlink to shared tooling)
├── aidd-docs/                       # Project documentation and memory bank
│   ├── AGENTS.md                    # Main project specification
│   ├── flows/                       # Workflow documentation
│   ├── logs/                        # Process logs
│   ├── memory-bank/                 # Project memory bank files
│   ├── rules/                       # Project-specific rules
│   └── tasks/                       # Task documentation
├── aidd-generated/                  # Auto-generated files
├── .claude/                         # Claude AI project configuration
├── .github/                         # GitHub configuration
├── .dart_tool/                      # Dart tooling cache
├── .idea/                           # IntelliJ IDEA configuration
├── build/                           # Build outputs
├── .gitignore                       # Git ignore rules
├── .mcp.json                        # MCP configuration
├── analysis_options.yaml            # Dart/Flutter linting rules
├── lefthook.yml                     # Git hooks configuration
├── lefthook-local.yml               # Local git hooks override
├── pubspec.yaml                     # Flutter dependencies and configuration
├── pubspec.lock                     # Locked dependency versions
├── Makefile                         # Build automation
├── README.md                        # Project README
├── PRIVACY.md                       # Privacy policy
├── SECURITY.md                      # Security documentation
├── LICENSE                          # License file
├── CODE_OF_CONDUCT.md               # Code of conduct
└── CLAUDE.md                        # Symlink to project specification
```

#### Android Flavor Configuration (Implemented)

The Android build system includes flavor support:

- **Flavor Dimensions**: "environment" dimension configured
- **Implemented Flavors**: 
  - `dev`: Development flavor with .dev suffix and dev API URL
- **Prepared Flavors**: 
  - `staging`: Commented out, ready for staging environment
  - `prod`: Commented out, ready for production environment
- **Build Types**: debug, profile, release with appropriate configurations

#### Core Application Features (Implemented)

##### Environment Configuration System
- **EnvironmentConfig**: Detects current environment (development/staging/production)
- **AppConfig**: Centralized app configuration with flavor-aware settings
- **Feature Flags**: Centralized feature flag management system

##### Material 3 UI Framework
- **Theme System**: Material 3 with dynamic color schemes
- **Component Structure**: Shared widgets for loading, error, and empty states

##### Development Infrastructure
- **Linting**: Comprehensive linting rules with analysis_options.yaml
- **Testing**: Unit test structure mirroring lib/ directory
- **Integration Tests**: Full app integration testing setup
- **CI/CD**: GitHub Actions workflows for quality, linting, and release

#### File Naming Patterns (Implemented)

##### Dart Files
- **Application Files**: snake_case.dart (main.dart, app_config.dart)
- **Widget Files**: snake_case.dart with descriptive suffixes (_widget.dart, _page.dart)
- **Configuration Files**: snake_case.dart for config modules
- **Test Files**: {feature}_test.dart pattern

##### Configuration Files
- **Flutter Config**: snake_case.yaml (pubspec.yaml, analysis_options.yaml)
- **Build Config**: platform standards (build.gradle, lefthook.yml)
- **Documentation**: UPPER_CASE.md for major docs, kebab-case.md for specific docs

##### Asset Files (Prepared)
- **Images**: kebab-case naming in assets/images/
- **Icons**: kebab-case naming in assets/icons/

#### Import/Export Patterns (Implemented)

##### Dart Import Strategy
- **Cross-Module Imports**: package:monica_mobile_app/module/file.dart
- **Intra-Module Imports**: Relative paths (./file.dart, ../file.dart)
- **External Dependencies**: Standard package: imports from pubspec.yaml
- **Core Utilities**: Imported via package paths for consistency

##### Dependency Management
- **Dependencies**: Minimal core dependencies (equatable, cupertino_icons)
- **Dev Dependencies**: Comprehensive testing and development tools
- **Build Tools**: Code generation tools prepared for future use

#### Current Implementation Status

##### Fully Implemented
- ✅ Flutter project structure with proper naming conventions
- ✅ Android flavor system with dev environment
- ✅ Core configuration and environment detection
- ✅ Material 3 UI framework setup
- ✅ Comprehensive linting and code quality setup
- ✅ Testing infrastructure (unit and integration)
- ✅ CI/CD workflows with GitHub Actions
- ✅ Feature flag system
- ✅ AIDD documentation tooling integration

##### Directory Structure Prepared
- 📁 Feature modules (contacts, calls, sync, settings)
- 📁 Database layer with interfaces and repositories
- 📁 Service layer with implementations and interfaces
- 📁 Complete test structure mirroring lib/

##### Ready for Implementation
- 🔧 Monica API integration
- 🔧 Contact management features
- 🔧 Call logging functionality
- 🔧 Data synchronization
- 🔧 Local database implementation
- 🔧 Additional flavors (staging, prod)

### Coding Guidelines

> Those rules must be minimal because they MUST be checked after EVERY CODE GENERATION.

#### Requirements to complete a feature

In order to complete a feature at its best, always check at the end of the implementation:

- [ ] Whole plan is implemented in code (no omissions)
- [ ] All technical rules are followed
- [ ] Pre-commit hooks pass (`lefthook run pre-commit`)
- [ ] Build is successful (`make build-debug`)
- [ ] All tests pass (unit + integration)

**A feature is really completed if ALL of the above are satisfied: if not, iterate to fix all until all are green.**

##### Stack specifics rules (Flutter/Dart)

- [ ] `dart analyze --fatal-warnings` passes with zero issues
- [ ] `dart format .` produces no changes (code already formatted)
- [ ] `flutter test` passes all unit tests
- [ ] `flutter build apk --debug` succeeds
- [ ] All Dart files follow strict analysis options:
  - [ ] No dynamic calls (`avoid_dynamic_calls`)
  - [ ] No implicit casts (`implicit-casts: false`)
  - [ ] No implicit dynamic (`implicit-dynamic: false`)
  - [ ] All types explicitly declared (`always_specify_types`)
  - [ ] Trailing commas required (`require_trailing_commas`)
- [ ] Feature-first directory structure maintained in `lib/features/`
- [ ] Test files mirror source structure in `test/`

##### Build system rules

- [ ] Android build configuration supports dev environment flavor
- [ ] Makefile commands execute without errors:
  - [ ] `make deps` (flutter pub get)
  - [ ] `make analyze` (dart analyze --fatal-warnings)
  - [ ] `make format` (dart format .)
  - [ ] `make test` (flutter test)
  - [ ] `make build-debug` (flutter build apk --debug)

##### Git workflow rules

- [ ] Pre-commit hooks configured and passing:
  - [ ] `dart format` auto-formats staged files
  - [ ] `dart analyze --fatal-warnings` blocks commits with issues
- [ ] All Dart files formatted before commit
- [ ] No build artifacts committed (excluded in .gitignore)

##### Project structure rules (MonicaHQ Mobile App)

- [ ] Feature-first organization maintained:
  - [ ] `lib/features/` contains feature modules
  - [ ] `lib/core/` contains shared utilities
  - [ ] `lib/services/` contains external service integrations
  - [ ] `test/` mirrors `lib/` structure
- [ ] Dependencies properly declared in `pubspec.yaml`
- [ ] Analysis options enforce project code style standards
- [ ] Environment configuration uses build flavors (dev/staging/prod)

##### CI/CD Code Quality

- [ ] Environment variables for version management prevent inconsistencies
- [ ] Test cases must validate actual implementation behavior
- [ ] Job dependencies ensure proper failure propagation
- [ ] Caching strategies improve pipeline performance
- [ ] Flutter/Dart versions consistent across all CI jobs
- [ ] Android minSdkVersion set to 24 (Android 7.0) minimum
- [ ] Build artifacts generated and stored with appropriate retention

### Infrastructure

#### Project Structure

```plaintext
MonicaMobileApp/
├── .github/                         # CI/CD workflows
│   └── workflows/
│       ├── ci.yml                   # Complete test suite + APK builds
│       ├── code_quality.yml        # Security scans, documentation checks
│       ├── lint.yml                 # Code analysis and linting
│       └── release.yml              # GitHub releases with APK/AAB artifacts
├── android/                         # Android platform configuration
│   ├── app/
│   │   ├── src/
│   │   │   └── main/               # Main manifest & resources
│   │   └── build.gradle            # Multi-flavor build config (dev/staging/prod)
│   └── gradle/                     # Gradle wrapper configuration
├── lib/                           # Flutter application code
│   └── core/config/environment.dart # Environment configuration
├── test/                          # Unit tests with helpers and mocks
├── integration_test/              # Integration tests for Android emulator
├── lefthook.yml                   # Git hooks configuration
├── analysis_options.yaml         # Dart/Flutter linting rules
└── pubspec.yaml                  # Flutter dependencies and metadata
```

#### Environment Variables

##### Flutter Build Configuration

**Environment Variables (@lib/core/config/environment.dart):**
- `FLAVOR` - Build flavor: `development`, `staging`, `production` (default: `development`)
- `API_BASE_URL` - Override default API URLs per environment

**Android Build Flavors (@android/app/build.gradle):**
- **dev**: `com.monica.app.dev` with development API endpoints
- **staging**: `com.monica.app.staging` (commented out, ready to enable)
- **prod**: `com.monica.app` for production (commented out, ready to enable)

**CI/CD Environment Variables:**
- `GITHUB_TOKEN` - For GitHub releases and artifact uploads
- `CODECOV_TOKEN` - For test coverage reporting (optional)

#### URLs

- **Development Environment**:
  - Local Flutter development with hot reload (`flutter run`)
  - Default API endpoint: `https://dev-api.monica.com` (dev flavor)

- **Distribution Channels**:
  - **GitHub Releases**: Direct APK/AAB download from repository releases
  - **F-Droid**: Planned for future releases (infrastructure ready)

- **API Endpoints by Environment**:
  - **Development**: `https://dev-api.monica.com`
  - **Staging**: `https://staging-api.monica.com` (not yet active)
  - **Production**: `https://api.monica.com` (not yet active)

#### Development Environment

**Local Development Setup:**
- Flutter SDK 3.19.0 (stable channel)
- Dart SDK with strict analysis (@analysis_options.yaml)
- Android SDK for emulator and device testing
- Git hooks with Lefthook (@lefthook.yml)

**Development Tools:**
- VS Code with Flutter extensions (recommended)
- Android Studio support available
- Git pre-commit hooks for formatting and analysis
- Automated dependency updates on branch switches

#### Testing & Code Quality

- **Test Execution**:
  - Unit tests: `flutter test --coverage` → Feature-organized with helpers (@test/)
  - Integration tests: `flutter test integration_test/` → Android emulator testing
  - Test helpers and mocks: @test/helpers/ and @test/mocks/
  - Coverage reporting: Codecov integration

- **Code Quality Tools**:
  - Linter: `dart analyze --fatal-infos --fatal-warnings` → @analysis_options.yaml
  - Formatter: `dart format --set-exit-if-changed` → Enforced formatting
  - Git hooks: @lefthook.yml → Pre-commit format + analysis
  - Security scanning: Hardcoded secrets detection, debug print checks

- **Quality Gates (CI/CD)**:
  - Static analysis: No fatal errors, warnings acceptable for development
  - Version consistency across all CI jobs enforced
  - Test coverage: Automatic coverage reports to Codecov
  - Build verification: Debug APK builds on every push
  - Dependency auditing: Security vulnerability scans

#### CI/CD Pipeline

```mermaid
graph LR
    A[Git Push/PR] --> B[Lint Workflow]
    A --> C[CI Workflow]
    A --> D[Code Quality Workflow]
    B --> E[Analysis & Format Check]
    C --> F[Unit Tests + Integration Tests]
    C --> G[Build Debug APK]
    D --> H[Security Scans + Documentation]
    E --> I[Artifacts Upload]
    F --> I
    G --> I
    H --> I
    J[Tag Push] --> K[Release Workflow]
    K --> L[Build Release APK/AAB]
    L --> M[GitHub Release]
```

**GitHub Actions Workflows:**
- **Lint** (@.github/workflows/lint.yml): Code analysis, formatting, dependency checks
- **CI** (@.github/workflows/ci.yml): Complete test suite + APK builds with emulator
- **Code Quality** (@.github/workflows/code_quality.yml): Security scans, documentation validation
- **Release** (@.github/workflows/release.yml): Tag-triggered releases with APK/AAB artifacts

**Build Strategy:**
- Flutter 3.13.0 stable for all workflows (consistent with pubspec.yaml requirement)
- Android emulator testing with API level 30
- Debug builds on every push/PR
- Release builds only on version tags
- Artifact retention: 7 days for debug builds

**CI/CD Best Practices:**
- Always use environment variables for version management across jobs
- Ensure test cases align with actual implementation behavior
- Implement proper job dependency chains for reliable pipeline execution
- Use caching for Flutter SDK, dependencies, and build artifacts

**Android Configuration:**
- minSdkVersion: 24 (Android 7.0) for modern feature support
- Android directory can be regenerated via `flutter create` for CI compatibility
- Build configuration supports dev and production environments

#### Mobile App Distribution

**Current Channels:**
- **GitHub Releases**: Direct APK/AAB download from repository releases
- Built from tagged versions with automated release workflow

**Planned Channels:**
- **F-Droid**: Infrastructure ready, not yet submitted

**Release Process:**
- Tag-based releases (`v*.*.*` pattern)
- Automated APK and AAB generation
- GitHub release creation with download links
- Release assets: `monica-mobile-app-{version}.apk` and `.aab`

#### Application Monitoring

**Test Coverage Monitoring:**
- Automated test execution in CI/CD
- Coverage reports via Codecov integration
- Unit test organization by features with test helpers

**Build Monitoring:**
- Automated APK builds on every commit
- Integration test execution on Android emulator
- Artifact upload and retention for debugging

**Code Quality Monitoring:**
- Security vulnerability scanning via `dart pub audit`
- Dependency monitoring with `flutter pub outdated`
- Static analysis with strict linting rules

#### Project Configuration

**Build Configuration:**
- Multi-flavor Android builds (@android/app/build.gradle)
- Environment-specific configuration (@lib/core/config/environment.dart)
- Strict Dart analysis rules (@analysis_options.yaml)
- Git hooks for code quality (@lefthook.yml)

**Development Dependencies (@pubspec.yaml):**
- Flutter SDK ≥3.13.0, Dart SDK ≥3.1.0 (pinned in CI environment variables)
- Testing framework: flutter_test, integration_test, mocktail
- Code generation: json_serializable, build_runner
- Linting: flutter_lints with extensive custom rules

**Security & Quality:**
- Hardcoded secrets detection in CI/CD
- Debug print statement scanning
- Dependency vulnerability auditing
- Automated formatting enforcement

### PROJECT_BRIEF.md

Monica Mobile App is a mobile companion application for Monica, the open-source Personal Relationship Manager (PRM) that helps users document their lives and organize their interactions with family, friends, and personal relationships.

#### Executive Summary

- **Project Name**: Monica Mobile App
- **Vision**: To provide a seamless mobile experience for managing personal relationships on-the-go
- **Mission**: Building a native mobile application that enables users to maintain and nurture their personal relationships through comprehensive contact management, automatic interaction logging, and relationship insights from anywhere
- **Primary Platform**: Android (V1), with iOS planned for future releases

##### Full Description

The Monica Mobile App aims to bridge the gap between the comprehensive web-based Monica PRM and the need for mobile accessibility. While the existing Monica platform offers powerful relationship management features through web browsers, users have expressed the need for a dedicated mobile application that provides quick access to contact information, enables automatic call logging, and sends proactive reminders about important relationship milestones.

This mobile app serves as a companion to the main Monica platform, focusing on the most frequently used mobile features while maintaining full bidirectional synchronization with the user's Monica account. The app prioritizes privacy with offline-first design, encrypted local storage, and minimal permission requirements.

#### Context

The project addresses a significant gap in the personal relationship management ecosystem. Monica, as an established open-source PRM, has built a strong community of users who document their personal relationships, but currently lacks mobile accessibility beyond responsive web design.

##### Core Domain

Monica operates in the Personal Relationship Management (PRM) domain, which applies Customer Relationship Management (CRM) principles to personal relationships. The core focus is on helping individuals maintain meaningful connections with their personal network by providing tools to remember important details, track interactions, and manage relationship-related tasks.

##### Ubiquitous Language

| Term | Definition |
|------|------------|
| Contact | A person in the user's personal network (family, friend, acquaintance, colleague) |
| Interaction | Any form of communication or meeting with a contact (call, message, in-person meeting) |
| Reminder | Automated notifications about important dates, follow-up actions, or relationship maintenance |
| Gift | Presents given or received, tracked for future reference and relationship building |
| Activity | Shared experiences or events involving contacts |
| Debt | Money borrowed or lent between the user and contacts |
| Relationship | The defined connection between the user and a contact (family member, friend, colleague) |
| Life Event | Significant occasions in contacts' lives (birthdays, anniversaries, job changes) |
| Note | Private observations or information about contacts |
| Task | Relationship-related actions or follow-ups |
| **Sync** | Bidirectional data synchronization between mobile app and Monica web platform |
| **Offline Mode** | Local app functionality without internet connection |
| **Call Log** | Automatic capture and recording of phone call interactions |
| **Conflict Resolution** | Process for handling data conflicts during synchronization |
| **Exclusion List** | User-defined list of contacts or numbers to exclude from sync |
| **Local Storage** | Encrypted SQLite database on device for offline data access |
| **Background Sync** | Automatic data synchronization occurring without user interaction |
| **Undo Journal** | Activity log enabling reversal of user actions |

#### Core Use Cases

##### Primary V1 Features
- **Bidirectional Contact Sync** - Seamlessly synchronize Android contacts with MonicaHQ
- **Automatic Call Logging** - Capture phone interactions with known and unknown contacts automatically
- **Offline Contact Access** - Access essential contact information without internet connection
- **Privacy-Focused Management** - Encrypted local storage with fine-grained sync control
- **Conflict Resolution** - Smart handling of sync conflicts with manual review options
- **Undo System** - Reverse actions with comprehensive activity journal

##### Extended Mobile Use Cases
- Quick contact lookup and information access while on-the-go
- Real-time logging of interactions immediately after phone calls or meetings
- Receiving and managing reminders for important relationship events and follow-ups
- Adding notes and observations about contacts during or after interactions
- Tracking gifts given or received during social occasions
- Recording debts and financial interactions with personal contacts
- Setting and managing relationship-related tasks and commitments
- Viewing relationship history and interaction patterns
- Exclusion lists for selective synchronization control

#### User Journey maps

##### Personas

- **Busy Professional**: Someone with an extensive network who struggles to maintain personal relationships due to time constraints and needs automated tracking
- **Family-Oriented Individual**: A person who wants to strengthen family bonds by remembering important details and staying connected through consistent contact
- **Social Butterfly**: An extroverted individual with many acquaintances who wants to deepen relationships and avoid forgetting important details
- **Privacy-Conscious User**: Someone who values relationship management but requires full control over data sync and storage

##### Primary Mobile Journey: Automatic Call Logging (V1 Focus)

```mermaid
graph TD
    A[User receives/makes phone call] --> B[Call ends automatically]
    B --> C[App detects call in background]
    C --> D{Contact in Monica?}
    D -->|Yes| E[Auto-creates interaction log]
    D -->|No| F[Prompts user to add contact or ignore]
    E --> G[Syncs interaction to Monica in background]
    F --> H[User chooses to add contact]
    H --> I[Contact synced to Monica]
    I --> E
    G --> J[User can review/edit interaction later]
    J --> K[App suggests follow-up actions if relevant]
```

##### Secondary Mobile Journey: Manual Contact Sync

```mermaid
graph TD
    A[User opens Monica Mobile App] --> B[Views sync status dashboard]
    B --> C{Conflicts detected?}
    C -->|No| D[Background sync continues]
    C -->|Yes| E[User reviews conflict resolution options]
    E --> F[User selects resolution preference]
    F --> G[Conflicts resolved and synced]
    G --> D
    D --> H[User access contact information offline]
```
