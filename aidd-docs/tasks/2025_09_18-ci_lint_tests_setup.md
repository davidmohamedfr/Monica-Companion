# Instruction: Setup Lint + tests for CI

## Feature

- **Summary**: Configure GitHub Actions CI/CD pipeline with linting, testing, and Android build verification for Flutter mobile app to ensure code quality on every commit
- **Stack**: `Flutter >=3.13.0, Dart >=3.1.0, GitHub Actions, Android SDK (minSdkVersion: 24 - Android 7.0)`

## Existing files

- @pubspec.yaml
- @analysis_options.yaml
- @.gitignore

### New file to create

- .github/workflows/ci.yml
- .github/workflows/pr_checks.yml

### Note

- Android directory remains untracked in git
- CI will generate Android build files dynamically

## Implementation phases

### Phase 1: GitHub Actions Workflow Setup

> Create CI infrastructure and Flutter environment

1. Create `.github/workflows` directory structure
2. Define main CI workflow with push/PR triggers
3. Configure Flutter SDK setup with caching
4. Set up dependency installation with pub cache

### Phase 2: Linting Configuration

> Implement code quality checks

1. Add Dart analyzer step with strict mode
2. Configure format checking with `dart format`
3. Set failure conditions for lint violations
4. Generate lint reports as artifacts

### Phase 3: Test Execution Pipeline

> Configure automated testing

1. Run Flutter unit and widget tests
2. Generate test coverage reports
3. Upload test results and coverage artifacts
4. Set minimum coverage thresholds

### Phase 4: Build Verification

> Validate Android app build

1. Configure Android APK debug build (minSdkVersion: 24 - Android 7.0)
2. Cache Gradle dependencies
3. Verify successful build completion
4. Store APK as artifact for testing

### Phase 5: PR Integration

> Integrate with GitHub PR workflow

1. Configure required status checks
2. Add workflow badges to repository
3. Set branch protection rules
4. Configure failure notifications

## Reviewed implementation

- [ ] Phase 1: GitHub Actions Workflow Setup
- [ ] Phase 2: Linting Configuration
- [ ] Phase 3: Test Execution Pipeline
- [ ] Phase 4: Build Verification
- [ ] Phase 5: PR Integration

## Validation flow

1. Create a test branch and push code with lint error
2. Verify CI fails on lint error
3. Fix lint error and push again
4. Create failing test and verify CI catches it
5. Fix test and verify all checks pass
6. Create PR and confirm status checks block merge
7. Verify Android build completes successfully
8. Check workflow execution time with caching

## Estimations

- Confidence: 9.5/10
- Time to implement: 1.5-2 hours