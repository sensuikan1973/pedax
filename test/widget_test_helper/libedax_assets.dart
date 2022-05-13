import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:pedax/engine/edax_asset.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

@isTest
Future<void> prepareLibedaxAssets() async {
  // REF: https://docs.flutter.dev/cookbook/persistence/reading-writing-files
  PathProviderPlatform.instance = FakePathProviderPlatform(tempDir: await Directory.systemTemp.createTemp());

  _copyDylibForTestOnMacOS();
}

// See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
// See: lib/engine/edax_asset.dart #_setupDll
void _copyDylibForTestOnMacOS() {
  if (!Platform.isMacOS) return;
  File('macos/${EdaxAsset.libedaxName}').copySync(EdaxAsset.libedaxName);
}

@isTest
class FakePathProviderPlatform extends Fake
    with
        MockPlatformInterfaceMixin // ignore: prefer_mixin
    implements
        PathProviderPlatform {
  FakePathProviderPlatform({required this.tempDir});

  final Directory tempDir;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir.path;
}
