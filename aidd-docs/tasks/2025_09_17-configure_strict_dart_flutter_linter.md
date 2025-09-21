# Instruction: Configure Strict Dart/Flutter Linter

## Feature

- **Summary**: Set up comprehensive strict linting configuration for Dart/Flutter project with all recommended rules, integrated in local development and CI/CD pipeline
- **Stack**: `Dart SDK, Flutter SDK, analysis_options.yaml, CI/CD (GitHub Actions/etc)`

## Existing files

- @analysis_options.yaml (if exists - to be replaced)
- @.github/workflows/* (CI/CD files to be updated)
- @**/*.dart (all Dart source files to be validated)

### New file to create

- analysis_options.yaml (comprehensive linting configuration)
- .github/workflows/lint.yml (if CI/CD workflow doesn't exist)

## Implementation phases

### Phase 1

> Configure comprehensive linting rules with all recommended standards

1. Create analysis_options.yaml with strict recommended rule sets
2. Configure lint rules for maximum code quality enforcement
3. Set appropriate severity levels for different rule categories
4. Include Flutter-specific linting rules

### Phase 2

> Resolve all existing code violations to achieve clean baseline

1. Run dart analyze to identify all current violations
2. Apply automatic fixes using dart fix --apply
3. Manually resolve remaining linting violations
4. Verify project passes all linting checks

### Phase 3

> Integrate linting into CI/CD pipeline for automated enforcement

1. Add linting step to existing CI/CD workflow
2. Configure pipeline to fail builds on linting errors
3. Test CI/CD integration with sample violations
4. Ensure linting runs on all pull requests

### Phase 4

> Configure development environment for real-time linting feedback

1. Configure IDE/editor settings for immediate linting feedback
2. Document linting workflow and standards for development team
3. Verify local development tools respect linting configuration

## Reviewed implementation

<!-- That section is filled by a review agent that ensures feature has been properly implemented -->

- [ ] Phase 1
- [ ] Phase 2
- [ ] Phase 3
- [ ] Phase 4

## Validation flow

<!-- What would a REAL user do to 100% validate the feature? -->

1. Run dart analyze and verify zero violations
2. Introduce intentional code style violation and verify it's caught
3. Test CI/CD pipeline rejects code with linting errors
4. Verify IDE shows real-time linting feedback during development
5. Confirm team can follow documented linting standards

## Estimations

- High confidence (9/10) - standard configuration with well-documented tools
- 2-4 hours implementation time (depending on existing code violations)