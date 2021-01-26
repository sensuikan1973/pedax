// This file is provided as a convenience for running integration tests via the
// flutter drive command.
//
// flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart

// See: The library 'package:integration_test/integration_test.dart' is legacy,
// ignore: import_of_legacy_library_into_null_safe
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async => integrationDriver();
