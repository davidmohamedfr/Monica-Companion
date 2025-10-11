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
  # Build APK if not provided
  echo "Building APK..."
  flutter build apk --debug
  APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
fi

# Install with permissions
echo "Installing APK with permissions..."
if [ -n "$DEVICE_ID" ]; then
  adb -s "$DEVICE_ID" install -g "$APK_PATH"
else
  adb install -g "$APK_PATH"
fi

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

# Trap to cleanup monitor on exit
trap "kill $MONITOR_PID 2>/dev/null || true" EXIT

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
    if flutter test "$TEST_FILE" -d "$DEVICE_ID"; then
      PASSED_TESTS+=("$TEST_FILE")
      echo "✅ PASSED: $TEST_FILE"
    else
      FAILED_TESTS+=("$TEST_FILE")
      echo "❌ FAILED: $TEST_FILE"
    fi
  else
    if flutter test "$TEST_FILE"; then
      PASSED_TESTS+=("$TEST_FILE")
      echo "✅ PASSED: $TEST_FILE"
    else
      FAILED_TESTS+=("$TEST_FILE")
      echo "❌ FAILED: $TEST_FILE"
    fi
  fi
done

# Cleanup
echo ""
echo "🧹 Cleaning up..."
kill $MONITOR_PID 2>/dev/null || true

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
