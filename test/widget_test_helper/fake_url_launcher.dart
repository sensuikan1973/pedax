import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

@isTest
void fakeUrlLauncher() {
  UrlLauncherPlatform.instance = FakeUrlLauncher();
}

@isTest
class FakeUrlLauncher extends Fake
    with
        MockPlatformInterfaceMixin // ignore: prefer_mixin
    implements
        UrlLauncherPlatform {
  @override
  Future<bool> canLaunch(String url) async => false;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async =>
      false;
}
