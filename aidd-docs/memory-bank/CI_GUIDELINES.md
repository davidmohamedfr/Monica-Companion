# CI/CD Implementation Guidelines

## Version Management

### Consistency Rules
- Use environment variables for all version specifications across CI jobs
- Pin Flutter/Dart versions in pubspec.yaml and reference in CI workflows
- Validate version consistency across all workflow jobs during implementation
- Never hardcode versions in individual job steps

### Example Implementation
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

## Test Strategy

### Test-Implementation Alignment
- Align test expectations with actual implementation behavior
- Fix tests when implementation is correct, not vice versa
- Validate test cases against business requirements before implementation
- Use descriptive test names that reflect actual behavior

### Test Organization
- Separate unit tests from integration tests in CI jobs
- Run fast tests (lint, unit) before slow tests (integration, build)
- Provide clear failure messages and debugging information
- Use test randomization to catch order-dependent failures

### Example Test Structure
```dart
group('isNotEmpty', () {
  test('should return true for non-empty strings', () {
    // Test actual implementation behavior, not assumptions
    expect(Validators.isNotEmpty('test with spaces'), isTrue);
  });
});
```

## Build Configuration

### Android Requirements
- Android minSdk should target reasonable compatibility (API 24+ recommended)
- Generate Android project files if missing via `flutter create --platforms android`
- Configure minSdkVersion explicitly in build.gradle.kts
- Support multiple environment branches (main, dev, staging)

### Platform Support
- Document which platforms are currently supported (Android-only vs multi-platform)
- Use appropriate build commands for target platforms
- Handle platform-specific configuration in CI

### Example Android Configuration
```kotlin
// android/app/build.gradle.kts
defaultConfig {
    minSdk = 24  // Android 7.0 for modern features
    targetSdk = flutter.targetSdkVersion
}
```

## Job Dependencies

### Pipeline Structure
- Structure jobs in logical order: lint → test → build → integration
- Use proper `needs` declarations for job sequencing
- Include all relevant jobs in final integration step
- Ensure proper failure propagation through dependency chain

### Parallel Execution
- Run independent jobs in parallel for performance
- Group related checks in single jobs when beneficial
- Use job matrices for multi-platform builds
- Balance parallelism with resource constraints

### Example Job Structure
```yaml
jobs:
  lint: # Fast feedback
  test: # Parallel with lint
  build:
    needs: [lint, test] # Only after quality gates
  integration:
    needs: [lint, test, build] # Final validation
```

## Performance Optimization

### Caching Strategy
- Cache Flutter SDK installations across jobs
- Cache Gradle dependencies for Android builds
- Cache pub dependencies between runs
- Use appropriate cache keys for invalidation

### Timeout Management
- Set reasonable timeouts for each job type
- Allow longer timeouts for integration tests and builds
- Monitor actual execution times and adjust accordingly
- Fail fast on obvious errors

### Artifact Management
- Upload build artifacts for debugging
- Set appropriate retention periods (7 days for debug builds)
- Compress large artifacts when possible
- Store coverage reports and test results

## Error Handling

### Failure Scenarios
- Handle missing dependencies gracefully
- Provide clear error messages for common failures
- Include troubleshooting information in CI output
- Use conditional execution to prevent cascading failures

### Debug Information
- Log important configuration values
- Include version information in CI output
- Capture relevant logs for failed builds
- Provide links to relevant documentation

## Environment Configuration

### Branch Strategy
- Support development workflows with multiple branches
- Configure appropriate triggers for different branch types
- Use environment-specific configurations when needed
- Document branch protection rules and requirements

### Secret Management
- Use GitHub secrets for sensitive configuration
- Avoid hardcoding credentials or tokens in workflows
- Document required secrets for project setup
- Use least-privilege access for CI tokens

## Quality Gates

### Code Quality Checks
- Enforce formatting consistency across all code
- Run static analysis with appropriate error levels
- Check for security vulnerabilities in dependencies
- Validate documentation and code comments

### Test Coverage
- Monitor test coverage trends over time
- Set reasonable coverage thresholds (60%+ recommended)
- Generate coverage reports as artifacts
- Include coverage information in PR comments

### Build Verification
- Verify builds complete successfully for target platforms
- Check build artifact sizes and warn on excessive growth
- Validate app startup and basic functionality
- Test deployment readiness for release builds