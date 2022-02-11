import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

const _methodChannels = [
  // See: https://github.com/flutter/plugins/blob/master/packages/file_selector/file_selector_platform_interface/lib/src/method_channel/method_channel_file_selector.dart
  MethodChannel('plugins.flutter.io/file_selector'),
  // See: https://github.com/flutter/plugins/blob/master/packages/file_selector/file_selector_windows/lib/file_selector_windows.dart
  MethodChannel('plugins.flutter.io/file_selector_windows'),
];

@isTest
void mockFileSelector() {
  for (final channel in _methodChannels) {
    channel.setMockMethodCallHandler((final methodCall) async {
      if (methodCall.method == 'openFile') return null;
      return null;
    });
  }
}
