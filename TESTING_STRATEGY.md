# Monica Companion - Comprehensive Testing Strategy

This document outlines our multi-layered testing approach to ensure code quality at every stage of development.

## 🎯 Testing Philosophy

**Quality Gates at Every Stage:**
- 📝 **Pre-commit**: Quality checks before any commit
- 🧪 **Pre-push**: Unit tests before any push
- 🚀 **PR/CI**: Integration tests, device tests, and comprehensive validation

## 🛠️ Setup Instructions

### For New Team Members

1. **Install Lefthook** (one-time setup):
   ```bash
   # macOS
   brew install lefthook

   # Or download from: https://github.com/evilmartians/lefthook
   ```

2. **Install project hooks**:
   ```bash
   lefthook install
   ```

3. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

## 📋 Testing Stages

### Stage 1: Pre-commit (Quality Checks)

**Runs automatically before every commit**

✅ **Code Formatting**
- Auto-formats Dart files using `flutter format`
- Files are automatically staged after formatting

✅ **Lint Analysis**
- Comprehensive analysis with `flutter analyze --fatal-infos --fatal-warnings`
- Enforces coding standards and best practices

✅ **Debug Statement Check**
- Prevents `print()` and `debugPrint()` in production code
- Encourages proper logging practices

✅ **Dependency Verification**
- Validates `pubspec.yaml` and dependency resolution
- Ensures project can build successfully

### Stage 2: Pre-push (Unit Testing)

**Runs automatically before every push**

🧪 **Dependency Update**
- Ensures latest dependencies with `flutter pub get`

🧪 **Unit & Widget Tests**
- Runs complete test suite with `flutter test --coverage`
- Generates coverage reports
- Fails if any tests fail

🧪 **Coverage Verification**
- Confirms test coverage report generation
- Optional: Can be configured with coverage thresholds

### Stage 3: CI/PR (Comprehensive Validation)

**Runs on every Pull Request**

🚀 **Integration Tests**
- Real device testing on Android emulator
- End-to-end application flow validation
- UI interaction testing

🚀 **Build Verification**
- Android APK build validation
- Size optimization checks
- Deployment readiness verification

🚀 **Cross-platform Compatibility**
- Multi-OS testing (Linux/Ubuntu)
- Different Flutter/Dart versions

## 🔧 Emergency Bypass

For urgent fixes, you can skip hooks:

```bash
# Skip all hooks for emergency commit
LEFTHOOK=0 git commit -m "hotfix: critical security patch"

# Skip all hooks for emergency push
LEFTHOOK=0 git push
```

## 📊 Manual Testing Commands

Run tests manually when needed:

```bash
# Run pre-commit checks manually
lefthook run pre-commit

# Run pre-push checks manually
lefthook run pre-push

# Run specific test suites
flutter test                          # Unit tests
flutter test integration_test/        # Integration tests
flutter test --coverage               # With coverage

# Quality checks
flutter analyze --fatal-infos --fatal-warnings
flutter format --output=none --set-exit-if-changed .
```

## 🎨 Commit Message Standards

We enforce [Conventional Commits](https://www.conventionalcommits.org/):

```bash
feat: add user authentication
fix: resolve memory leak in image loading
docs: update API documentation
test: add integration tests for login flow
refactor: simplify database connection logic
style: format code according to style guide
chore: update dependencies
```

## 📈 Coverage and Quality Metrics

### Current Status
- **Unit Tests**: 41 tests covering core functionality
- **Integration Tests**: 2 comprehensive end-to-end tests
- **Lint Compliance**: 0 issues (strict mode)
- **Code Coverage**: Generated with every test run

### Quality Targets
- 🎯 **Test Coverage**: Maintain comprehensive coverage
- 🎯 **Lint Issues**: Zero tolerance policy
- 🎯 **Build Success**: 100% CI pass rate
- 🎯 **Performance**: APK size monitoring

## 🚨 Troubleshooting

### Common Issues

**"Lefthook not found"**
```bash
brew install lefthook
lefthook install
```

**"Flutter not found"**
```bash
# Ensure Flutter is in PATH
export PATH="$PATH:/path/to/flutter/bin"
```

**"Tests failing locally but passing in CI"**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter test
```

**"Formatting issues"**
```bash
# Auto-fix formatting
flutter format .
git add .
```

## 📝 Team Workflow

### Standard Development Flow

1. **Create feature branch**: `git checkout -b feature/awesome-feature`
2. **Make changes**: Code, test, iterate
3. **Commit**: `git commit -m "feat: awesome feature"` (triggers pre-commit)
4. **Push**: `git push` (triggers pre-push with unit tests)
5. **Create PR**: Opens pull request (triggers comprehensive CI)
6. **Review & Merge**: After all checks pass

### Quality Assurance

- ✅ **Every commit** passes formatting and lint checks
- ✅ **Every push** has passing unit tests
- ✅ **Every PR** includes integration and device testing
- ✅ **No broken builds** reach main/dev branches

## 🔄 Continuous Improvement

This testing strategy evolves with the project:

- **Performance testing** for mobile-specific metrics
- **Accessibility testing** for inclusive design
- **Security testing** for vulnerability scanning
- **UI testing** with visual regression detection

## 📞 Support

For questions about the testing strategy:
- Check this documentation first
- Review existing test examples in `/test` and `/integration_test`
- Consult team members for complex testing scenarios

---

**Remember**: These tools exist to help maintain quality and catch issues early. They save time by preventing bugs from reaching production! 🛡️