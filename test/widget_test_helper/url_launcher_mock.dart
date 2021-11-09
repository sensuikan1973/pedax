import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

// See: https://github.com/flutter/plugins/blob/master/packages/url_launcher/url_launcher_platform_interface/lib/method_channel_url_launcher.dart
@isTest
void mockUrlLauncher() {
  const MethodChannel('plugins.flutter.io/url_launcher').setMockMethodCallHandler((final methodCall) async {
    if (methodCall.method == 'canLaunch') return false;
    if (methodCall.method == 'launch') return false;
    return null;
  });
}
