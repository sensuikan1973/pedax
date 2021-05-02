import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

@isTest
Future<void> waitEdaxSetuped(WidgetTester tester) async {
  print('will delay 1'); // ignore: avoid_print
  await Future<void>.delayed(const Duration(seconds: 1));
  print('will pump 1'); // ignore: avoid_print
  await tester.pump(); // after spwaning EdaxServer has completed, render UI.
  print('will delay 2'); // ignore: avoid_print
  await Future<void>.delayed(const Duration(seconds: 1)); // wait EdaxServer execute edax_init.
  print('will pump 2'); // ignore: avoid_print
  await tester.pump(); // after edax init has completed, render UI.
}
