# Instruction: Configure dev environment foundation with extensible flavor architecture

## Feature

- **Summary**: Set up dev environment configuration with API endpoints and feature flags. Create extensible architecture that supports adding staging/prod flavors later when app is functional.
- **Stack**: `Flutter 3.x, Gradle 8.x, Android SDK, Dart 3.x`

## Existing files

- @android/app/build.gradle
- @android/app/src/main/AndroidManifest.xml
- @lib/main.dart

### New file to create

- lib/config/environment.dart
- lib/config/feature_flags.dart

## Implementation phases

### Phase 1: Basic Environment Architecture

> Create extensible environment configuration system

1. Set up environment configuration base structure in Dart
2. Create dev environment configuration with API endpoints
3. Implement feature flag system for dev environment
4. Configure app name for dev (Monica Dev)

### Phase 2: Gradle Foundation

> Minimal Gradle setup ready for future flavors

1. Set up basic Gradle structure that supports flavors
2. Configure dev-specific build settings
3. Set up debug signing configuration
4. Prepare flavor architecture without multiple flavors yet

### Phase 3: Integration & Testing

> Ensure dev environment works and is ready for expansion

1. Test dev environment configuration loading
2. Verify API endpoints and feature flags work correctly
3. Test app naming and basic build process
4. Document how to add staging/prod flavors later

## Reviewed implementation

<!-- That section is filled by a review agent that ensures feature has been properly implemented -->

- [ ] Phase 1: Basic Environment Architecture
- [ ] Phase 2: Gradle Foundation
- [ ] Phase 3: Integration & Testing

## Validation flow

<!-- What would a REAL user do to 100% validate the feature? -->

1. Build and run dev version of app
2. Verify app shows "Monica Dev" name
3. Verify dev API endpoints are being used
4. Test feature flags are working correctly in dev
5. Confirm architecture is ready for future flavor expansion
6. Test clean builds work consistently

## Estimations

- 9/10 confidence
- 1-2 hours to implement
