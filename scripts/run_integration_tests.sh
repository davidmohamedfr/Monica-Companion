#!/bin/bash
set -e

# Script to run integration tests with automatic permission granting
#
# Problem: `flutter test integration_test/` rebuilds and reinstalls the APK,
#          losing runtime permissions granted via `adb install -g`
#
# Solution: Run permission monitor in background that continuously grants
#           permissions every 3 seconds during test execution
#
# Usage: ./scripts/run_integration_tests.sh [device-id]
# Example: ./scripts/run_integration_tests.sh emulator-5556

DEVICE_ID=${1:-}
PACKAGE_NAME="fr.m0hdaCorp.monica_companion"
PERMISSION="android.permission.READ_CONTACTS"

# Build APK
echo "Building APK..."
flutter build apk --debug

# Install with permissions
echo "Installing APK with permissions..."
if [ -n "$DEVICE_ID" ]; then
  adb -s "$DEVICE_ID" install -g build/app/outputs/flutter-apk/app-debug.apk
else
  adb install -g build/app/outputs/flutter-apk/app-debug.apk
fi

# Start permission monitor in background
(
  sleep 2
  while true; do
    if [ -n "$DEVICE_ID" ]; then
      adb -s "$DEVICE_ID" shell pm grant "$PACKAGE_NAME" "$PERMISSION" 2>/dev/null || true
    else
      adb shell pm grant "$PACKAGE_NAME" "$PERMISSION" 2>/dev/null || true
    fi
    sleep 3
  done
) &
MONITOR_PID=$!

# Trap to cleanup monitor on exit
trap "kill $MONITOR_PID 2>/dev/null || true" EXIT

# Run tests
echo "Running integration tests..."
if [ -n "$DEVICE_ID" ]; then
  flutter test integration_test/ -d "$DEVICE_ID"
else
  flutter test integration_test/
fi

TEST_RESULT=$?

# Cleanup
kill $MONITOR_PID 2>/dev/null || true

exit $TEST_RESULT
