import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

// See: https://github.com/flutter/plugins/blob/master/packages/url_launcher/url_launcher_platform_interface
@isTest
void mockUrlLauncher() {
  if (!Platform.isMacOS) return;
  const MethodChannel('plugins.flutter.io/url_launcher').setMockMethodCallHandler((final methodCall) async {
    if (methodCall.method == 'canLaunch') return false;
    if (methodCall.method == 'launch') return false;
    return null;
  });
}
