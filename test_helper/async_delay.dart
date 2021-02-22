import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

// For EdaxServer: expect move response ~ rendering is less than 200 millisec
@isTest
Future<void> delay200millisec(WidgetTester tester) async => Future<void>.delayed(const Duration(milliseconds: 200));
