import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

// EdaxServer process: less than 150 millisec with default book
@isTest
Future<void> delay150millisec(WidgetTester tester) async => Future<void>.delayed(const Duration(milliseconds: 150));
