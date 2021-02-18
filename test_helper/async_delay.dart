import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

@isTest
Future<void> asyncDelay(WidgetTester tester, Duration duration) async =>
    tester.runAsync(() async => Future<void>.delayed(duration));

@isTest
Future<void> asyncDelay100millisec(WidgetTester tester) async => asyncDelay(tester, const Duration(milliseconds: 100));
