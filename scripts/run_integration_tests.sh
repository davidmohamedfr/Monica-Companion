#!/bin/bash
set -e

# Script to run integration tests with automatic permission granting
#
# Problem: `flutter test integration_test/` and `flutter drive` lose runtime
#          permissions when app is reinstalled during test execution
#
# Solution: Run permission monitor in background that continuously grants
#           permissions during test execution. Tests are run individually
#           to avoid Flutter framework rendering errors during batch teardown.
#
# Usage: ./scripts/run_integration_tests.sh [device-id] [--apk-path <path>]
# Examples:
#   ./scripts/run_integration_tests.sh
#   ./scripts/run_integration_tests.sh emulator-5556
#   ./scripts/run_integration_tests.sh --apk-path build/app/outputs/flutter-apk/app-debug.apk
#   ./scripts/run_integration_tests.sh emulator-5556 --apk-path /path/to/app-debug.apk

# Parse arguments
DEVICE_ID=""
APK_PATH=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --apk-path)
      APK_PATH="$2"
      shift 2
      ;;
    *)
      if [ -z "$DEVICE_ID" ]; then
        DEVICE_ID="$1"
      fi
      shift
      ;;
  esac
done

PACKAGE_NAME="fr.m0hdaCorp.monica_companion"
READ_PERMISSION="android.permission.READ_CONTACTS"
WRITE_PERMISSION="android.permission.WRITE_CONTACTS"

# List of test files to run individually
TEST_FILES=(
  "integration_test/app_test.dart"
  "integration_test/contact_edit_button_test.dart"
  "integration_test/contacts_simple_test.dart"
  "integration_test/database_integration_test.dart"
)

echo "🚀 Running integration tests individually with auto-granted permissions"
echo "   Device: ${DEVICE_ID:-auto}"
echo "   Tests: ${#TEST_FILES[@]} files"
echo ""

# Determine APK path
if [ -n "$APK_PATH" ]; then
  # Validate provided APK path
  if [ ! -f "$APK_PATH" ]; then
    echo "❌ Error: APK file not found at: $APK_PATH"
    exit 1
  fi
  echo "Using pre-built APK: $APK_PATH"
else
  # Build APK if not provided (fail fast if build fails)
  echo "Building APK..."
  "$(dirname "$0")/flutter_with_env.sh" build apk --debug
  APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
fi

# Check for connected devices and start emulator if needed
EMULATOR_STARTED=false
EMULATOR_PID=""
AVD_NAME="test_integration_avd"

echo "🔍 Checking for connected devices..."
DEVICE_COUNT=$(adb devices | grep -c "device$" || true)

if [ "$DEVICE_COUNT" -eq 0 ]; then
  echo "⚠️  No devices connected. Starting emulator..."

  # Setup Android SDK paths
  export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"

  # Detect host architecture and select appropriate system image
  HOST_ARCH=$(uname -m)
  if [[ "$HOST_ARCH" == "arm64" || "$HOST_ARCH" == "aarch64" ]]; then
    # Use AOSP (default) for ARM64 - Google APIs not available for ARM64
    SYSTEM_IMAGE="system-images;android-34;default;arm64-v8a"
    ABI="default/arm64-v8a"
    API_LEVEL="34"
    echo "🔍 Detected ARM64 host (Apple Silicon) - using API 34 AOSP arm64-v8a emulator"
    echo "ℹ️  Note: Using AOSP image (Google APIs not available for ARM64)"
  else
    SYSTEM_IMAGE="system-images;android-30;google_apis;x86_64"
    ABI="google_apis/x86_64"
    API_LEVEL="30"
    echo "🔍 Detected x86_64 host - using API 30 x86_64 emulator with Google APIs"
  fi

  # Install system image if not present
  echo "📥 Ensuring system image is installed..."
  yes | sdkmanager --licenses 2>/dev/null || true
  sdkmanager "$SYSTEM_IMAGE" 2>/dev/null || echo "System image may already be installed"

  # Delete existing test AVD if present
  echo "🗑️  Removing any existing test AVD..."
  avdmanager delete avd --name "$AVD_NAME" 2>/dev/null || true

  # Create fresh AVD
  echo "📲 Creating test AVD..."
  echo "no" | avdmanager create avd --force \
    --name "$AVD_NAME" \
    --package "$SYSTEM_IMAGE" \
    --device "pixel_4" \
    --abi "$ABI"

  # Start emulator in background
  echo "🚀 Starting emulator..."
  nohup "$ANDROID_HOME/emulator/emulator" -avd "$AVD_NAME" \
    -no-window -no-audio -no-boot-anim \
    -gpu swiftshader_indirect -accel off \
    -camera-back none -camera-front none \
    > /tmp/emulator.log 2>&1 &
  EMULATOR_PID=$!
  EMULATOR_STARTED=true
  echo "✅ Emulator started (PID: $EMULATOR_PID)"

  # Wait for emulator to boot
  echo "⏳ Waiting for emulator to boot (max 15 minutes)..."
  timeout 900 adb wait-for-device || { echo "❌ Emulator device not detected"; kill $EMULATOR_PID 2>/dev/null; exit 1; }
  echo "⏳ Waiting for boot to complete..."
  timeout 600 adb shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done' || {
    echo "❌ Emulator boot timeout"
    kill $EMULATOR_PID 2>/dev/null
    exit 1
  }

  # Wait for package manager to stabilize
  echo "📦 Waiting for package manager service..."
  timeout 180 adb shell 'while ! pm list packages > /dev/null 2>&1; do sleep 2; done' || echo "⚠️ PM check timed out"
  sleep 30
  echo "✅ Emulator ready!"

  # Get the emulator device ID
  DEVICE_ID=$(adb devices | grep "emulator" | awk '{print $1}' | head -1)
  echo "📱 Using emulator device: $DEVICE_ID"
else
  echo "✅ Found $DEVICE_COUNT connected device(s)"
  if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID=$(adb devices | grep "device$" | awk '{print $1}' | head -1)
    echo "📱 Using device: $DEVICE_ID"
  fi
fi

# Install with permissions
echo "Installing APK with permissions..."
if [ -n "$DEVICE_ID" ]; then
  adb -s "$DEVICE_ID" install -g "$APK_PATH"
else
  adb install -g "$APK_PATH"
fi

# Wait for package manager to stabilize after APK installation
echo "📦 Waiting for package manager to stabilize after installation..."
sleep 5  # Brief initial wait
if [ -n "$DEVICE_ID" ]; then
  timeout 60 adb -s "$DEVICE_ID" shell 'while ! pm list packages > /dev/null 2>&1; do sleep 2; done' || echo "⚠️ PM check timed out"
else
  timeout 60 adb shell 'while ! pm list packages > /dev/null 2>&1; do sleep 2; done' || echo "⚠️ PM check timed out"
fi
echo "⏸️ Letting PM service stabilize (10s)..."
sleep 10
echo "✅ PM service ready after installation"

# Grant permissions immediately before starting tests
echo "🔐 Granting permissions..."
if [ -n "$DEVICE_ID" ]; then
  adb -s "$DEVICE_ID" shell pm grant "$PACKAGE_NAME" "$READ_PERMISSION" 2>/dev/null || true
  adb -s "$DEVICE_ID" shell pm grant "$PACKAGE_NAME" "$WRITE_PERMISSION" 2>/dev/null || true
else
  adb shell pm grant "$PACKAGE_NAME" "$READ_PERMISSION" 2>/dev/null || true
  adb shell pm grant "$PACKAGE_NAME" "$WRITE_PERMISSION" 2>/dev/null || true
fi

# Start permission monitor in background to handle reinstalls during test runs
echo "🔐 Starting permission monitor..."
(
  while true; do
    sleep 0.5  # Check every 500ms for faster response
    if [ -n "$DEVICE_ID" ]; then
      adb -s "$DEVICE_ID" shell pm grant "$PACKAGE_NAME" "$READ_PERMISSION" 2>/dev/null || true
      adb -s "$DEVICE_ID" shell pm grant "$PACKAGE_NAME" "$WRITE_PERMISSION" 2>/dev/null || true
    else
      adb shell pm grant "$PACKAGE_NAME" "$READ_PERMISSION" 2>/dev/null || true
      adb shell pm grant "$PACKAGE_NAME" "$WRITE_PERMISSION" 2>/dev/null || true
    fi
  done
) &
MONITOR_PID=$!
echo "✅ Permission monitor started (PID: $MONITOR_PID)"

# Update trap to cleanup both monitor and emulator on exit
if [ "$EMULATOR_STARTED" = true ]; then
  trap "echo '🧹 Cleaning up...'; kill $MONITOR_PID 2>/dev/null || true; echo '🛑 Stopping emulator...'; adb -s $DEVICE_ID emu kill 2>/dev/null || kill $EMULATOR_PID 2>/dev/null; echo '🗑️  Deleting test AVD...'; avdmanager delete avd --name $AVD_NAME 2>/dev/null || true" EXIT
else
  trap "kill $MONITOR_PID 2>/dev/null || true" EXIT
fi

# Run tests individually
echo ""
echo "🧪 Running integration tests individually..."
FAILED_TESTS=()
PASSED_TESTS=()
TOTAL_TESTS=${#TEST_FILES[@]}
CURRENT_TEST=0

for TEST_FILE in "${TEST_FILES[@]}"; do
  CURRENT_TEST=$((CURRENT_TEST + 1))
  echo ""
  echo "[$CURRENT_TEST/$TOTAL_TESTS] Running: $TEST_FILE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if [ -n "$DEVICE_ID" ]; then
    if "$(dirname "$0")/flutter_with_env.sh" test "$TEST_FILE" -d "$DEVICE_ID"; then
      PASSED_TESTS+=("$TEST_FILE")
      echo "✅ PASSED: $TEST_FILE"
    else
      FAILED_TESTS+=("$TEST_FILE")
      echo "❌ FAILED: $TEST_FILE"
    fi
  else
    if "$(dirname "$0")/flutter_with_env.sh" test "$TEST_FILE"; then
      PASSED_TESTS+=("$TEST_FILE")
      echo "✅ PASSED: $TEST_FILE"
    else
      FAILED_TESTS+=("$TEST_FILE")
      echo "❌ FAILED: $TEST_FILE"
    fi
  fi
done

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total:  $TOTAL_TESTS"
echo "Passed: ${#PASSED_TESTS[@]}"
echo "Failed: ${#FAILED_TESTS[@]}"
echo ""

if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
  echo "✅ All integration tests passed!"
  exit 0
else
  echo "❌ Failed tests:"
  for TEST in "${FAILED_TESTS[@]}"; do
    echo "   - $TEST"
  done
  exit 1
fi
