# Codebase Structure

## Current State: Flutter Mobile App with AIDD Tooling

### Flutter Naming Conventions (Implemented)

- **Files**: snake_case.dart (standard Dart convention)
- **Classes**: PascalCase (MonicaApp, HomePage, AppConfig, EnvironmentConfig)
- **Functions/Methods**: camelCase (build, main, runApp)
- **Variables**: camelCase (currentEnvironment, apiBaseUrl, allFlags)
- **Constants**: lowerCamelCase (AppConfig constants)
- **Configuration files**: snake_case.yaml, kebab-case.yml

### Flutter Module Dependencies (Implemented)

- **Module Graph**: Core-first architecture with feature directories prepared
- **Circular Dependencies**: None - clean separation between core, features, and services
- **Import/Export Strategy**: Package imports for cross-module, relative imports within modules

### Flutter Code Organization Principles (Implemented)

- **Separation of Concerns**: Core utilities separated from features and configuration
- **Feature-Based Structure**: Directory structure prepared for feature modules
- **Configuration Management**: Environment-aware configuration with flavor support

## Implemented Directory Structure

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

## Android Flavor Configuration (Implemented)

The Android build system includes flavor support:

- **Flavor Dimensions**: "environment" dimension configured
- **Implemented Flavors**: 
  - `dev`: Development flavor with .dev suffix and dev API URL
- **Prepared Flavors**: 
  - `staging`: Commented out, ready for staging environment
  - `prod`: Commented out, ready for production environment
- **Build Types**: debug, profile, release with appropriate configurations

## Core Application Features (Implemented)

### Environment Configuration System
- **EnvironmentConfig**: Detects current environment (development/staging/production)
- **AppConfig**: Centralized app configuration with flavor-aware settings
- **Feature Flags**: Centralized feature flag management system

### Material 3 UI Framework
- **Theme System**: Material 3 with dynamic color schemes
- **Component Structure**: Shared widgets for loading, error, and empty states

### Development Infrastructure
- **Linting**: Comprehensive linting rules with analysis_options.yaml
- **Testing**: Unit test structure mirroring lib/ directory
- **Integration Tests**: Full app integration testing setup
- **CI/CD**: GitHub Actions workflows for quality, linting, and release

## File Naming Patterns (Implemented)

### Dart Files
- **Application Files**: snake_case.dart (main.dart, app_config.dart)
- **Widget Files**: snake_case.dart with descriptive suffixes (_widget.dart, _page.dart)
- **Configuration Files**: snake_case.dart for config modules
- **Test Files**: {feature}_test.dart pattern

### Configuration Files
- **Flutter Config**: snake_case.yaml (pubspec.yaml, analysis_options.yaml)
- **Build Config**: platform standards (build.gradle, lefthook.yml)
- **Documentation**: UPPER_CASE.md for major docs, kebab-case.md for specific docs

### Asset Files (Prepared)
- **Images**: kebab-case naming in assets/images/
- **Icons**: kebab-case naming in assets/icons/

## Import/Export Patterns (Implemented)

### Dart Import Strategy
- **Cross-Module Imports**: package:monica_mobile_app/module/file.dart
- **Intra-Module Imports**: Relative paths (./file.dart, ../file.dart)
- **External Dependencies**: Standard package: imports from pubspec.yaml
- **Core Utilities**: Imported via package paths for consistency

### Dependency Management
- **Dependencies**: Minimal core dependencies (equatable, cupertino_icons)
- **Dev Dependencies**: Comprehensive testing and development tools
- **Build Tools**: Code generation tools prepared for future use

## Current Implementation Status

### Fully Implemented
- ✅ Flutter project structure with proper naming conventions
- ✅ Android flavor system with dev environment
- ✅ Core configuration and environment detection
- ✅ Material 3 UI framework setup
- ✅ Comprehensive linting and code quality setup
- ✅ Testing infrastructure (unit and integration)
- ✅ CI/CD workflows with GitHub Actions
- ✅ Feature flag system
- ✅ AIDD documentation tooling integration

### Directory Structure Prepared
- 📁 Feature modules (contacts, calls, sync, settings)
- 📁 Database layer with interfaces and repositories
- 📁 Service layer with implementations and interfaces
- 📁 Complete test structure mirroring lib/

### Ready for Implementation
- 🔧 Monica API integration
- 🔧 Contact management features
- 🔧 Call logging functionality
- 🔧 Data synchronization
- 🔧 Local database implementation
- 🔧 Additional flavors (staging, prod)