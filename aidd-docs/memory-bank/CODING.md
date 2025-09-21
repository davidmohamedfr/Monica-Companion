# Coding Guidelines

> Those rules must be minimal because they MUST be checked after EVERY CODE GENERATION.

## Requirements to complete a feature

In order to complete a feature at its best, always check at the end of the implementation:

- [ ] Whole plan is implemented in code (no omissions)
- [ ] All technical rules are followed
- [ ] Pre-commit hooks pass (`lefthook run pre-commit`)
- [ ] Build is successful (`make build-debug`)
- [ ] All tests pass (unit + integration)

**A feature is really completed if ALL of the above are satisfied: if not, iterate to fix all until all are green.**

### Stack specifics rules (Flutter/Dart)

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

### Build system rules

- [ ] Android build configuration supports dev environment flavor
- [ ] Makefile commands execute without errors:
  - [ ] `make deps` (flutter pub get)
  - [ ] `make analyze` (dart analyze --fatal-warnings)
  - [ ] `make format` (dart format .)
  - [ ] `make test` (flutter test)
  - [ ] `make build-debug` (flutter build apk --debug)

### Git workflow rules

- [ ] Pre-commit hooks configured and passing:
  - [ ] `dart format` auto-formats staged files
  - [ ] `dart analyze --fatal-warnings` blocks commits with issues
- [ ] All Dart files formatted before commit
- [ ] No build artifacts committed (excluded in .gitignore)

### Project structure rules (MonicaHQ Mobile App)

- [ ] Feature-first organization maintained:
  - [ ] `lib/features/` contains feature modules
  - [ ] `lib/core/` contains shared utilities
  - [ ] `lib/services/` contains external service integrations
  - [ ] `test/` mirrors `lib/` structure
- [ ] Dependencies properly declared in `pubspec.yaml`
- [ ] Analysis options enforce project code style standards
- [ ] Environment configuration uses build flavors (dev/staging/prod)

### CI/CD Code Quality

- [ ] Environment variables for version management prevent inconsistencies
- [ ] Test cases must validate actual implementation behavior
- [ ] Job dependencies ensure proper failure propagation
- [ ] Caching strategies improve pipeline performance
- [ ] Flutter/Dart versions consistent across all CI jobs
- [ ] Android minSdkVersion set to 24 (Android 7.0) minimum
- [ ] Build artifacts generated and stored with appropriate retention