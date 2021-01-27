// This file is provided as a convenience for running integration tests via the
// flutter drive command.
//
// flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart

// @dart = 2.11
// See: https://github.com/flutter/flutter/issues/71379
// See: https://dart.dev/null-safety/unsound-null-safety
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async => integrationDriver();
