# Linting and Code Quality

This document describes the linting configuration and code quality standards for the Monica Mobile App.

## Quick Setup

After git pull, run:
```bash
make setup-linting
```

Or manually:
```bash
chmod +x scripts/setup-linting.sh
./scripts/setup-linting.sh
```

## Overview

The project uses strict Dart/Flutter linting rules to ensure code quality, consistency, and maintainability.

## Configuration Files

- `analysis_options.yaml` - Main linting configuration with all recommended rules
- `.vscode/settings.json` - VS Code specific settings for real-time linting
- `.idea/codeStyles/` - Android Studio/IntelliJ code style settings
- `.idea/inspectionProfiles/` - IDE inspection profiles

## Linting Rules

The project enforces:
- All recommended Flutter lints
- Strict type checking (no implicit casts, dynamic, or raw types)
- 80 character line length limit
- Trailing commas required
- Consistent code formatting
- Import organization

## Local Development

### Running Linter Manually

```bash
# Analyze code for issues
dart analyze

# Format code
dart format .

# Check formatting without changing files
dart format --output=none --set-exit-if-changed .

# Fix auto-fixable issues
dart fix --apply
```

### IDE Configuration

**VS Code:**
- Templates in `templates/ide/vscode-settings.json`
- Deployed automatically by setup script
- Real-time linting feedback, format on save, 80-char ruler

**Android Studio/IntelliJ:**
- Templates in `templates/ide/android-studio-*.xml`
- Deployed automatically by setup script  
- 2-space indentation, 80-char margin, enhanced inspections

## CI/CD Integration

The GitHub Actions workflow (`.github/workflows/lint.yml`) runs:
1. Code formatting verification
2. Static analysis with fatal warnings
3. Custom Flutter lints
4. Dependency security audit

## Common Issues and Solutions

### Long Lines
- Break long parameter lists across multiple lines
- Use trailing commas to improve formatting
- Split long strings or expressions

### Import Organization
- Group imports: dart, flutter, package, relative
- Use `dart fix --apply` to auto-organize

### Type Safety
- Always specify types for public APIs
- Use `late` keyword appropriately
- Avoid `dynamic` and implicit casts

## Suppressing Warnings

Only suppress warnings when absolutely necessary:

```dart
// ignore: rule_name
problematic_code();

// ignore_for_file: rule_name
```

## Local Customization

You can create a `lefthook-local.yml` file for personal git hooks while still running the main linting configuration:

```bash
# Copy the template
cp lefthook-local.yml.template lefthook-local.yml

# Edit for your local needs
# The template ensures main lefthook.yml still runs after your local commands
```

The `lefthook-local.yml` file is gitignored so your personal hooks won't affect the team.

## Contributing

- All code must pass linting before merge
- CI/CD will fail on any linting violations
- Use provided IDE configurations for consistent experience
- Run `dart analyze` locally before pushing