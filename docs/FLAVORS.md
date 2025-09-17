# Environment Flavors Documentation

## Overview

This project supports environment-based flavors for development, staging, and production builds. Currently, only the **development flavor** is fully configured and ready for use.

## Current Configuration (Development Only)

### Available Environment
- **dev**: Development environment with debug features enabled

### Environment Configuration

The environment system is designed to be extensible. To add staging and production flavors later:

1. Update the Gradle build configuration
2. Add new flavor definitions in `android/app/build.gradle`
3. The Dart environment system is already ready for multiple environments

### Current Features

#### API Endpoints
- **Dev**: `https://dev-api.monica.com` (configurable via `--dart-define`)

#### App Names
- **Dev**: "Monica Dev"

#### Feature Flags
- **Debug Tools**: Enabled in dev
- **Console Logging**: Enabled in dev
- **Mock Data**: Configurable via build args
- **Experimental Features**: Enabled in dev

## Build Commands

### Development Build
```bash
flutter run --flavor dev --dart-define=FLAVOR=development
```

### With Custom API URL
```bash
flutter run --flavor dev --dart-define=FLAVOR=development --dart-define=API_BASE_URL=http://localhost:3000
```

### With Mock Data
```bash
flutter run --flavor dev --dart-define=FLAVOR=development --dart-define=ENABLE_MOCK_DATA=true
```

## Adding More Flavors

When ready to add staging and production:

1. **Update Gradle** (`android/app/build.gradle`):
   - Uncomment staging and prod flavor configurations
   - Configure signing for production

2. **Test Build Commands**:
   ```bash
   # Staging
   flutter run --flavor staging --dart-define=FLAVOR=staging
   
   # Production
   flutter run --flavor prod --dart-define=FLAVOR=production
   ```

3. **Configure Release Signing**:
   - Generate production keystore
   - Update signing configuration in Gradle

## Configuration Files

- **Environment**: `lib/core/config/environment.dart`
- **Feature Flags**: `lib/config/feature_flags.dart`
- **App Config**: `lib/core/config/app_config.dart`
- **Gradle**: `android/app/build.gradle`

## Testing Configuration

To verify the current environment configuration is working:

1. Run the dev flavor
2. Check the app displays "Monica Dev" 
3. Verify the environment info screen shows correct values
4. Test feature flags are applied correctly