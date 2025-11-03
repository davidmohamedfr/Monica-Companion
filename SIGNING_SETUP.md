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
keytool -genkeypair -v -keystore monica-companion-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias monica-companion \
  -storepass "MonicaCompanion2025!" \
  -keypass "MonicaCompanion2025!" \
  -dname "CN=Monica Companion, OU=Development, O=M0hda Corp, L=Paris, ST=IDF, C=FR" \
  -storetype JKS
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
