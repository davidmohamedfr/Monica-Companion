# TDD Testing Plan: Monica Companion Skeleton App

**Date**: 2025-09-21
**Branch**: 10-build-squelette-sur-device
**Methodology**: Kent Beck's TDD + Tidy First principles

## Overview

Implement comprehensive test coverage for Monica Companion skeleton app following TDD Red-Green-Refactor cycle. Focus on critical behaviors identified in untested analysis.

## TDD Development Rules

1. **Red**: Write simplest failing test first
2. **Green**: Write minimum code to make test pass
3. **Refactor**: Improve structure while keeping tests green
4. **Tidy First**: Separate structural changes from behavioral changes
5. **Commit Discipline**: Only commit when all tests pass

## Test Implementation Plan

### Phase 1: Critical Core Flows (Score 5)

#### Test 1: App Initialization
- [ ] **Test**: `shouldLaunchAppWithoutCrashing`
  - **Red**: Write test that verifies app launches successfully
  - **Green**: Ensure main.dart runApp() executes without exception
  - **Refactor**: Extract app initialization if needed

#### Test 2: Welcome Screen Display
- [ ] **Test**: `shouldDisplayWelcomeScreenOnStartup`
  - **Red**: Write test verifying WelcomeScreen is displayed
  - **Green**: Ensure MaterialApp home property shows WelcomeScreen
  - **Refactor**: Clean up widget tree structure if needed

#### Test 3: Required Assets Loading
- [ ] **Test**: `shouldLoadLogoAssetSuccessfully`
  - **Red**: Write test verifying SVG logo asset loads
  - **Green**: Implement proper asset path resolution
  - **Refactor**: Extract asset constants if needed

#### Test 4: Configuration Initialization
- [ ] **Test**: `shouldInitializeAppConfigWithoutError`
  - **Red**: Write test verifying AppConfig initializes
  - **Green**: Ensure AppConfig.packageName returns valid value
  - **Refactor**: Optimize configuration loading if needed

### Phase 2: User Interface Behaviors (Score 4)

#### Test 5: Monica Companion Title Display
- [ ] **Test**: `shouldDisplayMonicaCompanionTitle`
  - **Red**: Write test finding "Monica Companion" text
  - **Green**: Verify Text widget contains correct title
  - **Refactor**: Extract string constants if needed

#### Test 6: Tagline Display
- [ ] **Test**: `shouldDisplayCorrectTagline`
  - **Red**: Write test finding tagline text
  - **Green**: Verify "Personal relationships, perfectly managed" displays
  - **Refactor**: Extract tagline constant if needed

#### Test 7: Description Text Display
- [ ] **Test**: `shouldDisplayWelcomeDescription`
  - **Red**: Write test verifying description text exists
  - **Green**: Ensure welcome description renders properly
  - **Refactor**: Extract description text if needed

#### Test 8: Logo Rendering
- [ ] **Test**: `shouldRenderLogoWithCorrectHeight`
  - **Red**: Write test verifying SvgPicture height property
  - **Green**: Ensure logo renders with 120 height
  - **Refactor**: Extract logo configuration if needed

#### Test 9: Development Build Info
- [ ] **Test**: `shouldDisplayDevelopmentBuildInfo`
  - **Red**: Write test finding "Development Build" text
  - **Green**: Verify development info section exists
  - **Refactor**: Extract development info widget if needed

#### Test 10: Environment Display
- [ ] **Test**: `shouldDisplayCurrentEnvironment`
  - **Red**: Write test verifying environment name shows
  - **Green**: Ensure EnvironmentConfig.currentEnvironment displays
  - **Refactor**: Extract environment display logic if needed

#### Test 11: Package Name Display
- [ ] **Test**: `shouldDisplayPackageName`
  - **Red**: Write test verifying package name shows
  - **Green**: Ensure AppConfig.packageName displays correctly
  - **Refactor**: Extract package info display if needed

### Phase 3: Visual Theme Application (Score 4)

#### Test 12: Material Design 3 Theme
- [ ] **Test**: `shouldApplyMaterial3Theme`
  - **Red**: Write test verifying useMaterial3 is true
  - **Green**: Ensure ThemeData has useMaterial3: true
  - **Refactor**: Extract theme configuration if needed

#### Test 13: Monica Brand Colors
- [ ] **Test**: `shouldUseMonica BrandColorScheme`
  - **Red**: Write test verifying seed color is #6366F1
  - **Green**: Ensure ColorScheme.fromSeed uses correct color
  - **Refactor**: Extract color constants if needed

#### Test 14: Gradient Background
- [ ] **Test**: `shouldDisplayGradientBackground`
  - **Red**: Write test verifying LinearGradient exists
  - **Green**: Ensure DecoratedBox has gradient decoration
  - **Refactor**: Extract gradient configuration if needed

#### Test 15: Text Color Consistency
- [ ] **Test**: `shouldApplyWhiteTextColors`
  - **Red**: Write test verifying text uses white colors
  - **Green**: Ensure all text widgets use Colors.white variants
  - **Refactor**: Extract color helper methods if needed

### Phase 4: Error Handling & Resilience (Score 5)

#### Test 16: Missing Asset Handling
- [ ] **Test**: `shouldHandleMissingLogoAssetGracefully`
  - **Red**: Write test with invalid asset path
  - **Green**: Implement fallback or error handling for missing assets
  - **Refactor**: Extract asset error handling if needed

#### Test 17: Invalid Environment Handling
- [ ] **Test**: `shouldHandleInvalidEnvironmentConfig`
  - **Red**: Write test with malformed environment
  - **Green**: Implement proper error handling for config errors
  - **Refactor**: Extract error handling logic if needed

### Phase 5: Layout & Responsiveness (Score 3)

#### Test 18: SafeArea Implementation
- [ ] **Test**: `shouldImplementSafeAreaPadding`
  - **Red**: Write test verifying SafeArea widget exists
  - **Green**: Ensure SafeArea wraps main content
  - **Refactor**: Extract layout structure if needed

#### Test 19: Column Layout Structure
- [ ] **Test**: `shouldStructureContentInColumn`
  - **Red**: Write test verifying Column with proper children
  - **Green**: Ensure Column contains all required widgets
  - **Refactor**: Extract layout components if needed

#### Test 20: Spacer Distribution
- [ ] **Test**: `shouldDistributeSpaceWithSpacers`
  - **Red**: Write test verifying Spacer widgets placement
  - **Green**: Ensure Spacer widgets create proper spacing
  - **Refactor**: Extract spacing configuration if needed

## Test File Organization

```
test/
├── app_test.dart                    # Tests 1-2: App initialization
├── core/
│   └── config/
│       ├── app_config_test.dart     # Test 4: Configuration
│       └── environment_test.dart    # Test 17: Environment handling
├── features/
│   └── welcome/
│       ├── welcome_screen_test.dart # Tests 3, 5-11: Welcome screen
│       ├── theme_test.dart         # Tests 12-15: Theme application
│       └── layout_test.dart        # Tests 18-20: Layout structure
└── error_handling_test.dart        # Test 16: Error scenarios
```

## TDD Workflow Example

### Starting Test 1: `shouldLaunchAppWithoutCrashing`

**RED Phase:**
```dart
test('should launch app without crashing', () {
  expect(() => runApp(const MonicaApp()), returnsNormally);
});
```

**GREEN Phase:**
- Verify main.dart has proper runApp() call
- Ensure MonicaApp widget exists and is properly constructed
- Add minimum code to make test pass

**REFACTOR Phase:**
- Extract app initialization logic if duplicated
- Improve naming or structure while keeping tests green

## Commit Strategy

1. **Structural Commits**: "refactor: extract welcome screen constants"
2. **Behavioral Commits**: "test: add welcome screen title display verification"
3. **Each commit**: All tests passing, no lint warnings

## Success Criteria

- [ ] All 20 tests implemented following TDD cycle
- [ ] 100% test coverage for welcome screen functionality
- [ ] Zero failing tests
- [ ] Zero lint warnings
- [ ] Proper separation of structural vs behavioral changes
- [ ] Clean, maintainable test code with clear naming

## Next Steps

When ready, say "go" to start with Test 1. I will:
1. Write the failing test (RED)
2. Implement minimum code to pass (GREEN)
3. Refactor for clean structure
4. Commit changes
5. Move to next test

Each test will be completed fully before moving to the next one, following strict TDD discipline.