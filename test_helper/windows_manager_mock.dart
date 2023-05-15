import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

// https://github.com/leanflutter/window_manager/blob/main/test/window_manager_test.dart
@isTest
void mockWindowsManager() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('window_manager'),
    null,
  );
}
