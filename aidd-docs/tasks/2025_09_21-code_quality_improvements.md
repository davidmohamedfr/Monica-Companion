# Instruction: Code Quality Improvements for Monica Companion

## Feature

- **Summary**: Address code quality issues identified in review - remove unused imports, replace deprecated methods, add type annotations, and fix line length violations
- **Stack**: `Flutter 3.35.4, Dart 3.8.0, Material Design 3`

## Existing files

- @lib/main.dart
- @analysis_options.yaml

### New file to create

- None

## Implementation phases

### Phase 1: Clean unused imports

> Remove unused import statements to reduce code clutter

1. Remove unused `package:monica_companion/config/feature_flags.dart` from main.dart
2. Verify no other unused imports exist
3. Run flutter analyze to confirm no import warnings

### Phase 2: Replace deprecated methods

> Update deprecated withOpacity() calls to modern withValues() API

1. Replace all 8 withOpacity() calls in WelcomeScreen widget
2. Use proper withValues() syntax for color opacity
3. Test visual appearance remains identical

### Phase 3: Add type annotations

> Add missing explicit type annotations for better type safety

1. Add type annotation for gradient colors list at line 36
2. Add type annotation for Column children at line 47
3. Add type annotation for Column children at line 120
4. Verify all types match actual usage

### Phase 4: Fix line length violations

> Break long lines to comply with 80-character limit

1. Break line 100 (Welcome message) into multiple lines
2. Break line 101 (Description text) into multiple lines
3. Maintain readability with proper indentation
4. Verify formatting with dart format

## Reviewed implementation

- [ ] Phase 1: Clean unused imports
- [ ] Phase 2: Replace deprecated methods
- [ ] Phase 3: Add type annotations
- [ ] Phase 4: Fix line length violations

## Validation flow

1. Run `flutter analyze --fatal-warnings` and confirm zero issues
2. Run `dart format lib/main.dart` and verify no changes needed
3. Build debug APK with `flutter build apk --debug`
4. Launch app and verify welcome screen displays correctly
5. Verify all text and colors appear as before changes
6. Check that development info still shows at bottom
7. Confirm APK size remains similar (±1MB)

## Estimations

- **Confidence**: 9.5/10 - Simple refactoring tasks with clear requirements
- **Time to implement**: 15-20 minutes