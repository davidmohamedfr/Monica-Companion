# Instruction: Fix CI/CD Flutter Version Issue

## Feature

- **Summary**: Fix GitHub Actions CI pipeline to use correct Flutter version 3.35.3 and resolve dependency installation failures
- **Stack**: `Flutter 3.35.3, GitHub Actions, subosito/flutter-action@v2`

## Existing files

- @.github/workflows/lint.yml
- @pubspec.yaml

### New file to create

- None

## Implementation phases

### Phase 1: Update CI workflow configuration

> Replace flutter-version-file parameter with explicit version specification

1. Update Flutter setup action in lint.yml analyze job
2. Update Flutter setup action in test job
3. Update Flutter setup action in build job
4. Remove flutter-version-file parameter from all jobs
5. Add explicit flutter-version: '3.35.3' parameter

### Phase 2: Clear and verify cache

> Ensure clean Flutter installation without cached incorrect versions

1. Add cache-key parameter with version-specific identifier
2. Test workflow execution with cleared cache
3. Verify Flutter version output in CI logs

### Phase 3: Add version validation

> Add safeguards to prevent future version mismatches

1. Add Flutter version verification step after setup
2. Fail fast if version doesn't match expected 3.35.3
3. Document version management approach in workflow comments

## Reviewed implementation

- [ ] Phase 1
- [ ] Phase 2
- [ ] Phase 3

## Validation flow

1. Push changes to feature branch
2. Check GitHub Actions workflow runs successfully
3. Verify "Get dependencies" step passes without errors
4. Confirm Flutter version 3.35.3 is used in CI logs
5. Ensure all jobs (analyze, test, build) complete successfully
6. Merge to main branch and verify workflow runs

## Estimations

- Confidence: 9/10 - Clear issue with straightforward solution
- Time to implement: 30 minutes