// This file is provided as a convenience for running integration tests via the
// flutter drive command.
//
// flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart

// See: https://flutter.dev/docs/testing/integration-tests

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async => integrationDriver();
