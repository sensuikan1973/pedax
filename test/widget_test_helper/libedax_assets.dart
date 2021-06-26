import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:pedax/engine/edax_asset.dart';

@isTest
Future<void> prepareLibedaxAssets() async {
  // See: https://flutter.dev/docs/cookbook/persistence/reading-writing-files#testing
  final dir = await Directory.systemTemp.createTemp();
  const MethodChannel('plugins.flutter.io/path_provider').setMockMethodCallHandler((final methodCall) async {
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
