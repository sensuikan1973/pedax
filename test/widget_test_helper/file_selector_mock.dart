import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

// See: https://github.com/flutter/plugins/blob/master/packages/file_selector/file_selector_platform_interface/lib/src/method_channel/method_channel_file_selector.dart
@isTest
void mockFileSelector() {
  const MethodChannel('plugins.flutter.io/file_selector').setMockMethodCallHandler((final methodCall) async {
    if (methodCall.method == 'openFile') return null;
    return null;
  });
}
