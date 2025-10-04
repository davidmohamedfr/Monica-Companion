import 'package:integration_test/integration_test_driver.dart';

/// Standard integration test driver.
///
/// For tests requiring permissions, use the script wrapper instead:
/// ./scripts/run_integration_tests.sh
///
/// The script handles:
/// - Building and installing the app
/// - Running a permission monitor that continuously grants permissions
/// - Executing the tests
/// - Cleanup
///
/// Direct usage (without permission handling):
/// flutter drive \
///   --driver=test_driver/integration_test_driver.dart \
///   --target=integration_test/your_test.dart
Future<void> main() => integrationDriver();
