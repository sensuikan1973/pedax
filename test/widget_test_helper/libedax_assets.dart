import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:path_provider_macos/path_provider_macos.dart';
import 'package:pedax/engine/edax_asset.dart';

@isTest
Future<void> prepareLibedaxAssets() async {
  // See: https://flutter.dev/docs/cookbook/persistence/reading-writing-files#testing
  final dir = await Directory.systemTemp.createTemp();
  // See: https://github.com/flutter/plugins/pull/4547/files#diff-a5ae049a146b414930be866a1128adedf7c2298ed4807d4504d5c462a5146331
  PathProviderMacOS().methodChannel.setMockMethodCallHandler((final methodCall) async {
    if (methodCall.method == 'getApplicationDocumentsDirectory') return dir.path;
    return null;
  });

  _copyDylibForTestOnMacOS();
}

// See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
// See: lib/engine/edax_asset.dart #_setupDll
void _copyDylibForTestOnMacOS() {
  if (!Platform.isMacOS) return;
  File('macos/${EdaxAsset.libedaxName}').copySync(EdaxAsset.libedaxName);
}
