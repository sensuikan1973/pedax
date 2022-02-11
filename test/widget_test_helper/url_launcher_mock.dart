import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

const _methodChannels = [
  // See: https://github.com/flutter/plugins/blob/master/packages/url_launcher/url_launcher_platform_interface/lib/method_channel_url_launcher.dart
  MethodChannel('plugins.flutter.io/url_launcher'),
  // See: https://github.com/flutter/plugins/blob/main/packages/url_launcher/url_launcher_linux/lib/url_launcher_linux.dart#L12
  MethodChannel('plugins.flutter.io/url_launcher_linux'),
  // See: https://github.com/flutter/plugins/blob/main/packages/url_launcher/url_launcher_macos/lib/url_launcher_macos.dart#L12
  MethodChannel('plugins.flutter.io/url_launcher_macos'),
  // See: https://github.com/flutter/plugins/blob/main/packages/url_launcher/url_launcher_windows/lib/url_launcher_windows.dart#L12
  MethodChannel('plugins.flutter.io/url_launcher_windows'),
];

@isTest
void mockUrlLauncher() {
  for (final channel in _methodChannels) {
    channel.setMockMethodCallHandler((final methodCall) async {
      if (methodCall.method == 'canLaunch') return false;
      if (methodCall.method == 'launch') return false;
      return null;
    });
  }
}
