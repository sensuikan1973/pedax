import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

@isTest
Future<void> waitEdaxSetuped(final WidgetTester tester) async {
  await Future<void>.delayed(const Duration(seconds: 1));
  await tester.pump(); // after spawning EdaxServer has completed, render UI.
  await Future<void>.delayed(const Duration(seconds: 1)); // wait EdaxServer execute edax_init.
  await tester.pump(); // after edax init has completed, render UI.
}

// For EdaxServer: expect move response ~ rendering is less than 300 millisec
@isTest
Future<void> waitEdaxServerResponsed(final WidgetTester tester) async =>
    Future<void>.delayed(const Duration(milliseconds: 300));
