#!/bin/bash
set -e

# Script to run integration tests with automatic permission granting
#
# Problem: `flutter test integration_test/` and `flutter drive` lose runtime
#          permissions when app is reinstalled during test execution
#
# Solution: Run permission monitor in background that continuously grants
#           permissions every 2 seconds during test execution
#
# Usage: ./scripts/run_integration_tests.sh [device-id] [test-file]
# Examples:
#   ./scripts/run_integration_tests.sh
#   ./scripts/run_integration_tests.sh emulator-5556
#   ./scripts/run_integration_tests.sh "" integration_test/contacts_integration_test.dart

DEVICE_ID=${1:-}
TEST_TARGET=${2:-"integration_test/"}
PACKAGE_NAME="fr.m0hdaCorp.monica_companion"
PERMISSION="android.permission.READ_CONTACTS"

echo "🚀 Running integration tests with auto-granted permissions"
echo "   Device: ${DEVICE_ID:-auto}"
echo "   Target: $TEST_TARGET"
echo ""

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
echo "🔐 Starting permission monitor..."
(
  sleep 2
  while true; do
    if [ -n "$DEVICE_ID" ]; then
      adb -s "$DEVICE_ID" shell pm grant "$PACKAGE_NAME" "$PERMISSION" 2>/dev/null || true
    else
      adb shell pm grant "$PACKAGE_NAME" "$PERMISSION" 2>/dev/null || true
    fi
    sleep 2  # Check every 2 seconds
  done
) &
MONITOR_PID=$!
echo "✅ Permission monitor started (PID: $MONITOR_PID)"

# Trap to cleanup monitor on exit
trap "kill $MONITOR_PID 2>/dev/null || true" EXIT

# Run tests
echo ""
echo "🧪 Running integration tests..."
if [ -n "$DEVICE_ID" ]; then
  flutter test "$TEST_TARGET" -d "$DEVICE_ID"
else
  flutter test "$TEST_TARGET"
fi

TEST_RESULT=$?

# Cleanup
echo ""
echo "🧹 Cleaning up..."
kill $MONITOR_PID 2>/dev/null || true

if [ $TEST_RESULT -eq 0 ]; then
  echo "✅ Integration tests completed successfully!"
else
  echo "❌ Integration tests failed with exit code $TEST_RESULT"
fi

exit $TEST_RESULT
