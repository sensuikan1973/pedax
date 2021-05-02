import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

@isTest
Future<void> waitEdaxSetuped(WidgetTester tester) async {
  await Future<void>.delayed(const Duration(seconds: 1));
  await tester.pump(); // after spwaning EdaxServer has completed, render UI.
  await Future<void>.delayed(const Duration(seconds: 1)); // wait EdaxServer execute edax_init.
  await tester.pump(); // after edax init has completed, render UI.
}
