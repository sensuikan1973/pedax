import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

@isTest
void mockFileSelector() {
  // See: https://github.com/flutter/plugins/blob/master/packages/file_selector/file_selector_platform_interface/lib/src/method_channel/method_channel_file_selector.dart
  const MethodChannel('plugins.flutter.io/file_selector').setMockMethodCallHandler((final methodCall) async {
    if (methodCall.method == 'openFile') return null;
    return null;
  });

  // See: https://github.com/flutter/plugins/blob/master/packages/file_selector/file_selector_windows/lib/file_selector_windows.dart
  const MethodChannel('plugins.flutter.io/file_selector_windows').setMockMethodCallHandler((final methodCall) async {
    if (methodCall.method == 'openFile') return null;
    return null;
  });
}
