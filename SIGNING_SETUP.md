# APK Signing Setup Documentation

## Overview

This document describes the APK signing configuration for Monica Companion to resolve the "package is invalid" error on Android 14+ devices.

## Problem

Previously, the release APK was built without proper signing configuration, causing Android 14+ to reject installation with "package is invalid" error. Android 14 has stricter APK validation and rejects debug-signed release APKs.

## Solution

Implemented proper APK signing with release keystore for both local and CI/CD builds.

---

## Local Development Setup

### 1. Keystore File

**Location**: `android/monica-companion-release.jks`

**Details**:
- **Key Alias**: monica-companion
- **Validity**: 10,000 days (~27 years)
- **Algorithm**: RSA 2048-bit
- **Password**: MonicaCompanion2025!

### 2. Key Properties File

**Location**: `android/key.properties` (gitignored)

**Content**:
```properties
storePassword=MonicaCompanion2025!
keyPassword=MonicaCompanion2025!
keyAlias=monica-companion
storeFile=monica-companion-release.jks
```

### 3. Build Configuration

**File**: `android/app/build.gradle`

**Changes**:
- Added keystore properties loading
- Added `signingConfigs.release` block
- Updated release buildType to reference signing config

### 4. Build Release APK Locally

```bash
flutter build apk --release
```

The APK will be properly signed and installable on Android 14+ devices.

---

## CI/CD (GitLab) Setup

### Required GitLab CI/CD Variables

Add these as **Protected** and **Masked** variables in GitLab Project Settings → CI/CD → Variables:

1. **KEYSTORE_BASE64**
   - Type: Variable
   - Protected: ✅ Yes
   - Masked: ❌ No (too long for masking)
   - Value: (see below for generation)

2. **KEYSTORE_PASSWORD**
   - Type: Variable
   - Protected: ✅ Yes
   - Masked: ✅ Yes
   - Value: `MonicaCompanion2025!`

3. **KEY_PASSWORD**
   - Type: Variable
   - Protected: ✅ Yes
   - Masked: ✅ Yes
   - Value: `MonicaCompanion2025!`

4. **KEY_ALIAS**
   - Type: Variable
   - Protected: ✅ Yes
   - Masked: ✅ Yes
   - Value: `monica-companion`

### Generate KEYSTORE_BASE64 Value

```bash
base64 -i android/monica-companion-release.jks
```

**Base64 Encoded Keystore**:
```
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
```

Copy this entire base64 string to the `KEYSTORE_BASE64` variable in GitLab.

### Pipeline Workflow

The `.gitlab-ci.yml` release job now:
1. Decodes the base64 keystore
2. Creates `key.properties` with CI/CD variables
3. Builds a properly signed release APK

---

## Security Considerations

### Files to Keep Secure (Never Commit)

- ✅ `android/key.properties` - Already in `.gitignore`
- ✅ `android/monica-companion-release.jks` - Already in `.gitignore`

### GitLab Variables Security

- All signing variables should be **Protected** (only available on protected branches/tags)
- Password variables should be **Masked** (hidden in logs)
- KEYSTORE_BASE64 cannot be masked (too long), but is protected

---

## Verification

### Test Local Build

```bash
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

Should install successfully on Android 14+ without "package is invalid" error.

### Test CI/CD Build

1. Add all required variables to GitLab CI/CD settings
2. Create a new version tag: `git tag v0.1.9 && git push origin v0.1.9`
3. Monitor pipeline execution
4. Download release APK from GitLab releases
5. Install on Android 14+ device

---

## Regenerating Keystore (If Needed)

⚠️ **WARNING**: Regenerating the keystore means users cannot update the app without uninstalling first. Only do this if absolutely necessary.

```bash
cd android
keytool -genkey -v -keystore monica-companion-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias monica-companion \
  -dname "CN=Monica Companion, OU=Development, O=M0hda Corp, L=Paris, ST=IDF, C=FR"
```

Then update:
1. `key.properties` with new passwords/alias
2. GitLab CI/CD variables with new keystore base64 and credentials
3. `build.gradle` if alias changed

---

## Troubleshooting

### "package is invalid" error persists

- Verify `key.properties` exists and has correct paths
- Verify keystore file exists at specified location
- Check keystore passwords match in `key.properties`
- Ensure build.gradle has `signingConfig signingConfigs.release` in release buildType

### CI/CD build fails with signing error

- Verify all 4 GitLab variables are set correctly
- Check KEYSTORE_BASE64 is the complete base64 string
- Ensure variables are set as **Protected** and available on tags
- Check pipeline logs for specific error messages

### Cannot install APK after signing fix

- Uninstall old debug-signed version first
- Old and new versions have different signatures
- Clean install required for first signed release

---

## References

- [Flutter Android Signing Documentation](https://flutter.dev/to/reference-keystore)
- [Android Code Signing Guide](https://developer.android.com/studio/publish/app-signing)
- [GitLab CI/CD Variables](https://docs.gitlab.com/ee/ci/variables/)
